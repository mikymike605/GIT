SELECT * FROM sys.sysprocesses where spid >50 and waittime >0
Exec sp_who2
--KILL SPID
--DBCC inputbuffer(SPID)

select percent_complete,datediff(mi,start_time,getdate())as Temps_ecoule,text 
from sys.dm_exec_requests cross apply sys.dm_exec_sql_text (sql_handle) 
where command like '%DBCC%' 

