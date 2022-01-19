
SELECT * FROM sys.dm_db_xtp_checkpoint_files
SELECT * FROM sys.dm_db_xtp_checkpoint_stats
SELECT @@TRANCOUNT;

SELECT XACT_STATE();

SELECT name, database_id,recovery_model_desc, log_reuse_wait_desc
FROM sys.databases; 

DBCC OPENTRAN

SELECT * FROM sys.dm_tran_database_transactions

DBCC inputbuffer(87)

select percent_complete,datediff(mi,start_time,getdate())as Temps_ecoule,text 
from sys.dm_exec_requests cross apply sys.dm_exec_sql_text (sql_handle) 

SELECT * FROM sys.sysprocesses where spid >50 and waittime >0 and blocked >0
Exec sp_who2
--KILL 87
--DBCC inputbuffer(SPID)

