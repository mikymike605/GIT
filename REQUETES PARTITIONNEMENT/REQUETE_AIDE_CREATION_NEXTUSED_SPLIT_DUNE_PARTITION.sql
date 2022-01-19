/*
-------------------------------------------------------------------------------------------
---------------------------------1. Merge--------------------------------------------------
-------------------------------------------------------------------------------------------
ALTER PARTITION FUNCTION FCT_SID_DEV_ODS_DATE () MERGE RANGE ('20180831')
GO
-------------------------------------------------------------------------------------------
---------------------------------2. Next USED----------------------------------------------
-------------------------------------------------------------------------------------------
--/* Add the filegroup into the scheme by setting it NEXT USED */
ALTER PARTITION SCHEME [SCH_SID_DEV_ODS_DATE] NEXT USED [FG_SID_DEV_2_ODS_DATE_27]; 
GO 
-------------------------------------------------------------------------------------------
---------------------------------3. Split Range Last Range---------------------------------
-------------------------------------------------------------------------------------------
--/* Then we can SPLIT */
ALTER PARTITION FUNCTION [FCT_SID_DEV_ODS_DATE] () SPLIT RANGE ('2018-09-30T00:00:00.000');
GO
*/
-------------------------------------------------------------------------------------------
---------------------------------3. VERIFIER DATE PAR FUNCTION PARTITION-------------------
-------------------------------------------------------------------------------------------
/*
SELECT distinct (YEAR(CommercialDate))YEAR,MONTH(CommercialDate)MONTH,count(*)ROWS
 from ODS.MD5_INVOICE 
where $partition.FCT_SID_PRD_ODS_DATE(commercialdate)>=1
group by (YEAR(CommercialDate)),MONTH(CommercialDate)
order by 1,2

SELECT distinct (YEAR(CommercialDate))YEAR,MONTH(CommercialDate)MONTH,count(*)ROWS
 from ODS.MD5_INVOICE 
where $partition.FCT_SID_DEV_2_DWH_DATE(commercialdate)>=1
group by (YEAR(CommercialDate)),MONTH(CommercialDate)
order by 1,2

*/
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------PARTIONNNEMENT-------------------------ANALYSE DU DERNIER FILEGROUP--------------------------------------------------------------------------------
-------SELECT * from ODS.ADO_ARTICLE where $partition.FCT_SID_PRD_ODS_DATE(commercialdate)=17-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
where fg.name like ('SID_PRD_ODS%')
--where tb.name like 'PIQ_STOCK'
and case when ix.index_id < 2 then prt.rows else 0 END  >0
--and fg.name = 'primary'
--order by value desc 
--order by  FileGroup desc --,TotalMB desc,
ORDER BY Rows -- desc 



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
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------CHECK DES SCHEMA ET FUNCTION DE PARTITION D'UNE DB--------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select ps.name,pf.name,boundary_id,value
from sys.partition_schemes ps
join sys.partition_functions pf on pf.function_id=ps.function_id
join sys.partition_range_values prf on pf.function_id=prf.function_id
--where value > '20180101'
order by boundary_id

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------CHECK PAR TABLE DE LA PARTITION D'UNE DB AVEC LE NOMBRES DE LIGNES PAR PARTITION--------------------------------------------------------------------------------
-----------------------'ALTER PARTITION SCHEME '+PartitionScheme+' NEXT USED '+FileGr++partition_number+' ;-------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------'(db_id('SID_PRD'), OBJECT_ID('ODS.SEM_TICKET'), '1', '1', 'limited')'--------------------------------------------------------------------------------------------------------------------------------------------------

