SELECT 
--CONVERT(CHAR(100) ,
distinct  SERVERPROPERTY('Servername') AS Server

,msdb.dbo.backupset.database_name, 
msdb.dbo.backupset.backup_start_date, 
msdb.dbo.backupset.backup_finish_date, 
msdb.dbo.backupset.expiration_date, 
CASE msdb..backupset.type 
WHEN 'D' THEN 'Database' 
WHEN 'L' THEN 'Log' 
END AS backup_type, 
msdb.dbo.backupset.backup_size, 
msdb.dbo.backupmediafamily.logical_device_name, 
msdb.dbo.backupmediafamily.physical_device_name, 
msdb.dbo.backupset.name AS backupset_name, 
msdb.dbo.backupset.description 
FROM msdb.dbo.backupmediafamily 
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 1) 
and type = 'D'
and msdb.dbo.backupset.name is not null
ORDER BY 4 desc 
--msdb.dbo.backupset.database_name, 
--msdb.dbo.backupset.backup_finish_date 


SELECT  [rs].[destination_database_name] ,
        [rs].[restore_date] ,
        [bs].[backup_start_date] ,
        [bs].[backup_finish_date] ,
        [bs].[database_name] AS [source_database_name] ,
        [bmf].[physical_device_name] AS [backup_file_used_for_restore]
FROM    msdb..restorehistory rs
        INNER JOIN msdb..backupset bs ON [rs].[backup_set_id] = [bs].[backup_set_id]
        INNER JOIN msdb..backupmediafamily bmf ON [bs].[media_set_id] = [bmf].[media_set_id]
ORDER BY [rs].[restore_date] DESC