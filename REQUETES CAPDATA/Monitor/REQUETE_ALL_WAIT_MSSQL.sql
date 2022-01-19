SELECT st.text AS [SQL Text],
 w.session_id, 
 w.wait_duration_ms,
 w.wait_type, w.resource_address, 
 w.blocking_session_id, 
 w.resource_description FROM sys.dm_os_waiting_tasks AS w
 INNER JOIN sys.dm_exec_connections AS c ON w.session_id = c.session_id 
 CROSS APPLY (SELECT * FROM sys.dm_exec_sql_text(c.most_recent_sql_handle))
 AS st WHERE w.session_id > 50
 AND w.wait_duration_ms > 0