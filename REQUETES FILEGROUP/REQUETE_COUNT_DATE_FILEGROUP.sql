--select distinct (fg.name), cast (rv.value as date )as value
--select count (distinct (tb.name)),fg.name,cast (rv.value as date )as value
select distinct (tb.name)
,case when tb.name like 'f_%' then  'SELECT '''+tb.name +''',count(*),YEAR (SID_DATE),month (SID_DATE)  FROM dwh.'+tb.name+' where sid_date <=''20131231'' group by YEAR (sid_date),month (sid_date) ' 
else 'SELECT '''+tb.name +''', count(*),YEAR (commercialdate),month (commercialdate)  FROM ods.'+tb.name+' where commercialdate <=''20131231'' group by YEAR (commercialdate),month (commercialdate) '   end as tt
--,f.type_desc as [Type]
    --, f.name as [FileName]
    ,fg.name as [FileGroup]
    --,f.physical_name as [Path]
 --   ,f.size / 128 as [CurrentSizeGB]
 --   ,convert(int,fileproperty(f.name,'SpaceUsed'))/128 as SpaceUsed
	--,f.size / 128 - convert(int,fileproperty(f.name,'SpaceUsed'))/128 as [FreeSpaceMb]
	,cast (rv.value as date )as value
	,rows
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
where fg.name in ('SID_PRD_DWH_FG_02',
'SID_PRD_ODS_FG02')
and ix.index_id >0
and rows >0
--and tb.name='PIQ_STOCK_DETAIL'
and cast (rv.value as date )  between '2012-01-01' and '2014-12-31'
--group by cast (rv.value as date ) ,fg.name,tb.name,f.name,f.physical_name
--order by cast (rv.value as date ) 
order by 5 