USE SID_DEV
 
SELECT OBJECT_NAME(ddius.[object_id], ddius.database_id) AS [object_name] ,
 ddius.index_id ,
 ddius.user_seeks ,
 ddius.user_scans ,
 ddius.user_lookups ,
 ddius.user_seeks + ddius.user_scans + ddius.user_lookups
 AS user_reads ,
 ddius.user_updates AS user_writes ,
 ddius.last_user_scan ,
 ddius.last_user_update
 FROM sys.dm_db_index_usage_stats ddius
 WHERE ddius.database_id > 4 -- filter out system tables
 AND OBJECTPROPERTY(ddius.OBJECT_ID, 'IsUserTable') = 1
 AND ddius.index_id > 0 -- filter out heaps
 AND DB_NAME(ddius.database_id) = 'SID_DEV'
 ORDER BY ddius.user_scans DESC