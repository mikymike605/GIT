USE [AdminSQL]
GO
/****** Object:  StoredProcedure [dbo].[SETUP_MIRROR]    Script Date: 14/09/2016 11:26:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		C.ISSENLOR - OSMOZIUM
-- Create date: 25 Mai 2016
-- Description:	Setup auto mirroring
-- =============================================
ALTER PROCEDURE [dbo].[SETUP_MIRROR]
@WindowsShareDestination Varchar(8000) = NULL,
@InstanceDestination Varchar(8000) = NULL,
@MySourceDatabase Varchar(8000) = NULL,
@input_DefaultDestinationDataPath Varchar(8000) = NULL,
@input_DefaultDestinationLogPath Varchar(8000) = NULL
AS
BEGIN
exec sp_configure 'allow updates',0
reconfigure

exec sp_configure 'show advanced options',1
RECONFIGURE

exec sp_configure 'xp_cmdshell',1
RECONFIGURE

SET NOCOUNT ON

DECLARE @DefaultDestinationDataPath NVarchar(1000)
DECLARE @DefaultDestinationLogPath NVarchar(1000)
DECLARE @MyDestinationDatabase NVarchar(1000)
set @MyDestinationDatabase = @MySourceDatabase

DECLARE 
    @DeviceFrom NVarchar(1000),
    @DeviceTo NVarchar(1000),
    @LogicalName NVarchar(1000),
    @PhysicalName NVarchar(1000),
    @CMD Varchar(8000),
    @SQL Varchar(8000),
	@RowsToProcess integer,
    @CurrentRow integer,
    @Comma NVarchar(25),
	@type CHAR(1);

DECLARE @Tresult TABLE (data NVarchar(1000))
SET @CMD = 'SQLCMD.exe -S '+@InstanceDestination+ ' -E'+ ' -Q "SET NOCOUNT ON ; SELECT SERVERPROPERTY(''INSTANCEDEFAULTDATAPATH'')"'
INSERT INTO @Tresult EXEC XP_CMDSHELL @CMD

SET @DefaultDestinationDataPath=(SELECT TOP 1 * FROM @Tresult WHERE LEN(data) <> 0  and data not like '-%')
SET @CMD = 'SQLCMD.exe -S '+@InstanceDestination+ ' -E'+ ' -Q "SET NOCOUNT ON ; SELECT SERVERPROPERTY(''INSTANCEDEFAULTLOGPATH'')"'
DELETE FROM @Tresult
INSERT INTO @Tresult EXEC XP_CMDSHELL @CMD
SET @DefaultDestinationLogPath=(SELECT TOP 1 * FROM @Tresult WHERE LEN(data) <> 0  and data not like '-%')
--- For SQL 2008
If @input_DefaultDestinationDataPath is NOT NULL
begin
	SET @DefaultDestinationdataPath=@input_DefaultDestinationdataPath
end
If @input_DefaultDestinationLogPath is not NULL 
begin
	SET @DefaultDestinationLogPath=@input_DefaultDestinationLogPath
end

select @DefaultDestinationDataPath,@DefaultDestinationLogPath
--- passage base en recovery mode full
set @SQL='ALTER DATABASE [' +@MySourceDatabase+ '] SET RECOVERY FULL WITH NO_WAIT'
PRINT @SQL
EXEC(@SQL)

--- BACKUP DATABASE
SET @SQL = 'BACKUP DATABASE [' +@MySourceDatabase+ '] TO DISK='''+@WindowsShareDestination+'\'+@MySourceDatabase+'.bak'' ---WITH COPY_ONLY'
PRINT @SQL
EXEC(@SQL)


--- RESTORE DATABASE
SELECT @DeviceFrom = SUBSTRING(physical_name, 1,
CHARINDEX(@MyDestinationDatabase + '.mdf',
physical_name) - 1) 
FROM master.sys.master_files
WHERE name = @MyDestinationDatabase AND FILE_ID = 1;

SET @SQL = 'RESTORE DATABASE ' + @MyDestinationDatabase + ' FROM DISK = ''' + @WindowsShareDestination+'\'+@MySourceDatabase+'.bak' + ''' WITH ';
SET @CurrentRow = 0;
SET @Comma = ',';

DECLARE @FileList TABLE (
    RowID int not null primary key identity(1,1)
    ,LogicalName NVARCHAR(128) 
    ,PhysicalName NVARCHAR(260) 
    ,Type CHAR(1) 
    ,FileGroupName NVARCHAR(128) 
    ,Size numeric(20,0) 
    ,MaxSize numeric(20,0) 
    ,FileId BIGINT 
    ,CreateLSN numeric(25,0) 
    ,DropLSN numeric(25,0) 
    ,UniqueId uniqueidentifier 
    ,ReadOnlyLSN numeric(25,0) 
    ,ReadWriteLSN numeric(25,0) 
    ,BackupSizeInBytes BIGINT 
    ,SourceBlockSize BIGINT 
    ,FilegroupId BIGINT 
    ,LogGroupGUID uniqueidentifier 
    ,DifferentialBaseLSN numeric(25) 
    ,DifferentialBaseGUID uniqueidentifier 
    ,IsReadOnly BIGINT 
    ,IsPresent BIGINT
    ,TDEThumbprint VARBINARY(32) -- Remove this line for SQL Server 2005
    );
	
INSERT INTO @FileList
EXEC('RESTORE FILELISTONLY FROM DISK = ''' + @WindowsShareDestination+'\'+@MySourceDatabase+'.bak' + '''')
SET @RowsToProcess = @@RowCount;

WHILE @CurrentRow < @RowsToProcess
BEGIN
    SET @CurrentRow= @CurrentRow + 1;
    BEGIN
    IF @CurrentRow = @RowsToProcess
        SET @Comma = ',REPLACE';
    END
	select 'numligne',@CurrentRow 
	select * FROM @FileList 
    SELECT @LogicalName = LogicalName,@PhysicalName = PhysicalName,@type=type FROM @FileList WHERE RowID=@CurrentRow;
	select * FROM @FileList
    --SET @PhysicalName = Replace(@PhysicalName,@LogicalName,@MyDestinationDatabase);
    IF @Type='D' and @CurrentRow=1 begin SET @PhysicalName = @DefaultDestinationDataPath+@LogicalName+'.mdf' end
	IF @Type='D' and @CurrentRow <> 1 begin SET @PhysicalName = @DefaultDestinationDataPath+@LogicalName+'.ndf' end
	IF @Type='L'  begin SET @PhysicalName = @DefaultDestinationLogPath+@LogicalName+'.ldf' end

    SET @SQL = @SQL + 'MOVE ''' + @LogicalName + ''' TO ''' + @PhysicalName + '''' + @Comma + '';
END
SET @SQL = @SQL + ',NORECOVERY'

--PREVIEW THE GENERATED QUERY
PRINT @SQL;

--EXECUTE THE GENERATED QUERY
SET @CMD = 'SQLCMD.exe -S '+@InstanceDestination+ ' -E'+ ' -Q "'+@SQL+'"'
SELECT @CMD
EXEC XP_CMDSHELL @CMD


--- BACKUP LOG
SET @SQL = 'BACKUP LOG [' +@MySourceDatabase+ '] TO DISK='''+@WindowsShareDestination+'\'+@MySourceDatabase+'.trn'''
PRINT @SQL
EXEC(@SQL)

--- RESTORE LOG
SET @SQL = 'RESTORE LOG [' +@MydestinationDatabase+ '] FROM DISK='''+@WindowsShareDestination+'\'+@MySourceDatabase+'.trn'' WITH NORECOVERY'

--PREVIEW THE GENERATED QUERY
PRINT @SQL;

--EXECUTE THE GENERATED QUERY
SET @CMD = 'SQLCMD.exe -S '+@InstanceDestination+ ' -E'+ ' -Q "'+@SQL+'"'
SELECT @CMD
EXEC XP_CMDSHELL @CMD
 
 --- configuration mirroring

--- enpoint on principal
set @SQL='if not exists (select * from sys.endpoints where name=''mirroring'')
BEGIN
CREATE ENDPOINT [Mirroring] 
	STATE=STARTED
	AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL)
	FOR DATA_MIRRORING (ROLE = PARTNER, AUTHENTICATION = WINDOWS NEGOTIATE
, ENCRYPTION = REQUIRED ALGORITHM RC4)
END'

PRINT @SQL
EXEC(@SQL)
--- endpoint on mirror
set @SQL=' if not exists (select * from sys.endpoints where name=''mirroring'') BEGIN CREATE ENDPOINT [Mirroring] STATE=STARTED AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL) FOR DATA_MIRRORING (ROLE = PARTNER, AUTHENTICATION = WINDOWS NEGOTIATE , ENCRYPTION = REQUIRED ALGORITHM RC4) END'
--PREVIEW THE GENERATED QUERY
PRINT @SQL

--EXECUTE THE GENERATED QUERY
SET @CMD = 'SQLCMD.exe -S '+@InstanceDestination+ ' -E'+ ' -Q "'+@SQL+'"'
SELECT @CMD
EXEC XP_CMDSHELL @CMD

--- START MIRRORING
set @SQL='ALTER DATABASE [' +@MydestinationDatabase+ '] SET PARTNER = ''TCP://'+@@servername+':5022'''
--PREVIEW THE GENERATED QUERY
PRINT @SQL;

--EXECUTE THE GENERATED QUERY
SET @CMD = 'SQLCMD.exe -S '+@InstanceDestination+ ' -E'+ ' -Q "'+@SQL+'"'
SELECT @CMD
EXEC XP_CMDSHELL @CMD

set @SQL='ALTER DATABASE [' +@MySourceDatabase+ '] SET PARTNER = ''TCP://'+@InstanceDestination+':5022'''
PRINT @SQL
EXEC(@SQL)

-- job de monotoring
SET @SQL='if not exists(select * from msdb..sysjobs where name =''Database Mirroring Monitor Job'') EXEC sp_dbmmonitoraddmonitoring 1; else PRINT''Job Database Mirroring Monitor  is already configured'''
PRINT @SQL
EXEC(@SQL)
SET @CMD = 'SQLCMD.exe -S '+@InstanceDestination+ ' -E'+ ' -Q "'+@SQL+'"'
SELECT @CMD
EXEC XP_CMDSHELL @CMD

--exec sp_configure 'xp_cmdshell',0
--RECONFIGURE

--exec sp_configure 'show advanced options',0
--RECONFIGURE


END


