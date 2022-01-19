/*
SCRIPT controle par table l'utilité des index avant delete
*/
SELECT 
    QUOTENAME(s.name) + '.' + QUOTENAME(t.name) AS TableName,
    i.name AS IdxName,
    i.type_desc AS IdxType,
    ius.user_seeks,
    (ius.user_seeks*1.) / NULLIF((ius.user_seeks+ius.user_scans+ius.user_lookups),0) AS [%Seek],
    ius.user_scans,
    (ius.user_scans*1.) / NULLIF((ius.user_seeks+ius.user_scans+ius.user_lookups),0) AS [%Scan],
    ius.user_lookups,
    (ius.user_lookups*1.) / NULLIF((ius.user_seeks+ius.user_scans+ius.user_lookups),0) AS [%Lookup],
    ius.user_updates
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats ius ON  ius.object_id = i.object_id
        AND ius.index_id = i.index_id  AND database_id = DB_ID()--Current DB
INNER JOIN sys.tables t ON t.object_id = i.object_id
INNER JOIN sys.schemas s  ON t.schema_id = s.schema_id
WHERE t.type = 'U'
    AND t.is_ms_shipped = 0
	--and t.name like 'SHP_BK_SHAREPOINT_MENU'
ORDER BY ius.user_seeks + ius.user_scans + ius.user_lookups DESC

/*
SCRIPT DELETE INDEX INUTILES
*/
SELECT 'DROP INDEX '+SCHEMA_NAME ( schema_id )+'.'+OBJECT_NAME(dm_db_index_usage_stats.object_id)+'.'+indexes.name AS Drop_Index
, OBJECT_NAME(dm_db_index_usage_stats.object_id)
, user_seeks
, user_scans
, user_lookups
, user_updates
FROM sys.dm_db_index_usage_stats
    INNER JOIN sys.objects ON dm_db_index_usage_stats.OBJECT_ID = objects.OBJECT_ID
    INNER JOIN sys.indexes ON indexes.index_id = dm_db_index_usage_stats.index_id AND dm_db_index_usage_stats.OBJECT_ID = indexes.OBJECT_ID
WHERE indexes.is_primary_key = 0 --This line excludes primary key constarint
    AND indexes. is_unique = 0 --This line excludes unique key constarint
    AND dm_db_index_usage_stats.user_updates <> 0 -- This line excludes indexes SQL Server hasn’t done any work with
    AND dm_db_index_usage_stats. user_lookups = 0
    AND dm_db_index_usage_stats.user_seeks = 0
    AND dm_db_index_usage_stats.user_scans = 0
	and indexes.name is not null
	--and indexes.name like '%F_PRODUC%'
ORDER BY --dm_db_index_usage_stats.user_updates DESC
	1
	--DROP INDEX F_PRODUCT_MONTH.IX_F_PRODUCT_ID_YEAR_ID_MONTH_SIMPLE


	SELECT @@version 