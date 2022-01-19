/********************************************************************************************************************************************************************/
/************************************************************SQL Server: Script to find Missing Indexes**************************************************************/
/********************************************************************************************************************************************************************/
SELECT TOP 25 'MISSING INDEXS',
	 ROUND(DMIGS.avg_total_user_cost * DMIGS.avg_user_impact * (DMIGS.user_seeks + DMIGS.user_scans),0) AS TotalCost
	 ,DMID.[statement] AS TableName
	 ,equality_columns
	 ,inequality_columns
	 ,included_columns
FROM sys.dm_db_missing_index_groups AS DMIG
INNER JOIN sys.dm_db_missing_index_group_stats AS DMIGS
	ON DMIGS.group_handle = DMIG.index_group_handle
INNER JOIN sys.dm_db_missing_index_details AS DMID
	ON DMID.index_handle = DMIG.index_handle
	where DMID.[statement]  = '[SID_DEV].[SAS].[REB_PAYMENT]'
ORDER BY 1 DESC
/********************************************************************************************************************************************************************/
/*******************************************************SQL Server: Script to find Unused Indexes of Database********************************************************/
/********************************************************************************************************************************************************************/
SELECT 'UNUSED INDEXS',
	OBJECT_NAME(i.OBJECT_ID) AS ObjectName
	,i.name AS UnusedIndexName	
	,8 * SUM(au.used_pages) AS IndexSizeInKB
	,CASE
		WHEN i.type= 0 THEN 'Heap'  
		WHEN i.type= 1 THEN 'Clustered' 
		WHEN i.type=2 THEN 'Non-Clustered'   
		WHEN i.type=3 THEN 'XML'   
		WHEN i.type=4 THEN 'Spatial'  
		WHEN i.type=5 THEN 'Clustered columnstore index'   
		WHEN i.type=6 THEN 'Nonclustered columnstore index'  
		WHEN i.type=7 THEN 'Nonclustered hash index.'
	END index_type
	,'DROP INDEX ' + i.name + ' ON ' + OBJECT_NAME(i.OBJECT_ID) AS DropStatement
FROM sys.indexes AS i 
LEFT JOIN sys.dm_db_index_usage_stats AS dius 
	ON dius.OBJECT_ID = i.OBJECT_ID 
		AND i.index_id = dius.index_id 
		AND dius.database_id = DB_ID() 
INNER JOIN sys.partitions AS p 
	ON p.OBJECT_ID = i.OBJECT_ID 
		AND p.index_id = i.index_id 
INNER JOIN sys.allocation_units AS au 
	ON au.container_id = p.partition_id 
WHERE OBJECTPROPERTY(i.OBJECT_ID, 'IsIndexable') = 1 
	AND OBJECTPROPERTY(i.OBJECT_ID, 'IsIndexed') = 1 
	AND dius.index_id IS NULL
	OR (dius.user_updates > 0 
		AND dius.user_seeks = 0 
		AND dius.user_scans = 0 
		AND dius.user_lookups = 0)
--AND OBJECT_NAME(i.OBJECT_ID)='TICKET_UNIFIE_ARCHIVE'
GROUP BY OBJECT_NAME(i.OBJECT_ID), i.name, i.type 
--ORDER BY OBJECT_NAME(i.OBJECT_ID) 
order by 3 desc 
/********************************************************************************************************************************************************************/
/*******************************************************SQL Server: Script to find Duplicate Indexes********************************************************/
/********************************************************************************************************************************************************************/
SELECT 'DUPLICATED INDEXS',
s.Name + '.' + t.Name AS TableName
,i.name AS IndexName1
,DupliIDX.name AS DuplicateIndexName
,'DROP INDEX '+s.name+'.' + DupliIDX.name + ' ON ' + OBJECT_NAME(i.OBJECT_ID) AS DropStatement
,'DROP INDEX ' + i.name + ' ON ' + OBJECT_NAME(i.OBJECT_ID) AS DropStatement
,c.name AS ColumnName
FROM sys.tables AS t
JOIN sys.indexes AS i
ON t.object_id = i.object_id -- index belongs to this table
JOIN sys.index_columns ic
ON ic.object_id = i.object_id -- columns for this index
AND ic.index_id = i.index_id -- index to which column belongs
AND ic.key_ordinal = 1 -- only want the first column in the index
JOIN sys.columns AS c
ON c.object_id = ic.object_id
AND c.column_id = ic.column_id -- to get the name of the first indexed column
JOIN sys.schemas AS s
ON t.schema_id = s.schema_id
CROSS APPLY
(
SELECT
ind.index_id
,ind.name
FROM sys.indexes AS ind
JOIN sys.index_columns AS ico
ON ico.object_id = ind.object_id
AND ico.index_id = ind.index_id
AND ico.key_ordinal = 1
WHERE ind.object_id = i.object_id
AND ind.index_id > i.index_id -- exclude the clustered index (which is the PK usually)
AND ico.column_id = ic.column_id
) DupliIDX
where t.name='TICKET_UNIFIE'
ORDER BY
s.name,t.name,i.index_id,c.column_id
GO

DROP INDEX [ClusteredIndex-20181123-114958] ON ODS.TICKET_UNIFIE