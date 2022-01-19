--select 'SELECT * FROM sys.dm_db_index_physical_stats (db_id(''SID_PRD''), OBJECT_ID(''ODS.'+o.name+'''),'+cast (i.index_id as varchar)+','+cast (partition_number as varchar)+',''limited'') 
--where avg_fragmentation_in_percent >30 union ' toto,i.index_id,p.partition_number
----select,o.name,i.name, partition_id,[rows] 
----select 'sys.dm_db_index_physical_stats (db_id(''SID_PRD''), OBJECT_ID(''ODS.'+o.name+'''),'+cast (i.index_id as varchar)+','+cast (partition_number as varchar)+',''limited'') dm_db_index_physical_stats' toto
----INTO #tmp
--from sys.partitions p
--inner join sys.objects o on o.object_id=p.object_id
--inner join sys.indexes i on i.object_id=o.object_id and p.index_id=i.index_id
--where o.name ='SEM_PLU'  --TICKET_UNIFIE, SEM_TICKET, MD5_INVOICE_DETAIL, F_PRODUCT_TIMESLOT,F_PRODUCT,MD5_INVOICE,MD5_PAYEMENT
----and rows >0
----SELECT * FROM #tmp


DECLARE @DatabaseID int

SET @DatabaseID = DB_ID()
--ALTER INDEX [IX_CLUSTER_SID_DATE] ON [SID_PRD].[DWH].[F_impriPRODUCT] REBUILD PARTITION = 1 WITH (SORT_IN_TEMPDB = OFF, ONLINE = ON)
SELECT 'ALTER INDEX ['+[indexes].[name]+  '] on ['+DB_NAME(@DatabaseID)+'].[' +SCHEMA_NAME(schemas.[schema_id])+'].['+objects.[name]+'] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = ON);',
--REBUILD PARTITION ='+cast(dm_db_index_physical_stats.partition_number as varchar)+'
DB_NAME(@DatabaseID) AS DatabaseName,
	SUM(s.[used_page_count]) * 8/1024/1024 AS IndexSizeGB,
 ddius.index_id ,
 ddius.user_seeks ,
 ddius.user_scans ,
 ddius.user_lookups ,
 ddius.user_seeks + ddius.user_scans + ddius.user_lookups AS user_reads ,       
 schemas.[name] AS SchemaName,
       objects.[name] AS ObjectName,
       indexes.[name] AS IndexName,
       objects.type_desc AS ObjectType,
       indexes.type_desc AS IndexType,
	   dm_db_index_physical_stats.Avg_Fragmentation_in_Percent,
       dm_db_index_physical_stats.partition_number AS PartitionNumber,
       dm_db_index_physical_stats.page_count AS [PageCount]
       --dm_db_index_physical_stats.avg_fragmentation_in_percent AS AvgFragmentationInPercent
--FROM sys.dm_db_index_physical_stats (db_id(), NULL, NULL, NULL, 'LIMITED') dm_db_index_physical_stats
FROM sys.dm_db_index_physical_stats (db_id('SID_PRD'), object_id('ODS.MD5_INVOICE'),1,1,'limited') dm_db_index_physical_stats
INNER JOIN sys.indexes indexes ON dm_db_index_physical_stats.[object_id] = indexes.[object_id] AND dm_db_index_physical_stats.index_id = indexes.index_id
INNER JOIN sys.objects objects ON indexes.[object_id] = objects.[object_id]
INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id]
INNER JOIN sys.dm_db_partition_stats s ON s.[object_id] = indexes.[object_id] AND s.[index_id] = indexes.[index_id]
INNER JOIN sys.dm_db_index_usage_stats ddius on indexes.[object_id]=ddius.[object_id] and objects.object_id=s.object_id and indexes.index_id=ddius.index_id
WHERE objects.[type] IN('U','V')
AND objects.is_ms_shipped = 0
AND indexes.[type] IN(1,2,3,4)
AND indexes.is_disabled = 0
AND indexes.is_hypothetical = 0
AND dm_db_index_physical_stats.alloc_unit_type_desc = 'IN_ROW_DATA'
	AND dm_db_index_physical_stats.index_level = 0
--AND dm_db_index_physical_stats.page_count >= 1500
--and avg_fragmentation_in_percent >=30
and indexes.[name] is not null
--and dm_db_index_physical_stats.partition_number >1a
--and objects.[name]='ODS.SEM_PLU_CATEGORIES'
group by  
ddius.index_id ,
 ddius.user_seeks ,
 ddius.user_scans ,
 ddius.user_lookups ,
 ddius.user_seeks + ddius.user_scans + ddius.user_lookups,
 indexes.name,schemas.schema_id
,objects.name,dm_db_index_physical_stats.partition_number
,schemas.name,objects.type_desc
,indexes.type_desc
,dm_db_index_physical_stats.avg_fragmentation_in_percent
,dm_db_index_physical_stats.page_count
--ORDER BY avg_fragmentation_in_percent desc
--ORDER BY ddius.user_scans desc ,  avg_fragmentation_in_percent desc
--order by  ddius.user_scans desc 
--order by ddius.index_id,dm_db_index_physical_stats.partition_number


--1	2
--1	8
--1	9
--1	12
----13	12
