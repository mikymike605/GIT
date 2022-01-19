/*
-------------------------------------------------------------------------------------------
---------------------------------1. Merge--------------------------------------------------
-------------------------------------------------------------------------------------------
ALTER PARTITION FUNCTION [FCT_SID_PRD_DWH_DATE] () MERGE RANGE ('20180228')
GO
*/
-------------------------------------------------------------------------------------------
---------------------------------2. Next USED----------------------------------------------
-------------------------------------------------------------------------------------------
--/* Add the filegroup into the scheme by setting it NEXT USED */
ALTER PARTITION SCHEME [SCH_SID_DEV_ODS_DATE] NEXT USED [FG_SID_DEV_2_ODS_DATE_26]; 
GO 
-------------------------------------------------------------------------------------------
---------------------------------3. Split Range Last Range---------------------------------
-------------------------------------------------------------------------------------------
--/* Then we can SPLIT */
ALTER PARTITION FUNCTION [FCT_SID_DEV_ODS_DATE] () SPLIT RANGE ('2018-09-30T00:00:00.000');
GO


SELECT distinct (fg.name) as FilegroupName,value,partition_number,SCHEMA_NAME(schema_id)
,SUM (case when ix.index_id < 2 then prt.rows else 0 END) as Rows
FROM sys.partitions prt
inner join sys.indexes ix
on ix.object_id = prt.object_id and
ix.index_id = prt.index_id
inner join sys.data_spaces ds
on ds.data_space_id = ix.data_space_id inner join sys.tables tb on tb.object_id=prt.object_id
left join sys.partition_schemes ps
on ps.data_space_id = ix.data_space_id
left join sys.partition_functions pf
on pf.function_id = ps.function_id
left join sys.partition_range_values rv
on rv.function_id = pf.function_id AND
rv.boundary_id = prt.partition_number
left join sys.destination_data_spaces dds
on dds.partition_scheme_id = ps.data_space_id AND
dds.destination_id = prt.partition_number
left join sys.filegroups fg
on fg.data_space_id = ISNULL(dds.data_space_id,ix.data_space_id)
where SCHEMA_NAME(schema_id) = 'ODS'
group by fg.name, partition_number,SCHEMA_NAME(schema_id),value
ORDER BY 3 desc 

