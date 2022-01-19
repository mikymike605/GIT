if object_id('tempdb..#Table') is not null drop table #Table;  

SELECT distinct tb.name
--,ISNULL(quotename(ix.name),'Heap') as IndexName 
--,ix.type_desc as type
--,convert (varchar(50), prt.partition_number)as partition_number
--,prt.data_compression_desc
--,ps.name as PartitionScheme
--,pf.name as PartitionFunction
,fg.name as FilegroupName
,cast (rv.value as date )as value
,case when ix.index_id < 2 then prt.rows else 0 END as Rows
,au.TotalMB
,au.UsedMB
--,case when pf.boundary_value_on_right = 1 then 'less than' when pf.boundary_value_on_right is null then '' else 'less than or equal to' End as Comparison
--,CASE 
--WHEN left (fg.name,15) like 'SID_PRD_DWH_FG_%' then 'SID_PRD_DWH_FG_' else 'SID_PRD_ODS_FG' end as filegr 
--,left (fg.name,14) as FileGroup
--,cast (rv.value as date )as value
--,DATEADD(MONTH, 1, EOMONTH(GETDATE(), -2)) as totot
--INTO #Table
FROM sys.partitions prt
inner join sys.indexes ix on ix.object_id = prt.object_id and ix.index_id = prt.index_id
inner join sys.data_spaces ds on ds.data_space_id = ix.data_space_id inner join sys.tables tb on tb.object_id=prt.object_id
left join sys.partition_schemes ps on ps.data_space_id = ix.data_space_id
left join sys.partition_functions pf on pf.function_id = ps.function_id
left join sys.partition_range_values rv on rv.function_id = pf.function_id AND rv.boundary_id = prt.partition_number
left join sys.destination_data_spaces dds on dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = prt.partition_number
left join sys.filegroups fg on fg.data_space_id = ISNULL(dds.data_space_id,ix.data_space_id)
inner join (select str(sum(total_pages)*8./1024,10,2) as [TotalMB]
,str(sum(used_pages)*8./1024,10,2) as [UsedMB]
,container_id
from sys.allocation_units
group by container_id) au
on au.container_id = prt.partition_id
--where cast (rv.value as date )<= '2018-01-31'
and rows >0
and case when ix.index_id < 2 then prt.rows else 0 END  >0
--and  prt.OBJECT_ID =  object_id(N'DWH.F_RESTAURANT')
--where fg.name not in ('PRIMARY')
and fg.name in  ('SID_PRD_ODS_FG15','SID_PRD_ODS_FG16','SID_PRD_ODS_FG17','SID_PRD_ODS_FG18')
--and prt.partition_number=1
--where tb.name in ('PIQ_STOCK')
--and tb.name like  ('F_RESTAURANT%' )
order by 2,4 


