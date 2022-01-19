SELECT
FILEGROUP_NAME(AU.data_space_id) AS FileGroupName,
 (OBJECT_NAME(Parti.object_id)) AS TableName,
ind.name AS ClusteredIndexName,
AU.total_pages/128 AS TotalTableSizeInMB,
AU.used_pages/128 AS UsedSizeInMB,
AU.data_pages/128 AS DataSizeInMB
FROM sys.allocation_units AS AU
INNER JOIN sys.partitions AS Parti ON AU.container_id = CASE WHEN AU.type in(1,3) THEN Parti.hobt_id ELSE Parti.partition_id END
LEFT JOIN sys.indexes AS ind ON ind.object_id = Parti.object_id AND ind.index_id = Parti.index_id
INNER JOIN [sys].[filegroups] f
    ON f.[data_space_id] = ind.[data_space_id]
where FILEGROUP_NAME(AU.data_space_id)not in ('primary')
--where (OBJECT_NAME(Parti.object_id)) like '%ADO_ACH%'
and OBJECT_NAME(Parti.object_id) is not null
--and AU.total_pages/128 >0 
--and partition_id=72057594751614976
ORDER BY 2