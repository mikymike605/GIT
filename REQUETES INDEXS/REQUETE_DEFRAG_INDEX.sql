--Find out the disk size of an index:
USE [SID_PRD]
go

SELECT
OBJECT_NAME(I.OBJECT_ID) AS TableName,
I.name AS IndexName,   
8 * SUM(AU.used_pages) AS 'Index size (KB)',
CAST(8 * SUM(AU.used_pages) / 1024.0 AS DECIMAL(18,2)) AS 'Index size (MB)',
CAST(8 * SUM(AU.used_pages) / 1024.0/1024.0 AS DECIMAL(18,2)) AS 'Index size (GB)',i.index_id,P.partition_number
FROM sys.indexes I
JOIN sys.partitions P ON P.OBJECT_ID = I.OBJECT_ID AND P.index_id = I.index_id
JOIN sys.allocation_units AU ON AU.container_id = P.partition_id
WHERE OBJECT_NAME(I.OBJECT_ID) = 'MD5_PAYMENT'  
and i.index_id=0
and partition_number in (9,12,18)  
GROUP BY I.OBJECT_ID, I.name,i.index_id,p.partition_number
ORDER BY 5

select o.name,i.name,partition_id, i.index_id, partition_number,[rows]
from sys.partitions p
inner join sys.objects o on o.object_id=p.object_id
inner join sys.indexes i on i.object_id=o.object_id and p.index_id=i.index_id
where o.name like 'ADO_ARTICLe'
and rows >0
order by 6 desc 

-- Ensure a USE  statement has been executed first.
SELECT [DatabaseName]
    ,[ObjectId]
    ,[ObjectName]
    ,[IndexId]
    ,[IndexDescription]
    ,CONVERT(DECIMAL(16, 1), (SUM([avg_record_size_in_bytes] * [record_count]) / (1024.0 * 1024))) AS [IndexSize(MB)]
    ,[lastupdated] AS [StatisticLastUpdated]
    ,[AvgFragmentationInPercent]
FROM (
    SELECT DISTINCT DB_Name(Database_id) AS 'DatabaseName'
        ,OBJECT_ID AS ObjectId
        ,Object_Name(Object_id) AS ObjectName
        ,Index_ID AS IndexId
		,Index_Type_Desc AS IndexDescription
        ,avg_record_size_in_bytes
        ,record_count
        ,STATS_DATE(object_id, index_id) AS 'lastupdated'
        ,CONVERT([varchar](512), round(Avg_Fragmentation_In_Percent, 3)) AS 'AvgFragmentationInPercent'
    FROM sys.dm_db_index_physical_stats(db_id('MDMUDATA'), OBJECT_ID('Reporting.TransactionsStockPost'), null, null, 'limited')
    WHERE OBJECT_ID IS NOT NULL
        AND Avg_Fragmentation_In_Percent <> 0
    ) T
GROUP BY DatabaseName
    ,ObjectId
    ,ObjectName
    ,IndexId
    ,IndexDescription
    ,lastupdated
    ,AvgFragmentationInPercent
	order by AvgFragmentationInPercent desc

	
SELECT * FROM sys.indexes WHERE object_id=84911374

	--SELECT * FROM sys.databases


