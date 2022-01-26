;with SpaceInfo(ObjectId, IndexId, TableName, IndexName
    ,Rows, TotalSpaceGB, UsedSpaceGB)
as
( select t.object_id as [ObjectId]
        ,i.index_id as [IndexId]
        ,s.name + '.' + t.Name as [TableName]
        ,i.name as [Index Name]
        ,sum(p.[Rows]) as [Rows]
        ,sum(au.total_pages) * 8 / 1024 /1024 as [Total Space GB]
        ,sum(au.used_pages) * 8 / 1024 /1024 as [Used Space GB]
    from  sys.tables t with (nolock) 
	join sys.schemas s with (nolock) on s.schema_id = t.schema_id
    join sys.indexes i with (nolock) on  t.object_id = i.object_id
    join sys.partitions p with (nolock) on  i.object_id = p.object_id
	join sys.filegroups f with (nolock) on f.data_space_id=i.data_space_id
	 and i.index_id = p.index_id
            cross apply
            ( select sum(a.total_pages) as total_pages
                    ,sum(a.used_pages) as used_pages
                from sys.allocation_units a with (nolock)
                where p.partition_id = a.container_id 
            ) au
    where  f.name like 'PRIMAR%'
	--where t.name='TICKET_UNIFIE'
    group by t.object_id, i.index_id, s.name, t.name, i.name
)
select 
    ObjectId, IndexId, TableName, IndexName
    ,Rows, TotalSpaceGB, UsedSpaceGB
    ,TotalSpaceGB - UsedSpaceGB as [ReservedSpaceMB]
from SpaceInfo		
order by 6 desc
option (recompile)