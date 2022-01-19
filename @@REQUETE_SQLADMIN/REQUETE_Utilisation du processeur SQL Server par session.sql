DECLARE @sessionsCPU TABLE 
	(
	 session_id SMALLINT NOT NULL,
	 cpu_time INT NULL ,
	 initialCPUFlag BIT NOT NULL
	)
  
INSERT INTO @sessionsCPU
SELECT 
	 session_id
	,sum(cpu_time) as cpu_time
	,1 as initialCPUFlag
FROM sys.dm_exec_requests
WHERE session_id > 20
GROUP BY session_id
  
WAITFOR DELAY '0:00:1.0' -- define the intervel to measure high CPU consumers.
  
INSERT INTO @sessionsCPU
SELECT
	 session_id
	,sum(cpu_time) as cpu_time
	,0 as initialCPUFlag
FROM sys.dm_exec_requests
WHERE session_id > 20
GROUP BY session_id;
  
WITH total AS
(
	select
		 initialCPUFlag
		,sum(cpu_time) as cpu_time
	FROM @sessionsCPU
	GROUP BY initialCPUFlag
), 
delta AS
(
	 SELECT 
		s.cpu_time - f.cpu_time as total_cpu
	 FROM total f
	 CROSS JOIN total s
	 WHERE f.initialCPUFlag = 1
	 AND s.initialCPUFlag = 0
)  
SELECT
	 i.session_id
	,convert(numeric(5,2), (100. * (((i.cpu_time - l.cpu_time) * 1.) / (d.total_cpu * 1.)))) AS percentCPU
	,convert(char(8), getdate() - r.start_time, 108) AS run_duration
	,substring( st.text, 
				(r.statement_start_offset/2)+1,
				((CASE r.statement_end_offset
				WHEN -1 THEN datalength(st.text)
				ELSE r.statement_end_offset END - r.statement_start_offset)/2) + 1)
		AS statement_text
	,st.text AS full_query
	,s.login_name
	,s.host_name
	,s.program_name
FROM @sessionsCPU i
INNER JOIN @sessionsCPU l
	ON i.session_id = l.session_id
	AND i.initialCPUFlag = 0 AND l.initialCPUFlag = 1
INNER JOIN sys.dm_exec_requests r
	ON i.session_id = r.session_id
INNER JOIN sys.dm_exec_sessions s
	ON i.session_id = s.session_id
CROSS JOIN delta d
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
WHERE d.total_cpu <> 0
ORDER BY percentCPU DESC;