USE MSDB
select
backup_start_date as date, 
sd.name,
coalesce ( compressed_backup_size,backup_size,null) as size,
datediff(MINUTE,backup_start_date,backup_finish_date) as duration
FROM master..sysdatabases sd  
LEFT JOIN msdb.dbo.backupset bs 
ON database_name = sd.name 
WHERE DatabasePropertyEx (sd.name, 'Status')='ONLINE' 
and  sd.name = 'ODS'