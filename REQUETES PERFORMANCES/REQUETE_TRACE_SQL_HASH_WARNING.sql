--SELECT * FROM fn_trace_getinfo(0) 

select count ( databasename),databasename
, cast (starttime as date)
       ,e.name "event"
       ,ObjectType
       ,applicationname
       ,HostName
       ,LoginName
       --,SPID
from fn_trace_gettable('E:\SQL2012\MSSQL11.MSSQLSERVER\MSSQL\Log\log_985.trc', default)t
	join sys.trace_events e on t.eventclass=e.trace_event_id
WHERE starttime > convert(datetime,'2019-10-28 08:00:00',102) 
	--and databasename in ('MEGATEST_SystemDb', 'MEGATEST_Travail') 
	and SPID<>@@SPID
	and e.name='Hash Warning'
	group by cast (starttime as date),e.name ,databasename
       ,ObjectType
       ,applicationname
       ,HostName
       ,LoginName
order by cast (starttime as date)	 desc
