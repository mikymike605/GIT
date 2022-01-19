--SELECT distinct (YEAR(sid_date)),MONTH(sid_date),count(*)
-- from ODS.TICKET_UNIFIE
-- where $partition.FCT_SID_PRD_DWH_DATE(sid_date)>=1 
-- and year (sid_date)=2018
--group by (YEAR(sid_date)),MONTH(sid_date)
--order by 1,2

--ALTER PARTITION FUNCTION FCT_SID_PRD_ODS_DATE () MERGE RANGE ('20180131')
--GO
---------------------------------------------------------------------------------------------
-----------------------------------2. Next USED----------------------------------------------
---------------------------------------------------------------------------------------------
----/* Add the filegroup into the scheme by setting it NEXT USED */
--ALTER PARTITION SCHEME SCH_SID_PRD_ODS_DATE NEXT USED SID_PRD_ODS_FG1; 
--GO 
---------------------------------------------------------------------------------------------
-----------------------------------3. Split Range Last Range---------------------------------
---------------------------------------------------------------------------------------------
----/* Then we can SPLIT */
--ALTER PARTITION FUNCTION SCH_SID_PRD_ODS_DATE () SPLIT RANGE ('20180131');
--GO
--*/


SELECT tb.name,
ISNULL(quotename(ix.name),'Heap') as IndexName 
,ix.type_desc as type
,prt.partition_number
,prt.data_compression_desc
,ps.name as PartitionScheme
,pf.name as PartitionFunction
,fg.name as FilegroupName
,case when ix.index_id < 2 then prt.rows else 0 END as Rows
,au.TotalMB
,au.UsedMB
,case 
when pf.boundary_value_on_right = 1 
then 'less than' 
when pf.boundary_value_on_right is null then '' else 'less than or equal to' End as Comparison
,fg.name as FileGroup
,rv.value
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
inner join (select str(sum(total_pages)*8./1024,10,2) as [TotalMB]
,str(sum(used_pages)*8./1024,10,2) as [UsedMB]
,container_id
from sys.allocation_units
group by container_id) au
on au.container_id = prt.partition_id
--WHERE prt.OBJECT_ID = object_id(N'ods.md5_TAX')
--where fg.name like ('SID_PRD_ODS_%')
--and prt.partition_number>14
where tb.name like 'TICKET_UNIFIE'
and case when ix.index_id < 2 then prt.rows else 0 END  >0
--and fg.name = 'primary'
--order by value desc 
--order by  FileGroup desc --,TotalMB desc,
ORDER BY rv.value -- desc 
