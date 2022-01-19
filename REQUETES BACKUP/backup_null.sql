-------------------------
--Databases full backup--
------------------------- 
DECLARE @backupRetention int;
DECLARE @backupFiles int;
DECLARE @fileNumber int;
DECLARE @FilesList varchar(4000);
DECLARE @databasesExclusion table (db varchar(128))
DECLARE @backuppath VARCHAR(4000)
DECLARE @db_id INT
DECLARE @date VARCHAR(14)
DECLARE @sql VARCHAR(4096)
DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @cleandate varchar(25) 
DECLARE @dt datetime 

-----------------------------------------------
--                Parameters                 --
-----------------------------------------------
--Backups retention (hours)
SET @backupRetention= 22;
--Backup files/database
SET @backupFiles= 1;
--Databases exclusion list
INSERT INTO @databasesExclusion VALUES 
	('tempdb') 
--	,('db2') 
--	,('db3') 
--	,('db4')
----------------------------------------------

--backup path
EXEC master.dbo.xp_instance_regread
		'HKEY_LOCAL_MACHINE',
		'Software\Microsoft\MSSQLServer\MSSQLServer',
		'BackupDirectory',
		@backuppath OUTPUT, 
		'no_output'
SET @backuppath='G:\bases\mssql\backup\FR-COR-DWHSQLT1\'

----drop old backup
--SET @sql='xp_delete_file 0,'''+@backuppath+''',''bak'','''+CONVERT (varchar, DATEADD(hh, -@backupRetention, getdate()),126)+''''
--PRINT (@sql)
--EXEC(@sql)
--PRINT  '										'

--Backup loop
SELECT @db_id=MAX(database_id) FROM sys.databases
WHILE (@db_id > 0)
BEGIN
	IF  (SELECT db_name(@db_id) WHERE databasepropertyex(db_name(@db_id),'Updateability')='READ_WRITE' AND  databasepropertyex(db_name(@db_id),'Status')='ONLINE'
	AND db_name(@db_id) NOT IN (SELECT db FROM @databasesExclusion) ) IS NOT NULL
	BEGIN
		PRINT '-- Base '+DB_NAME(@db_id)+'									'
		BEGIN TRY
			--backup files list
			SET @date=CONVERT (VARCHAR, getdate(), 112)+SUBSTRING (CONVERT (VARCHAR, getdate(), 108),1,2)+SUBSTRING (CONVERT (VARCHAR, getdate(), 108),4,2)+SUBSTRING (CONVERT (VARCHAR, getdate(), 108),7,2);
			IF @backupFiles>1
			BEGIN
				SET @fileNumber=@backupFiles;
				SET @FilesList='';
				WHILE (@fileNumber>0)
				BEGIN
					SET @FilesList=@FilesList+' DISK='''+@backuppath+db_name(@db_id)+'_'+@date+'_0'+cast(@fileNumber as varchar)+'.bak'',';
					SET @fileNumber=@fileNumber-1;
				END
				SELECT @FilesList=substring(@FilesList, 1, (len(@FilesList) - 1));--remove last comma
			END
			ELSE 
				SET @FilesList=' DISK='''+@backuppath+db_name(@db_id)+'_'+@date+'.bak''';
			--Backup
			SET @sql='BACKUP DATABASE ['+db_name(@db_id)+'] TO '+@FilesList+' WITH NO_COMPRESSION,  INIT,  NAME=''Sauvegarde full de la base '+db_name(@db_id)+''''
			PRINT (@sql)
			--EXEC (@sql)
			--Verify
			SELECT @sql='--RESTORE DATABASE ['+db_name(@db_id)+'] FROM DISK='''+@backuppath+db_name(@db_id)+'_'+@date+'.bak''  WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 10' --FROM #db_list WHERE database_id=@db_id
			PRINT (@sql)
			--EXEC (@sql)
		END TRY
		BEGIN CATCH
			SELECT @ErrorMessage = ERROR_MESSAGE()
			PRINT @ErrorMessage
		END CATCH
		PRINT  '										'
	END
	SET @db_id=@db_id-1
END

IF @ErrorMessage IS NOT NULL
BEGIN
	RAISERROR (@ErrorMessage,16,1)
END

----History Cleanup
--SELECT @cleandate = CONVERT (varchar, DATEADD(mm, -1, getdate()),126)
--SELECT @dt = CAST(@cleandate as datetime) 

--EXEC msdb.dbo.sp_delete_backuphistory @dt
--EXEC msdb.dbo.sp_purge_jobhistory  @oldest_date=@cleandate
--EXEC msdb..sp_maintplan_delete_log null,null,@cleandate