--select 'SELECT * FROM sys.dm_db_index_physical_stats (db_id(''SID_PRD''), OBJECT_ID(''ODS.'+o.name+'''),'+cast (i.index_id as varchar)+','+cast (partition_number as varchar)+',''limited'') where avg_fragmentation_in_percent >30 union ' toto
select o.name,i.name, partition_id,[rows] 
from sys.partitions p
inner join sys.objects o on o.object_id=p.object_id
inner join sys.indexes i on i.object_id=o.object_id and p.index_id=i.index_id
where o.name like 'PIQ_STOCK' --TICKET_UNIFIE, SEM_TICKET, MD5_INVOICE_DETAIL, MD5_INVOICE, F_PRODUCT, F_PRODUCT_TIMESLOT, 
--and rows >0

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------CREATION DYNAMIC DU PROCHAIN FILEGROUP AVEC NEXT USED & SPLIT DE LA PARTITION--------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select distinct (fg.name), cast (rv.value as date )as value
FROM sys.partitions prt
inner join sys.indexes ix on ix.object_id = prt.object_id and ix.index_id = prt.index_id
inner join sys.data_spaces ds on ds.data_space_id = ix.data_space_id 
inner join sys.tables tb on tb.object_id=prt.object_id
left join sys.partition_schemes ps on ps.data_space_id = ix.data_space_id
left join sys.partition_functions pf on pf.function_id = ps.function_id
left join sys.partition_range_values rv on rv.function_id = pf.function_id AND rv.boundary_id = prt.partition_number
left join sys.destination_data_spaces dds on dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = prt.partition_number
left join sys.filegroups fg on fg.data_space_id = ISNULL(dds.data_space_id,ix.data_space_id)
where fg.name like ('SID_PRD_DWH_FG%')
order by value desc 

select ps.name,pf.name,boundary_id,value
from sys.partition_schemes ps
join sys.partition_functions pf on pf.function_id=ps.function_id
join sys.partition_range_values prf on pf.function_id=prf.function_id
--where pf.name like 'SID_PRD_ODS_FG29'
order by value desc 

if object_id('tempdb..#Table') is not null drop table #Table;  

SELECT distinct tb.name
--,ISNULL(quotename(ix.name),'Heap') as IndexName 
--,ix.type_desc as type
,convert (varchar(50), prt.partition_number)as partition_number
,prt.data_compression_desc
,ps.name as PartitionScheme
,pf.name as PartitionFunction
,fg.name as FilegroupName
,cast (rv.value as date )as value
,case when ix.index_id < 2 then prt.rows else 0 END as Rows
,au.TotalMB
,au.UsedMB
,case when pf.boundary_value_on_right = 1 then 'less than' when pf.boundary_value_on_right is null then '' else 'less than or equal to' End as Comparison
,CASE 
WHEN left (fg.name,15) like 'SID_PRD_DWH_FG_%' then 'SID_PRD_DWH_FG_' else 'SID_PRD_ODS_FG' end as filegr 
,left (fg.name,14) as FileGroup
--,cast (rv.value as date )as value
,DATEADD(MONTH, 1, EOMONTH(GETDATE(), -2)) as totot
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
where cast (rv.value as date ) >= '20131231'
--and rows >0
and case when ix.index_id < 2 then prt.rows else 0 END  >0
--WHERE prt.OBJECT_ID = object_id(N'ods.md5_TAX')
--where fg.name not in ('PRIMARY')
--where fg.name in ('SID_PRD_ODS_FG03','SID_PRD_ODS_FG02','SID_PRD_ODS_FG01','SID_PRD_ODS_FG05'
--,'SID_PRD_ODS_FG06'
--,'SID_PRD_ODS_FG07'
--,'SID_PRD_ODS_FG08')
--and prt.partition_number=1
--where tb.name in ('PIQ_STOCK')
--and tb.name not in ('SEM_TICKET','SEM_V2_TLOG_SALE_TENDERS','SEM_V2_TLOG_SALE_PRODUCTS' )
order by value desc 

SELECT 'ALTER PARTITION SCHEME '+PartitionScheme+' NEXT USED '+FileGr++partition_number+' ;
ALTER PARTITION FUNCTION  '+PartitionFunction+' () SPLIT RANGE ('''+convert (nvarchar (40),totot)+''') '
FROM #Table
where PartitionScheme is not null
and value is null
--DROP TABLE #Table
--SELECT 'ALTER PARTITION FUNCTION  '+PartitionFunction+' () MERGE RANGE ('+convert (nvarchar (40),value)+');'
--FROM #Table
--where PartitionScheme is not null
--and value is null
--DROP TABLE #Table

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------SUPRESSIONO FUNCTION PARTION MERGE-------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

alter table ODS.PIQ_STOCK SWITCH PARTITION [PRIMARY]

--ALTER PARTITION FUNCTION FCT_SID_PRD_DWH_DATE () MERGE RANGE ('2018-02-28 00:00:00.000')
--GO


----SELECT min (commercialdate) FROM SID_PRD.ODS.PIQ_STOCK_DETAIL

----/* Add the filegroup into the scheme by setting it NEXT USED */
--ALTER PARTITION SCHEME [SCH_SID_PRD_ODS_DATE] NEXT USED [SID_PRD_ODS_FG19]; 
--GO 
----/* Then we can SPLIT */
--ALTER PARTITION FUNCTION [FCT_SID_PRD_ODS_DATE] () SPLIT RANGE ( '2018-02-28 00:00:00.000' );
--GO

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------CREATION D'UN FILEGROUP SUR LE SERVEUR--------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Exemple : --ALTER PARTITION SCHEME SCH_SID_PRD_DWH_DATE NEXT USED SID_PRD_DWH_FG_18 ;
--ALTER PARTITION FUNCTION  FCT_SID_PRD_DWH_DATE () SPLIT RANGE ('2018-02-28')

/* OK, let's add that boundary point back and give it a non-primary FG */
/* Create the filegroup and give it a file... */
ALTER DATABASE SID_PRD add FILEGROUP [SID_PRD_DWH_FG_17];
GO

ALTER DATABASE SID_PRD add FILE (
    NAME = SID_PRD_DWH_FG_17, FILENAME = 'H:\DATA\SID_PRD_DWH_FG_17.ndf', SIZE = 5MB, FILEGROWTH = 1MB  
) TO FILEGROUP [SID_PRD_DWH_FG_17];
GO