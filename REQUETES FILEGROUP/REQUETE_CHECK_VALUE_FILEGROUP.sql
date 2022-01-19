--select distinct (fg.name), cast (rv.value as date )as value
--select count (distinct (tb.name)),fg.name,cast (rv.value as date )as value
select distinct (tb.name)
--,f.type_desc as [Type]
    --, f.name as [FileName]
    ,fg.name as [FileGroup]
    --,f.physical_name as [Path]
 --   ,f.size / 128 as [CurrentSizeGB]
 --   ,convert(int,fileproperty(f.name,'SpaceUsed'))/128 as SpaceUsed
	--,f.size / 128 - convert(int,fileproperty(f.name,'SpaceUsed'))/128 as [FreeSpaceMb]
	,cast (rv.value as date )as value,rows
FROM sys.partitions prt
inner join sys.indexes ix on ix.object_id = prt.object_id and ix.index_id = prt.index_id
inner join sys.data_spaces ds on ds.data_space_id = ix.data_space_id 
inner join sys.tables tb on tb.object_id=prt.object_id
left join sys.partition_schemes ps on ps.data_space_id = ix.data_space_id
left join sys.partition_functions pf on pf.function_id = ps.function_id
left join sys.partition_range_values rv on rv.function_id = pf.function_id AND rv.boundary_id = prt.partition_number
left join sys.destination_data_spaces dds on dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = prt.partition_number
left join sys.filegroups fg on fg.data_space_id = ISNULL(dds.data_space_id,ix.data_space_id)
--left join sys.database_files f on f.data_space_id=fg.data_space_id 
--where fg.name in ('SID_PRD_ODS_FG03'
--,'SID_PRD_ODS_FG02'
--,'SID_PRD_ODS_FG01'
--,'SID_PRD_ODS_FG05'
--,'SID_PRD_ODS_FG06'
--,'SID_PRD_ODS_FG07'
--,'SID_PRD_ODS_FG08')
where ix.index_id >0
and rows >0
--and tb.name='PIQ_STOCK_DETAIL'
and cast (rv.value as date )  between '2012-01-01' and '2019-12-31'
--group by cast (rv.value as date ) ,fg.name,tb.name,f.name,f.physical_name
order by cast (rv.value as date ) 