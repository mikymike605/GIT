SELECT 
--bs.database_name AS DatabaseName
 sum (CAST(bs.backup_size/1024.0/1024/1024 AS DECIMAL(10, 2))) AS BackupSizeGB
--,sum( CAST(bs.backup_size/1024.0/1024 AS DECIMAL(10, 2))) AS BackupSizeMB
, sum (CAST(bs.compressed_backup_size/1024.0/1024/1024 AS DECIMAL(10, 2))) AS CompressedSizeGB   
       --, sum (CAST(bs.compressed_backup_size/1024.0/1024 AS DECIMAL(10, 2))) AS CompressedSizeMB
, cast (bs.backup_start_date as date)AS BackupStartDate
--, bs.backup_finish_date AS BackupEndDate
--, CAST(bs.backup_finish_date - bs.backup_start_date AS TIME) AS AmtTimeToBkup
--, bmf.physical_device_name AS BackupDeviceName
FROM msdb.dbo.backupset bs JOIN msdb.dbo.backupmediafamily bmf
ON bs.media_set_id = bmf.media_set_id
WHERE
--bs.database_name = ‘MyDatabase’ and   — uncomment to filter by database name
bs.backup_start_date > DATEADD(dd, -10, GETDATE()) and
bs.type = 'D' --— change to L for transaction logs
group by cast (bs.backup_start_date as date)
ORDER BY  cast (bs.backup_start_date as date) desc 


Declare @DatabaseName sysname
--set @DatabaseName = 'WSS_SP2016PRD_Content_InternalSP'
use msdb;
Select 
--distinct t3.user_name
--t3.name as backup_name
--t1.name
--,t3.description
--,(datediff( ss, t3.backup_start_date, t3.backup_finish_date))/60.0 as duration,t3.backup_start_date,t3.backup_finish_date,t3.type as [type]
--case when  sum ((t3.backup_size/1024.0)) < 1024 then (t3.backup_size/1024.0)
--when sum ( (t3.backup_size/1048576.0)) < 1024 then (t3.backup_size/1048576.0)
--else sum ( (t3.backup_size/1048576.0/1024.0))
--end as backup_size,
 sum (CAST(t3.backup_size/1024.0/1024/1024 AS DECIMAL(10, 2))) as BackupSizeGB
--sum (t3.backup_size)/1024/1024/1024 as BackupSizeGB,
, sum (CAST(t3.compressed_backup_size/1024.0/1024/1024 AS DECIMAL(10, 2))) AS CompressedSizeGB   
--sum (T3.compressed_backup_size)/1024/1024/1024 as CompressedSizeGB,
,cast (t3.backup_start_date as date) as BackupStartDate,
--sum (t3.backup_size)
case when sum (t3.backup_size/1024.0) < 1024 then 'KB'  when sum (t3.backup_size/1048576.0) < 1024 then 'MB' 
else 'GB' 
end as backup_size_unit
--,t3.last_lsn- t3.first_lsn,t3.first_lsn,t3.last_lsn
--,case when t3.differential_base_lsn is null then 'Not Applicable' 
--else convert( varchar(100),t3.differential_base_lsn) 
--end as [differential_base_lsn]
--,t6.physical_device_name
--,t6.device_type as [device_type]
--,t3.recovery_model 
--,t3.backup_set_id 
from  sys.databases t1 
inner  join backupset t3 on (t3.database_name = t1.name ) 
left outer join backupmediaset t5 on ( t3.media_set_id = t5.media_set_id )
left outer join backupmediafamily t6 on ( t6.media_set_id = t5.media_set_id )
where  type='D'
--and (t1.name = @DatabaseName)
and cast (t3.backup_start_date as date) >= GETDATE()-20
--and physical_device_name like '%FULL%'
group by cast (t3.backup_start_date as date)--,t3.backup_size
order by cast (t3.backup_start_date as date) desc
--order by backup_start_date desc,t3.backup_set_id,t6.physical_device_name