SELECT distinct (OBJECT_NAME(p.object_id)) AS ObjectName ,
 --i.name AS IndexName ,
 --p.index_id AS IndexID ,
 ds.name AS PartitionScheme ,
 p.partition_number AS PartitionNumber ,
 fg.name AS FileGroupName ,
 cast (prv_left.value as date) AS LowerBoundaryValue ,
 cast (prv_right.value as date) AS UpperBoundaryValue ,
 CASE pf.boundary_value_on_right
 WHEN 1 THEN 'RIGHT'
 ELSE 'LEFT'
 END AS PartitionFunctionRange ,
 p.rows AS Rows
FROM sys.partitions AS p
 INNER JOIN sys.indexes AS i ON i.object_id = p.object_id
 AND i.index_id = p.index_id
 INNER JOIN sys.data_spaces AS ds ON ds.data_space_id = i.data_space_id
 INNER JOIN sys.partition_schemes AS ps ON ps.data_space_id = ds.data_space_id
 INNER JOIN sys.partition_functions AS pf ON pf.function_id = ps.function_id
 INNER JOIN sys.destination_data_spaces AS dds ON dds.partition_scheme_id = ps.data_space_id
 AND dds.destination_id = p.partition_number
 INNER JOIN sys.filegroups AS fg ON fg.data_space_id = dds.data_space_id
 LEFT OUTER JOIN sys.partition_range_values AS prv_left ON ps.function_id = prv_left.function_id
 AND prv_left.boundary_id = p.partition_number- 1
 LEFT OUTER JOIN sys.partition_range_values AS prv_right ON ps.function_id = prv_right.function_id
 AND prv_right.boundary_id = p.partition_number
--WHERE p.object_id = OBJECT_ID('SEM_TICKET');
where   cast (prv_right.value as date)<= '20131231'
and p.rows=0
order by 4

SELECT distinct (OBJECT_NAME(p.object_id)) AS ObjectName ,
 --i.name AS IndexName ,
 --p.index_id AS IndexID ,
 ds.name AS PartitionScheme ,
 p.partition_number AS PartitionNumber ,
 fg.name AS FileGroupName ,
 cast (prv_left.value as date) AS LowerBoundaryValue ,
 cast (prv_right.value as date) AS UpperBoundaryValue ,
 CASE pf.boundary_value_on_right
 WHEN 1 THEN 'RIGHT'
 ELSE 'LEFT'
 END AS PartitionFunctionRange ,
 p.rows AS Rows
FROM sys.partitions AS p
 INNER JOIN sys.indexes AS i ON i.object_id = p.object_id
 AND i.index_id = p.index_id
 INNER JOIN sys.data_spaces AS ds ON ds.data_space_id = i.data_space_id
 INNER JOIN sys.partition_schemes AS ps ON ps.data_space_id = ds.data_space_id
 INNER JOIN sys.partition_functions AS pf ON pf.function_id = ps.function_id
 INNER JOIN sys.destination_data_spaces AS dds ON dds.partition_scheme_id = ps.data_space_id
 AND dds.destination_id = p.partition_number
 INNER JOIN sys.filegroups AS fg ON fg.data_space_id = dds.data_space_id
 LEFT OUTER JOIN sys.partition_range_values AS prv_left ON ps.function_id = prv_left.function_id
 AND prv_left.boundary_id = p.partition_number- 1
 LEFT OUTER JOIN sys.partition_range_values AS prv_right ON ps.function_id = prv_right.function_id
 AND prv_right.boundary_id = p.partition_number
--WHERE p.object_id = OBJECT_ID('SEM_TICKET');
where   cast (prv_right.value as date)<= '20131231'
and p.rows>0
order by 4

SELECT distinct (OBJECT_NAME(p.object_id)) AS ObjectName ,
 --i.name AS IndexName ,
 --p.index_id AS IndexID ,
 ds.name AS PartitionScheme ,
 p.partition_number AS PartitionNumber ,
 fg.name AS FileGroupName ,
 cast (prv_left.value as date) AS LowerBoundaryValue ,
 cast (prv_right.value as date) AS UpperBoundaryValue ,
 CASE pf.boundary_value_on_right
 WHEN 1 THEN 'RIGHT'
 ELSE 'LEFT'
 END AS PartitionFunctionRange ,
 p.rows AS Rows
FROM sys.partitions AS p
 INNER JOIN sys.indexes AS i ON i.object_id = p.object_id
 AND i.index_id = p.index_id
 INNER JOIN sys.data_spaces AS ds ON ds.data_space_id = i.data_space_id
 INNER JOIN sys.partition_schemes AS ps ON ps.data_space_id = ds.data_space_id
 INNER JOIN sys.partition_functions AS pf ON pf.function_id = ps.function_id
 INNER JOIN sys.destination_data_spaces AS dds ON dds.partition_scheme_id = ps.data_space_id
 AND dds.destination_id = p.partition_number
 INNER JOIN sys.filegroups AS fg ON fg.data_space_id = dds.data_space_id
 LEFT OUTER JOIN sys.partition_range_values AS prv_left ON ps.function_id = prv_left.function_id
 AND prv_left.boundary_id = p.partition_number- 1
 LEFT OUTER JOIN sys.partition_range_values AS prv_right ON ps.function_id = prv_right.function_id
 AND prv_right.boundary_id = p.partition_number
--WHERE p.object_id = OBJECT_ID('SEM_TICKET');
--where   cast (prv_left.value as date)<'20131231'
where fg.name='SID_PRD_ODS_FG01'
order by 4