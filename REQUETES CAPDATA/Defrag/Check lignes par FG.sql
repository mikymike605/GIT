select  distinct SCHEMA_NAME(​o.​schema_id)​+'.​'+OBJECT_NAME(​i.​object_id)​ as Objet,
        p.partition_number as Partition,
        fg.name as GroupeFichiers,
        p.rows as NbrLignes--,
from    sys.partitions p
join    sys.indexes i on p.object_id = i.object_id and p.index_id = i.index_id
join    sys.objects o ON o.object_id = p.object_id
join    sys.partition_schemes ps on ps.data_space_id = i.data_space_id
join    sys.partition_functions pf on pf.function_id = ps.function_id
join    sys.destination_data_spaces dds on dds.partition_scheme_id = ps.data_space_id and dds.destination_id = p.partition_number
join    sys.filegroups fg on fg.data_space_id = dds.data_space_id
left outer join sys.partition_range_values prv on prv.function_id =
ps.function_id and p.partition_number = prv.boundary_id
where o.object_id = OBJECT_ID(​'ODS..ODS_Invoice2')​
--and p.rows >0
