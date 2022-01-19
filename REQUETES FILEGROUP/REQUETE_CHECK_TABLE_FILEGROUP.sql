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
--INNER JOIN [sys].[filegroups] f
--    ON f.[data_space_id] = ind.[data_space_id]
--where FILEGROUP_NAME(AU.data_space_id)in ('primary')
where (OBJECT_NAME(Parti.object_id)) like '%TICKET_UNIFIE%'
and FILEGROUP_NAME(AU.data_space_id) like 'SID_PRD_ODS_FG%'
and ind.name like 'IX_DATE_ID_UNIQUE'
--and OBJECT_NAME(Parti.object_id) is not null
--and AU.total_pages/128 >0 
--and partition_id=72057594751614976
ORDER BY 2


select o.name,i.name,partition_id,partition_number, [rows]
from sys.partitions p 
inner join sys.objects o on o.object_id=p.object_id
inner join sys.indexes i on i.object_id=o.object_id
and p.index_id=i.index_id
where o.name like 'F_RESTAURANT'
--and partition_id=72057594109231104
and i.name is null


select ps.name,pf.name,boundary_id,value ,*
from sys.partition_schemes ps
join sys.partition_functions pf on pf.function_id=ps.function_id
join sys.partition_range_values prf on pf.function_id=prf.function_id


SELECT * FROM sys.partitions
where partition_id=72057594751614976
