select cast (deqs.last_execution_time as smalldatetime)
         , count (dest.TEXT) AS [Count_Query]
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
--where CAST(deqs.last_execution_time AS smalldatetime)>='20181213 15:25:00'
group by (dest.TEXT),cast (deqs.last_execution_time as smalldatetime) 
--having count (dest.TEXT)>10
ORDER BY cast (deqs.last_execution_time as smalldatetime) DESC


SELECT  cast (deqs.last_execution_time as smalldatetime), count (dest.TEXT) AS [Count_Query]
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
where deqs.last_execution_time between '20181214 05:00' and '20181214 06:00'
group by (dest.TEXT), cast (deqs.last_execution_time as smalldatetime)
ORDER BY  cast (deqs.last_execution_time as smalldatetime) DESC

SELECT  cast (deqs.last_execution_time as smalldatetime), count (dest.TEXT) AS [Count_Query]
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
where deqs.last_execution_time >= '20181213 08:00'-- and '20181213 16:00'
group by (dest.TEXT) , cast (deqs.last_execution_time as smalldatetime)
ORDER BY  cast (deqs.last_execution_time as smalldatetime) DESC

SELECT CAST(deqs.last_execution_time  as date) AS ForDate,
       DATEPART(hour,deqs.last_execution_time ) AS OnHour,
       COUNT(*) AS Totals
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
GROUP BY CAST(deqs.last_execution_time as date),
       DATEPART(hour,deqs.last_execution_time)
	   ORDER BY  cast (deqs.last_execution_time as date) DESC,  DATEPART(hour,deqs.last_execution_time ) desc