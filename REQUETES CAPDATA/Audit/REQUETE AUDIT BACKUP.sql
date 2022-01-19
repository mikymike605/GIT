USE MSDB
SELECT 
sd.name, BS.recovery_model,
max(case type  when 'D' then backup_start_date end) as backupFULL,
max(case type  when 'I' then backup_start_date end) as backupDIFF,
max(case type  when 'L' then backup_start_date end) as backupLOG
FROM master..sysdatabases sd 
LEFT JOIN msdb.dbo.backupset bs 
ON database_name = sd.name 
WHERE DatabasePropertyEx (sd.name, 'Status')='ONLINE' 
AND BS.recovery_model = 'FULL'
---AND sd.name <> 'AdminSQL' 
GROUP BY sd.name, database_name ,BS.recovery_model
HAVING datediff(HOUR,max(case type  when 'L' then backup_start_date end),getdate()) > 24
AND max(case type  when 'D' then backup_start_date end) > DATEADD(Hour,2,getdate()-1)
--HAVING max(case type  when 'D' then backup_start_date end) is null
--OR max(case type  when 'L' then backup_start_date end) is null
--OR max(case type  when 'D' then backup_start_date end) < DATEADD(Hour,2,getdate()-1)
--OR datediff(HOUR,max(case type  when 'L' then backup_start_date end),getdate()) > 1 