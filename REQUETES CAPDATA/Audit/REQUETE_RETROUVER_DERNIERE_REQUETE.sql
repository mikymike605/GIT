SELECT		QS.creation_time Creation,
		QS.last_execution_time LastExec,
		QS.plan_generation_num NbComp,
		QS.execution_count NbExec, 
		OBJECT_NAME(SQL.objectid) Procedures,
		SUBSTRING
		(
			SQL.text,
			QS.statement_start_offset / 2 + 1,
			(
				CASE
					WHEN QS.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(max), SQL.text)) * 2 
					ELSE QS.statement_end_offset 
				END - QS.statement_start_offset
			) / 2 + 1
		) AS Instruction
FROM sys.dm_exec_query_stats QS 
CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) SQL
order by 1 desc 