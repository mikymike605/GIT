/****** Script for SelectTopNRows command from SSMS  ******/


  DECLARE @tbname varchar(250)

DECLARE product_cursor CURSOR FOR  
	SELECT name FROM sys.sysdatabases where name not in ('master','tempdb','model','msdb','ReportServer','ReportServerTempDB')
OPEN product_cursor  
FETCH FROM product_cursor INTO @tbname 
WHILE @@FETCH_STATUS = 0  
    BEGIN 
	--PRINT @tbname
	FETCH FROM product_cursor INTO @tbname 
	BEGIN
DECLARE @SQL VARCHAR(max)
SET @SQL=
'
DECLARE @shrink int 
set @shrink = 736982

while @shrink >9460
BEGIN

DBCC SHRINKFILE (N'SID_PRD_ODS_FG01' , @shrink)

set @shrink = @shrink - 100

END'

END
  PRINT @SQL
  --EXEC(@SQL)

  
INSERT INTO [AdminSQL].[dbo].[TB_UnUsedTable] ([Commande],[Servername],[Type],[Filename],[Filegroup],[Path],[CurrentSizeMB],[FreeSpaceMB],[TimeStamp]) EXEC(@SQL)
	END
	CLOSE product_cursor  
DEALLOCATE product_cursor

