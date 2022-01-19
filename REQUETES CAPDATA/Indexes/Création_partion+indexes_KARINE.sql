USE [SID_DEV]
GO


DECLARE @fg varchar(50)
DECLARE @ind int=0
DECLARE @cmd varchar(max)

----création des FG

--While @ind < 15
--BEGIN
--set @ind=@ind+1
--set @cmd = 'ALTER DATABASE [SID_DEV] ADD FILEGROUP [SID_DEV_SAS_DATA_FG'+replicate ('0', 2-len (@ind))+cast(@ind as varchar)+']'
--exec(@cmd)
--END

-- création des Fichiers

set @ind=0
While @ind < 1
BEGIN
set @ind=@ind+1
set @cmd = 'ALTER DATABASE [SID_DEV] ADD FILE ( NAME = N''SID_DEV_TEC_DATA_FG'+replicate ('0', 2-len (@ind))+cast(@ind as varchar)+''', 
FILENAME = N''D:\DATA\SID_DEV\TEC\SID_DEV_TEC_DATA_FG'+replicate ('0', 2-len (@ind))+cast(@ind as varchar)+'.ndf'' , SIZE = 5120KB , FILEGROWTH = 1024KB ) 
TO FILEGROUP [SID_DEV_TEC_DATA_FG'+replicate ('0', 2-len (@ind))+cast(@ind as varchar)+']'      
exec(@cmd)
END

--- fonction partition
CREATE PARTITION FUNCTION [FCT_SID_DEV_TEC_COMMERCIALDATE](date) AS RANGE RIGHT FOR VALUES (
'20000101'
)
--- Schéma pzrtition
CREATE PARTITION SCHEME [SCH_SID_DEV_TEC_COMMERCIALDATE] AS PARTITION [FCT_SID_DEV_TEC_COMMERCIALDATE] TO (
'SID_DEV_TEC_DATA','SID_DEV_TEC_DATA_FG01'
)
--
-- partitionner la table
---
ALTER TABLE [dbo].[ODS_InvoiceDetail2] ADD  CONSTRAINT [PK_ODS_InvoiceDetail2] PRIMARY KEY CLUSTERED 
(
	[Commercialdate] ASC,
	[InvoiceId] ASC,
	[Number] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
ON [SHEMA_PARTITION_Commercialdate]([Commercialdate])
GO


------ACTIVATION DES VERROU NIVEAU PARTION----------------
ALTER TABLE [ODS].[dbo].[ODS_InvoiceDetail2] SET (LOCK_ESCALATION = AUTO)



---
--- Locks niveau partitions
-----
--ALTER TABLE TableName SET (LOCK_ESCALATION = AUTO);   --- TABLE pour revenir au default
----
---- lister la taille des partitions
-----
select * from sys.partitions where object_id =OBJECT_ID(?'Sales.?SalesOrderDetail_P')?;?
select  distinct SCHEMA_NAME(?o.?schema_id)?+'.?'+OBJECT_NAME(?i.?object_id)? as
Objet,
        p.partition_number as Partition,
        fg.name as GroupeFichiers,
        p.rows as NbrLignes--,
from    sys.partitions p
join    sys.indexes i on p.object_id = i.object_id and p.index_id =
i.index_id
join    sys.objects o ON o.object_id = p.object_id
join    sys.partition_schemes ps on ps.data_space_id = i.data_space_id
join    sys.partition_functions pf on pf.function_id = ps.function_id
join    sys.destination_data_spaces dds on dds.partition_scheme_id =
ps.data_space_id and dds.destination_id = p.partition_number
join    sys.filegroups fg on fg.data_space_id = dds.data_space_id
left outer join sys.partition_range_values prv on prv.function_id =
ps.function_id and p.partition_number = prv.boundary_id
where o.object_id = OBJECT_ID(?'ODS..ODS_Invoice2')?







