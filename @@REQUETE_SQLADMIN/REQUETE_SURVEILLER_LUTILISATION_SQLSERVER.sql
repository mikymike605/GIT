Select spid,hostname,hostprocess,program_name,nt_username, 
blocked, waittime, waittype, loginame,cmd,spid,waittype,
waittime,lastwaittype,cpu,physical_io,memusage,login_time,
last_batch,open_tran,status,net_address, t.text 
from sys.sysprocesses sp 
--JOIN sys.dm_exec_connections con ON con.session_id = sp.sid
CROSS APPLY( select text from sys.dm_exec_sql_text(sp.sql_handle))t 
--where hostname
where last_batch >= DATEADD(minute, -5, GETDATE())
--and t.text like 'CREATE pro%'
order by physical_io desc ,cpu desc 





/** http://www.adminreseau.net/2007/10/16/surveiller-lutilisation-de-sql-server-2000/ **/


SELECT
TOP 20
SPID, Blocked,
convert(varchar(10),db_name(dbid)) as Base,
CPU,
datediff(second,login_time, getdate())/60 as Minutes,
convert(float, cpu / datediff(second,login_time, getdate())) as PScore,
convert(varchar(16), hostname) as Hôte,
convert(varchar(20), loginame) as Login,
convert(varchar(50), program_name) as Programme
FROM master..sysprocesses
WHERE datediff(second,login_time, getdate()) > 0 and SPID > 50
ORDER BY PScore desc

SELECT
convert(varchar(50), program_name) as Programme,
count(*) as CliCount,
sum(cpu) as CPUSum,
sum(datediff(second, login_time, getdate())) as SecSum,
convert(float, sum(cpu)) / convert(float, sum(datediff(second, login_time, getdate()))) as Score,
convert(float, sum(cpu)) / convert(float, sum(datediff(second, login_time, getdate()))) / count(*) as BFactor
FROM master..sysprocesses
WHERE spid > 50
GROUP BY
convert(varchar(50), program_name)
ORDER BY score DESC