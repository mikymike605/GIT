DECLARE @MINUTES SMALLINT;
SET @MINUTES = 10; --> durée minimale en minutes depuis le démarrage de la transaction
WITH T AS
(
SELECT at.transaction_begin_time,
       DATEDIFF(SECOND, at.transaction_begin_time, GETDATE()) AS DUREE_SECONDE,
       login_time, host_name, program_name, login_name, transaction_state,
       s.cpu_time, s.total_elapsed_time, s.reads, s.writes,
       client_net_address, DB_NAME(dbid) AS DATABASE_NAME, text AS SQL_query
FROM   sys.dm_tran_active_transactions  AS at
       JOIN sys.dm_tran_session_transactions AS st
            ON at.transaction_id = st.transaction_id
       JOIN sys.dm_exec_sessions AS s
            ON st.session_id = s.session_id
       JOIN sys.dm_exec_connections AS c
            ON st.session_id = c.session_id
       LEFT OUTER JOIN sys.dm_exec_requests AS r
            ON st.session_id = r.session_id
       OUTER APPLY sys.dm_exec_sql_text(most_recent_sql_handle)
WHERE  transaction_type  = 1 -- active
  AND  transaction_state IN (2, 7) -- écriture
  AND  transaction_begin_time < DATEADD(MINUTE, -@MINUTES, GETDATE())
)
SELECT *, CAST(CAST(CAST(DUREE_SECONDE/86400 AS DATETIME) AS INT) AS VARCHAR(10)) + ' jour '
          + RIGHT(CONVERT(CHAR(24), CAST(DUREE_SECONDE/86400.0 AS DATETIME), 121), 13) AS DUREE
FROM   T
ORDER BY DUREE_SECONDE DESC;


------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*SQL SERVER – Find Most Expensive Queries Using DMV
https://blog.sqlauthority.com/2010/05/14/sql-server-find-most-expensive-queries-using-dmv/*/
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT TOP 10 SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
((CASE qs.statement_end_offset
WHEN -1 THEN DATALENGTH(qt.TEXT)
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2)+1),
qs.execution_count,
qs.total_logical_reads, qs.last_logical_reads,
qs.total_logical_writes, qs.last_logical_writes,
qs.total_worker_time,
qs.last_worker_time,
qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
qs.last_elapsed_time/1000000 last_elapsed_time_in_S,
qs.last_execution_time,
qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY qs.total_logical_reads DESC -- logical reads
-- ORDER BY qs.total_logical_writes DESC -- logical writes
-- ORDER BY qs.total_worker_time DESC -- CPU time