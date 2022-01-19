WITH LastRestores AS
(
SELECT
    DatabaseName = [d].[name] ,
    [d].[create_date] ,
    [d].[compatibility_level] ,
    [d].[collation_name] ,
    r.*,
    RowNum = ROW_NUMBER() OVER (PARTITION BY d.Name ORDER BY r.[restore_date] DESC)
FROM master.sys.databases d
LEFT OUTER JOIN msdb.dbo.[restorehistory] r ON r.[destination_database_name] = d.Name
)
SELECT *
FROM [LastRestores]
WHERE [RowNum] = 1
order by restore_date desc 


Declare @DatabaseName sysname
--set @DatabaseName = 'WSS_SP2016PRD_Content_InternalSP'
use msdb;
Select  t1.name, count ( *)as database_name,
--distinct t3.user_name,
--t3.name as backup_name,
--t1.name,
--t3.description,
--(datediff( ss, t3.backup_start_date, t3.backup_finish_date))/60.0 as duration
cast (t3.backup_start_date as date) as date
--,t3.backup_finish_date
--,t3.type as [type]
--sum (t3.backup_size/1048576.0/1024) as [sum_backup GO]
--,case when (t3.backup_size/1024.0) < 1024 then (t3.backup_size/1024.0)when (t3.backup_size/1048576.0) < 1024 then (t3.backup_size/1048576.0)
--else (t3.backup_size/1048576.0/1024.0)
--end as backup_size
--,case when (t3.backup_size/1024.0) < 1024 then 'KB'  when (t3.backup_size/1048576.0) < 1024 then 'MB' 
--else 'GB' 
--end as backup_size_unit
--,t3.last_lsn- t3.first_lsn,t3.first_lsn,t3.last_lsn
--,case when t3.differential_base_lsn is null then 'Not Applicable' 
--else convert( varchar(100),t3.differential_base_lsn) 
--end as [differential_base_lsn]
--,t6.physical_device_name
--,t6.device_type as [device_type]
--,t3.recovery_model 
--,t3.backup_set_id
from  sys.databases t1 
inner  join backupset t3 on (t3.database_name = t1.name ) left outer join backupmediaset t5 on ( t3.media_set_id = t5.media_set_id )
left outer join backupmediafamily t6 on ( t6.media_set_id = t5.media_set_id )
where  type='D'
--and (t1.name = @DatabaseName)
and backup_start_date >= GETDATE()-10
and device_type=2
--and physical_device_name like '%FULL%'
--group by t3.backup_size,t3.user_name,t3.name,t1.name,t3.description,t3.backup_start_date,t3.backup_finish_date,t3.type,
--t3.last_lsn,t3.first_lsn,t3.differential_base_lsn,t6.physical_device_name,t6.device_type,t3.recovery_model,t3.backup_set_id
--having t3.backup_size/1048576.0/1024 >1
group by cast (t3.backup_start_date as date), t1.name--,backup_size
having count ( *) >1
order by cast (t3.backup_start_date as date) desc--,t3.backup_set_id,t6.physical_device_name