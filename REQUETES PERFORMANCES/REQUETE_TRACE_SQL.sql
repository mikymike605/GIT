SELECT * FROM fn_trace_getinfo(0) 

select *
from fn_trace_gettable('E:\bases\mssql\MSSQL13.MSSQLSERVER\MSSQL\Log\log_6.trc', default)t
	join sys.trace_events e on t.eventclass=e.trace_event_id
WHERE starttime > convert(datetime,'2019-10-28 08:00:00',102) 
	--and databasename in ('MEGATEST_SystemDb', 'MEGATEST_Travail') 
	and SPID<>@@SPID
order by starttime	 desc

select distinct starttime
       ,databasename
       ,e.name "event"
       ,ObjectType
       ,applicationname
       ,HostName
       ,LoginName
       ,SPID
from fn_trace_gettable('E:\SQL2012\MSSQL11.MSSQLSERVER\MSSQL\Log\log_972.trc', default)t
       join sys.trace_events e on t.eventclass=e.trace_event_id
WHERE t.starttime > convert(datetime,'2019-10-22 17:00:00',102) 
       and databasename ='DBZZZTER' 
       and SPID=74
order by t.starttime 
