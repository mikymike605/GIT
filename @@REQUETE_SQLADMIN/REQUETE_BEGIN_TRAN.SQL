/************ CREATE LOCK  ************/

BEGIN TRANSACTION 

UPDATE [DBAtools].[dbo].[BlitzFirst_WaitStats_Archive]
SET ServerName='AUBFRCXSQL2'

COMMIT



/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [DBAtools].[dbo].[BlitzFirst_WaitStats_Archive]
  
  
/************ QUERY LOCK  ************/
  
DECLARE @DUREE_MAX int =(
SELECT A.wait_duration_s
FROM (
SELECT   w.session_id
,w.wait_duration_ms /1000 wait_duration_s
,w.wait_type
,w.blocking_session_id
,w.resource_description
,s.program_name
,t.text
,t.dbid
,s.cpu_time
,s.memory_usage
FROM sys.dm_os_waiting_tasks w
INNER JOIN sys.dm_exec_sessions s
ON w.session_id = s.session_id
INNER JOIN sys.dm_exec_requests r
ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text (r.sql_handle) t
WHERE s.is_user_process = 1
and w.wait_type like 'LCK%') A)
--and w.wait_duration_ms/1000> )

--SELECT @DUREE_MAX = 
PRINT @DUREE_MAX

--IF @DUREE_MAX between  300 and 599
--   RAISERROR ('4',16,1);
-- IF @DUREE_MAX >= 600
--  RAISERROR ('3',16,1);
   