--select name,collation_name,recovery_model_desc,* from sys.databases
----where name in('ARPM4DEV')
--order by 1--- desc
  


OJVM RELEASE UPDATE 19.11.0.0.0

select 'alter user '|| username || ' account unlock;' from dba_users where account_status = 'LOCKED';

Source: https://prograide.com/pregunta/66204/ora-28001-le-mot-de-passe-a-expire

--CHECK BACKUP DATABASE GETDATE 
select t1.name,backup_start_date
from  sys.databases t1 
inner  join backupset t3 on (t3.database_name = t1.name ) 
--left outer join backupmediaset t5 on ( t3.media_set_id = t5.media_set_id )
--left outer join backupmediafamily t6 on ( t6.media_set_id = t5.media_set_id )
where  type='D'
and t1.name=t1.name
and backup_start_date >='2021-01-25 08:00:01.000'
and backup_start_date >= GETDATE()-1
order by 2 desc

--BACKUP DATABASE NOT EXIST 
use msdb;
select a.name,'('''+name+'''),'
from sys.databases a
where not exists 
(
select t1.name
from  sys.databases t1 
inner  join backupset t3 on (t3.database_name = t1.name) 
left outer join backupmediaset t5 on ( t3.media_set_id = t5.media_set_id )
left outer join backupmediafamily t6 on ( t6.media_set_id = t5.media_set_id )
where  type='D'
and a.name=t1.name
and backup_start_date >= '20210622'
)
AND a.name NOT IN ('tempdb')
			AND a.name NOT LIKE ('%HOT')
			AND a.name NOT LIKE ('%TST')
			AND a.name NOT LIKE ('%PRJ')
			AND (a.name NOT LIKE ('PFR%') OR a.name in ('PFRM4RD4','PFRM4QA3','PFRM4QA6'))
			AND a.name NOT LIKE ('PROD001_DMS')
			AND a.name NOT LIKE ('TRANSFERT')
order by 1

  
Declare @DatabaseName sysname
--set @DatabaseName = 'LVMM4QA1'
use msdb;
Select distinct t3.user_name,t3.name as backup_name,t1.name,t3.description,
(datediff( ss, t3.backup_start_date, t3.backup_finish_date))/60.0 as duration,t3.backup_start_date,t3.backup_finish_date,t3.type as [type]
,case when (t3.backup_size/1024.0) < 1024 then (t3.backup_size/1024.0)when (t3.backup_size/1048576.0) < 1024 then (t3.backup_size/1048576.0)
else (t3.backup_size/1048576.0/1024.0)
end as backup_size,
case when (t3.backup_size/1024.0) < 1024 then 'KB'  when (t3.backup_size/1048576.0) < 1024 then 'MB' 
else 'GB' 
end as backup_size_unit
,t3.last_lsn- t3.first_lsn,t3.first_lsn,t3.last_lsn
,case when t3.differential_base_lsn is null then 'Not Applicable' 
else convert( varchar(100),t3.differential_base_lsn) 
end as [differential_base_lsn]
,t6.physical_device_name,t6.device_type as [device_type],t3.recovery_model ,t3.backup_set_id 
from  sys.databases t1 
inner  join backupset t3 on (t3.database_name = t1.name ) left outer join backupmediaset t5 on ( t3.media_set_id = t5.media_set_id )
left outer join backupmediafamily t6 on ( t6.media_set_id = t5.media_set_id )
where  type='D'
--and (t1.name = 'FMTM4DEV')
and backup_start_date >= GETDATE()-2
--and physical_device_name like '%FULL%'
order by backup_start_date desc,t3.backup_set_id,t6.physical_device_name


Declare @DatabaseName1 sysname
--set @DatabaseName1 = 'facturation_dev'
use msdb;
SELECT count (cast (t3.backup_start_date as date)),cast (t3.backup_start_date as date)
from  sys.databases t1 
 inner  join backupset t3 on (t3.database_name = t1.name ) left outer join backupmediaset t5 on ( t3.media_set_id = t5.media_set_id )
 left outer join backupmediafamily t6 on ( t6.media_set_id = t5.media_set_id )
 where  type='D'
 --and (t1.name = @DatabaseName1)
and backup_start_date >= GETDATE()-20
group by cast (t3.backup_start_date as date)
--having count (cast (t3.backup_start_date as date)) =1
order by 2 desc 