select * from sys.objects
where type in ('U','V')
order by 1

--select 'SELECT * INTO [MD8_ARCH].['+s.name+'].['+o.name+'] FROM [SID_PRD].['+s.name+'].['+o.name+'] ',o.type,s.name,o.name,
select 8 * SUM(AU.used_pages) AS 'Index size (KB)',
CAST(8 * SUM(AU.used_pages) / 1024.0 AS DECIMAL(18,2)) AS 'Index size (MB)',
CAST(8 * SUM(AU.used_pages) / 1024.0/1024.0 AS DECIMAL(18,2)) AS 'Index size (GB)'
from sys.objects o
inner join sys.schemas s on s.schema_id=o.schema_id
inner join sys.indexes i on i.object_id=o.object_id
inner join sys.partitions P ON P.OBJECT_ID = I.OBJECT_ID AND P.index_id = I.index_id
inner join sys.allocation_units AU ON AU.container_id = P.partition_id
where o.type not in('IT')
--and o.name = 'DIM_EXPLOITATION'
GROUP BY o.type,s.name,o.name
order by 4

SELECT *
--OBJECT_NAME(I.OBJECT_ID) AS TableName,
--I.name AS IndexName,   
--8 * SUM(AU.used_pages) AS 'Index size (KB)',
--CAST(8 * SUM(AU.used_pages) / 1024.0 AS DECIMAL(18,2)) AS 'Index size (MB)',
--CAST(8 * SUM(AU.used_pages) / 1024.0/1024.0 AS DECIMAL(18,2)) AS 'Index size (GB)'
--,i.index_id,P.partition_number
FROM sys.indexes I
JOIN sys.partitions P ON P.OBJECT_ID = I.OBJECT_ID AND P.index_id = I.index_id
JOIN sys.allocation_units AU ON AU.container_id = P.partition_id
JOIN sys.objects o on o.object_id=i.object_id
--where o.type='V'
--WHERE OBJECT_NAME(I.OBJECT_ID) = 'TICKET_UNIFIE'  
--and i.index_id in (2,23,39)
--and partition_number in (17)  
--GROUP BY I.OBJECT_ID, I.name,i.index_id,p.partition_number
ORDER BY i.index_id,p.partition_number