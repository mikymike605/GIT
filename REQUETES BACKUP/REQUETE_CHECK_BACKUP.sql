USE msdb
SELECT  
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
   msdb.dbo.backupset.database_name,  
   msdb.dbo.backupset.backup_start_date,  
   msdb.dbo.backupset.backup_finish_date, 
   msdb.dbo.backupset.expiration_date, 
   msdb.dbo.backupset.user_name, 
   CONVERT(time(7),DATEADD(s, DATEDIFF(s,msdb.dbo.backupset.backup_start_date,msdb.dbo.backupset.backup_finish_date),'00:00:00')),
    CASE msdb..backupset.type  
       WHEN 'D' THEN 'FULL'
	   WHEN 'I' THEN 'DIFF'  
       WHEN 'L' THEN 'Log' 
	   --else 'Full' 
   END AS backup_type,  
   msdb.dbo.backupset.backup_size,  
   msdb.dbo.backupmediafamily.logical_device_name,  
   msdb.dbo.backupmediafamily.physical_device_name,   
   msdb.dbo.backupset.name AS backupset_name, 
   msdb.dbo.backupset.description 
FROM   msdb.dbo.backupmediafamily  
   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id  
WHERE  (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 37) 
--and msdb.dbo.backupset.user_name ='NT AUTHORITY\SYSTEM' 
and msdb.dbo.backupset.database_name='SID_PRD'
--and msdb..backupset.type =  'I'
ORDER BY  
   msdb.dbo.backupset.database_name, 
   msdb.dbo.backupset.backup_finish_date desc