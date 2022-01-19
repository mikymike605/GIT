

 --1 session(s) bloquee(s) depuis 15556s par GDSFW\SVC-SCVMM (SVC-SCVMM GDSB1VMM001) sur SCVMMB1 (126, VirtualMachineManager)
SELECT waittime /1000/60 TimeStamp_Min , * FROM sys.sysprocesses where  spid >50 and waittime >0 and blocked >0 
order by waittime desc

	SELECT r.session_id,r.command,CONVERT(NUMERIC(6,2),r.percent_complete)AS [Percent Complete]
,CONVERT(VARCHAR(20),DATEADD(ms,r.estimated_completion_time,GetDate()),20) AS [ETA Completion Time],
CONVERT(NUMERIC(10,2),r.total_elapsed_time/1000.0/60.0) AS [Elapsed Min],
CONVERT(NUMERIC(10,2),r.estimated_completion_time/1000.0/60.0)  AS [ETA Min],
CONVERT(NUMERIC(10,2),r.estimated_completion_time/1000.0/60.0/60.0) AS [ETA Hours],
CONVERT(VARCHAR(1000),(SELECT SUBSTRING(text,r.statement_start_offset/2,
CASE WHEN r.statement_end_offset = -1 THEN 1000 ELSE (r.statement_end_offset-r.statement_start_offset)/2 END)
FROM sys.dm_exec_sql_text(sql_handle)))
FROM sys.dm_exec_requests r
 WHERE command like ('%BACKUP%') or command like ('%RESTORE%')or command like ('%INDEX%')or command like ('%DBCC%')

select '--kill '+cast (session_id as varchar)+'','DBCC inputbuffer ('+cast (session_id as varchar)+')'
, session_id,percent_complete,datediff(MINUTE,start_time,getdate())Temps_ecoule_Minutes ,
case 
when datediff(MINUTE,start_time,getdate())  <60 then  datediff(MINUTE,start_time,getdate()) 
when datediff(MINUTE,start_time,getdate())<1440 then  datediff(MINUTE,start_time,getdate())  /60
when datediff(MINUTE,start_time,getdate())>1800 then  datediff(MINUTE,start_time,getdate()) /60/24 
end as Temps_ecoule,
case  
when datediff(MINUTE,start_time,getdate()) <1 then 'Secondes' 
when datediff(MINUTE,start_time,getdate())  <60 then 'Minutes'
when datediff(MINUTE,start_time,getdate()) < 1440 then 'Heures'
when datediff(MINUTE,start_time,getdate()) >1800 then 'Jours'
end as Temps_ecoule
,text 
from sys.dm_exec_requests cross apply sys.dm_exec_sql_text (sql_handle) m
--where  text like ('%varchar(8000)%') 

SELECT waittime /1000/60 TimeStamp_Min , * FROM sys.sysprocesses where  spid >50 and waittime >0 and blocked >0 
order by waittime desc
Exec sp_who2 
--KILL 107
--DBCC inputbuffer(64)
