USE msdb
select
backup_start_date as date, 
sd.name,
 backup_size as size,
datediff(MINUTE,backup_start_date,backup_finish_date) as duration
FROM master..sysdatabases sd  
LEFT JOIN msdb.dbo.backupset bs 
ON database_name = sd.name 
--WHERE DatabasePropertyEx (sd.name, 'Status')='ONLINE' 
--and  sd.name = 'ODS'
order by 1 desc