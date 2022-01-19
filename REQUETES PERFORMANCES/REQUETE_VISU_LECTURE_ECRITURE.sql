
/****

https://blog.developpez.com/sqlpro/p13175/ms-sql-server/estimation-des-io-es-en-lecture-et-ecriture-table-par-table-dune-base-sql

*****/
WITH 
idx_details AS
(
SELECT ius.object_id, ius.index_id, user_seeks, user_lookups, user_scans,
       COALESCE(INDEXPROPERTY(i.object_id, i.name, 'IndexDepth '), 0) 
          AS index_depth,
       (SELECT SUM(used_page_count) AS pages
        FROM   sys.dm_db_partition_stats AS s
        WHERE  s.object_id = ius.object_id 
          AND  s.index_id  = ius.index_id) AS page_count
FROM   sys.dm_db_index_usage_stats AS ius
       JOIN sys.indexes AS i
          ON  ius.object_id = i.object_id 
          AND ius.index_id  = i.index_id
WHERE  database_id = DB_ID()
AND    ius.index_id > 0 OR user_lookups > 0 OR user_scans > 0)  
,
TOPT AS
(
SELECT s.name AS TABLE_SCHEMA, o.name AS TABLE_NAME, 
       SUM(user_seeks + 10 * user_lookups * index_depth) + 
       SUM(user_scans * page_count) AS IO_READS_ESTIMATE,
       100.0 * (SUM(user_seeks + 10 * user_lookups * index_depth) + 
       SUM(user_scans * page_count)) / 
       SUM(NULLIF(SUM(user_seeks + 10 * user_lookups * index_depth) + 
       SUM(user_scans * page_count), 0)) OVER()  AS PERCENT_READS_ESTIMATE
FROM   idx_details AS id
       JOIN sys.objects AS o
            ON id.object_id = o.object_id
       JOIN sys.schemas AS s 
            ON s.schema_id = o.schema_id
GROUP  BY s.name, o.name
HAVING SUM(user_seeks + 10 * user_lookups * index_depth) + 
       SUM(user_scans * page_count) > 0
)
SELECT TABLE_SCHEMA, TABLE_NAME, IO_READS_ESTIMATE,
       CAST(PERCENT_READS_ESTIMATE AS DECIMAL(5, 2)) AS PERCENT_READS_ESTIMATE,
       CAST(SUM(PERCENT_READS_ESTIMATE) 
          OVER(ORDER BY PERCENT_READS_ESTIMATE DESC) AS DECIMAL(5, 2)) 
          AS CUMUL_PERCENT,
       CAST((SELECT sqlserver_start_time 
             FROM   sys.dm_os_sys_info) AS datetime2(0)) AS SINCE
FROM   TOPT
ORDER  BY IO_READS_ESTIMATE DESC;

WITH 
idx_details AS
(
SELECT ius.object_id, SUM(user_updates * 100) AS user_updates
FROM   sys.dm_db_index_usage_stats AS ius
       JOIN sys.indexes AS i
          ON ius.object_id = i.object_id AND ius.index_id = i.index_id
WHERE  database_id = DB_ID()
AND    ius.index_id  >0 
GROUP  BY ius.object_id
),
TOPT AS
(
SELECT s.name AS TABLE_SCHEMA, o.name AS TABLE_NAME, 
       user_updates AS IO_WRITES_ESTIMATE,
       100.0 * user_updates / SUM(user_updates) OVER() 
          AS PERCENT_WRITES_ESTIMATE
FROM   idx_details AS id
       JOIN sys.objects AS o
            ON id.object_id = o.object_id
       JOIN sys.schemas AS s 
            ON s.schema_id = o.schema_id
GROUP  BY s.name, o.name, user_updates
)
SELECT TABLE_SCHEMA, TABLE_NAME, IO_WRITES_ESTIMATE,
       CAST(PERCENT_WRITES_ESTIMATE AS DECIMAL(5, 2)) 
          AS PERCENT_WRITES_ESTIMATE,
       CAST(SUM(PERCENT_WRITES_ESTIMATE) 
          OVER(ORDER BY PERCENT_WRITES_ESTIMATE DESC) AS DECIMAL(5, 2)) 
          AS CUMUL_PERCENT,
       CAST((SELECT sqlserver_start_time 
             FROM   sys.dm_os_sys_info) AS datetime2(0)) AS SINCE
FROM   TOPT
ORDER  BY PERCENT_WRITES_ESTIMATE DESC;