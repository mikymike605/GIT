if object_id('tempdb..#tmp') is not null drop table #tmp;  

SELECT d.name AS 'DATABASE_Name',
MAX(CASE WHEN bu.type = 'D' THEN bu.LastBackupDate END) AS 'Full DB Backup Status',
MAX(CASE WHEN bu.type = 'I' THEN bu.LastBackupDate END) AS 'Differential DB Backup Status',
MAX(CASE WHEN bu.type = 'L' THEN bu.LastBackupDate END) AS 'Transaction DB Backup Status',
CASE d.recovery_model WHEN 1 THEN 'Full' WHEN 2 THEN 'Bulk Logged' WHEN 3 THEN 'Simple' END RecoveryModel
into #tmp
FROM master.sys.databases d
LEFT OUTER JOIN (SELECT database_name, type, MAX(backup_start_date) AS LastBackupDate
SELECT * FROM msdb.dbo.backupset where type = 'i' order by database_creation_date desc 
where cast (backup_start_date as date) < cast (getdate()-1 as date)
and YEAR (backup_start_date)=YEAR(getdate())
and month(backup_start_date)=month(getdate())
GROUP BY database_name, type) AS bu ON d.name = bu.database_name
GROUP BY d.Name, d.recovery_model

select * from #tmp
where  cast ([Full DB Backup Status] as date) < cast (getdate()-6 as date)
or cast ([Differential DB Backup Status] as date) <= cast (getdate()-2 as date)