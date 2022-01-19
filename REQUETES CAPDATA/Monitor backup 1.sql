--- Liste bases :
--- Pas de Backup FULL depuis plus de 24H + 2H (temps du backup)
--- Pas de Backup LOG depuis plus 1H
USE MSDB
SELECT 
sd.name,
max(case type  when 'D' then backup_start_date end) as backupFULL,
max(case type  when 'I' then backup_start_date end) as backupDIFF,
max(case type  when 'L' then backup_start_date end) as backupLOG
FROM master..sysdatabases sd  
LEFT JOIN msdb.dbo.backupset bs 
ON database_name = sd.name 
WHERE DatabasePropertyEx (sd.name, 'Status')='ONLINE' 
---AND sd.name <> 'AdminSQL' 
GROUP BY sd.name, database_name 
HAVING max(case type  when 'D' then backup_start_date end) is null
OR max(case type  when 'L' then backup_start_date end) is null
OR max(case type  when 'D' then backup_start_date end) < DATEADD(Hour,2,getdate()-1)
OR datediff(HOUR,max(case type  when 'L' then backup_start_date end),getdate()) > 1 

USE MSDB
Go
SET NOCOUNT ON
GO
SET ANSI_WARNINGS OFF
GO
SELECT 
sd.name,
max(case type  when 'D' then backup_start_date end) as backupFULL
FROM master..sysdatabases sd  
LEFT JOIN msdb.dbo.backupset bs 
ON database_name = sd.name 
WHERE DatabasePropertyEx (sd.name, 'Status')='ONLINE' 
---AND sd.name <> 'AdminSQL' 
GROUP BY sd.name, database_name 
HAVING max(case type  when 'D' then backup_start_date end) is null
OR max(case type  when 'D' then backup_start_date end) < DATEADD(Hour,2,getdate()-1)


