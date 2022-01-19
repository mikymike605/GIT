SELECT DISTINCT 
    s.database_name,
    s.backup_start_date,
    s.backup_finish_date,
    mf.physical_device_name,
    s.backup_size / 1000000000 AS backup_size_Go,
    CASE WHEN s.type = 'D' THEN 'Full' 
         WHEN s.type = 'I' THEN 'Diff' 
         WHEN s.type = 'L' THEN 'Log' 
         ELSE 'Not define' 
    END AS type
FROM msdb..backupset s 
JOIN msdb..backupfile f ON f.backup_set_id = s.backup_set_id 
JOIN msdb..backupmediaset ms ON s.media_set_id = ms.media_set_id
JOIN msdb..backupmediafamily mf ON ms.media_set_id = mf.media_set_id
where mf.physical_device_name like 'K%'
and s.database_name = 'ECP'
--where s.server_name like '%cognos%'
ORDER BY s.backup_finish_date DESC;