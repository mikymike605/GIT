DECLARE @backuppath VARCHAR(4000)

EXEC master.dbo.xp_instance_regread
		'HKEY_LOCAL_MACHINE',
		'Software\Microsoft\MSSQLServer\MSSQLServer',
		'BackupDirectory',
		@backuppath OUTPUT, 
		'no_output'
SET @backuppath=@backuppath+'\'+  CONVERT(varchar, getdate(),112)+'_'+ LEFT (convert (varchar, getdate(),24),2)+ substring(convert (varchar, getdate(),24),4,2)+'\'

--DECLARE @targetDirectory nvarchar(max) = N'E:\backup' 
exec xp_create_subdir @backuppath

---- Base FORMATION									
--BACKUP DATABASE [FORMATION] TO  DISK='G:\bases\mssql\backup\2020-08-27\FORMATION_20200827091912.bak' WITH NO_COMPRESSION,  INIT,  NAME='Sauvegarde full de la base FORMATION'
	