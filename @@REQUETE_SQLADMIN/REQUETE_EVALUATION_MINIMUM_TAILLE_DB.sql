DECLARE @tr TABLE (dbname sysname,tablename sysname, indexname sysname NULL,indexid bigint,indexsizeGB int)
INSERT INTO @tr
EXEC  sp_MSforeachdb 
'USE [?];PRINT db_name();SELECT TOP 1
''?'',
OBJECT_NAME(i.OBJECT_ID) AS TableName,
i.name AS IndexName,
i.index_id AS IndexID,
(8 * SUM(a.used_pages))/1024/1024 AS ''Indexsize(GB)''
FROM sys.indexes AS i
JOIN sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id
JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
GROUP BY i.OBJECT_ID,i.index_id,i.name
order by 5 desc
---ORDER BY OBJECT_NAME(i.OBJECT_ID),i.index_id'

select @@servername,max(indexsizeGB) from @tr
