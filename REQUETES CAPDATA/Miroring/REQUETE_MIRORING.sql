----------------------------------------------------------------------------------------------------
-----------------ATTENTION MODIFIER LE CHEMIN POUR DEPOSER LES FICHIERS-----------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------
-----------------INSTANCE SERVEUR A (PRINCIPAL)-----------------------------
----------------------------------------------------------------------------
USE [AdminSQL]
GO
EXEC[dbo].[SETUP_MIRROR] @MySourceDatabase= N'MDMUDATA'
,@WindowsShareDestination = N'\\AUBFRMUSQLVM\Share_SQL'
,@InstanceDestination = N'AUBFRMUSQLVM'
,@input_DefaultDestinationDataPath = N'D:\DATA\'
,@input_DefaultDestinationLogPath = N'L:\LOG\'

-------BACKUP_DIFF-----------
BACKUP DATABASE [MDMUDATA] 
TO  DISK = N'\\AUBFRINFRASQLVM\Share_SQL\MDMUDATA.trn' WITH  DIFFERENTIAL , 
NOFORMAT, NOINIT,  NAME = N'MDMUDATA-Differential Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

-------BACKUP_LOG-----------
BACKUP LOG [MDMUDATA] 
TO DISK='\\AUBFRINFRASQLVM\Share_SQL\MDMUDATA.trn'

----------------------------------------------------------------------------
-----------------INSTANCE SERVEUR B (SECONDAIRE)-----------------------------
----------------------------------------------------------------------------

-------RESTORE_BACKUP_DIFF-----------
RESTORE DATABASE MDMUDATA 
FROM DISK = '\\AUBFRMUSQLVM\Share_SQL\MDMUDATA_2.bak' 
WITH MOVE 'MDMUData' TO 'D:\DATA\MDMUData.mdf',
MOVE 'MDMUData_Reporting_File1' TO 'D:\DATA\MDMUData_Reporting_File1.ndf',
MOVE 'MDMUData_Broadcasts_File1' TO 'D:\DATA\MDMUData_Broadcasts_File1.ndf',
MOVE 'MDMUData_Broadcaster_File1' TO 'D:\DATA\MDMUData_Broadcaster_File1.ndf',
MOVE 'MDMUData_Catalog' TO 'D:\DATA\MDMUData_Catalog.ndf',
MOVE 'MDMUData_log' TO 'D:\DATA\MDMUData_log.ldf',REPLACE,NORECOVERY

-------RESTORE_LOG-----------
RESTORE LOG [MDMUDATA]  
FROM DISK='\\AUBFRINFRASQLVM\Share_SQL\MDMUDATA.trn' WITH NORECOVERY

-- ALTER DATABASE [MDMUDATA] SET PARTNER OFF
