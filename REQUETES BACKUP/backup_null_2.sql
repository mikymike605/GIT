DECLARE @backuppath VARCHAR(128)
DECLARE @db_id INT
DECLARE @date VARCHAR(14)
-- DECLARE @sql VARCHAR(4096)
DECLARE @ErrorMessage NVARCHAR(4000)

SELECT @backuppath = 'G:\bases\MSSQL\Backup\'
SELECT @db_id=MAX(database_id) FROM sys.databases
SELECT database_id, name INTO #db_list FROM sys.databases WHERE name NOT IN ('tempdb')

----drop old backup
--SET @sql='xp_delete_file 0,'''+@backuppath+''',''bak'','''+CONVERT (varchar, DATEADD(hh, -22, getdate()),126)+''''
--PRINT (@sql)
--EXEC(@sql)
--PRINT  '										'

--Backup
WHILE (@db_id > 0)
BEGIN
	PRINT '-- Base '+DB_NAME(@db_id)+'									'
	BEGIN TRY
		SELECT @date=CONVERT (VARCHAR, getdate(), 112)+SUBSTRING (CONVERT (VARCHAR, getdate(), 108),1,2)+SUBSTRING (CONVERT (VARCHAR, getdate(), 108),4,2)+SUBSTRING (CONVERT (VARCHAR, getdate(), 108),7,2)
		SET @sql=''
		SELECT @sql='BACKUP DATABASE ['+name+'] TO  DISK='''+@backuppath+name+'_'+@date+'.bak'' WITH INIT,  NAME=''Sauvegarde full de la base '+name+'''' FROM #db_list WHERE database_id=@db_id
		IF @sql<>''
		BEGIN
			PRINT (@sql)
			--EXEC (@sql)
		END
		SELECT @sql='RESTORE DATABASE ['+name+'] FROM DISK='''+@backuppath+name+'_'+@date+'.bak''  WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 10' FROM #db_list WHERE database_id=@db_id
		IF @sql<>''
		BEGIN
			PRINT (@sql)
		--	EXEC (@sql)
		END
	END TRY
	BEGIN CATCH
		SELECT @ErrorMessage = ERROR_MESSAGE()
		PRINT @ErrorMessage
	END CATCH
	PRINT  '										'
	SET @db_id=@db_id-1
END

DROP TABLE #db_list

--IF @ErrorMessage IS NOT NULL
--BEGIN
--	RAISERROR (@ErrorMessage,16,1)
--END