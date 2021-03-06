USE DB_FG_PARTITION
GO


DECLARE @fg varchar(50)
DECLARE @ind int=0
DECLARE @cmd varchar(max)

 ------création des FG

While @ind < 10
BEGIN
set @ind=@ind+1
set @cmd = 'ALTER DATABASE [DB_FG_PARTITION] ADD FILEGROUP [DB_FG_PARTITION'+replicate ('0', 2-len (@ind))+cast(@ind as varchar)+']'
exec(@cmd)
END

 ------création des Fichiers

set @ind=0
While @ind < 10
BEGIN
set @ind=@ind+1
set @cmd = 'ALTER DATABASE [DB_FG_PARTITION] ADD FILE ( NAME = N''DB_FG_PARTITION'+replicate ('0', 2-len (@ind))+cast(@ind as varchar)+''', 
FILENAME = N''C:\Share_SQL\DATA\DB_FG_PARTITION'+replicate ('0', 2-len (@ind))+cast(@ind as varchar)+'.ndf'' , SIZE = 5120KB , FILEGROWTH = 1024KB ) 
TO FILEGROUP [DB_FG_PARTITION'+replicate ('0', 2-len (@ind))+cast(@ind as varchar)+']'      
exec(@cmd)
END

--- fonction partition COUNT FILEGROUP MOINS 1 = 9
CREATE PARTITION FUNCTION [FCT_SID_DEV_DWH_DATE](date) AS RANGE LEFT FOR VALUES (
'20121231',
'20131231',
'20141231',
'20151231',
'20161231',
'20170131',
'20170228',
'20170331',
'20170430'
)
--- Schéma pzrtition COUNT TOTAL FILEGROUP = 10
CREATE PARTITION SCHEME [SCH_SID_DEV_DWH_DATE] AS PARTITION [FCT_SID_DEV_DWH_DATE] TO (
'DB_FG_Partition01',
'DB_FG_Partition02',
'DB_FG_Partition03',
'DB_FG_Partition04',
'DB_FG_Partition05',
'DB_FG_Partition06',
'DB_FG_Partition07',
'DB_FG_Partition08',
'DB_FG_Partition09',
'DB_FG_Partition10'
)
--
-- partitionner la table
---
--ALTER TABLE [DWh].[F_PRODUCT] ADD  CONSTRAINT [PK_ODS_InvoiceDetail2] PRIMARY KEY CLUSTERED 
--(
--	[Commercialdate] ASC,
--	[InvoiceId] ASC,
--	[Number] ASC
--)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
--ON [SHEMA_PARTITION_Commercialdate]([Commercialdate])
--GO

USE [SID_PRD]
GO
BEGIN TRANSACTION


CREATE CLUSTERED INDEX [ClusteredIndex_on_SCH_SID_PRD_DWH_DATE_636305545742299758] ON [DWH].[F_PRODUCT]
(
	[SID_DATE]
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [SCH_SID_PRD_DWH_DATE]([SID_DATE])


DROP INDEX [ClusteredIndex_on_SCH_SID_PRD_DWH_DATE_636305545742299758] ON [DWH].[F_PRODUCT]


------ACTIVATION DES VERROU NIVEAU PARTION----------------
ALTER TABLE [ODS].[dbo].[ODS_InvoiceDetail2] SET (LOCK_ESCALATION = AUTO)



---
--- Locks niveau partitions
-----
--ALTER TABLE TableName SET (LOCK_ESCALATION = AUTO);   --- TABLE pour revenir au default
----
---- lister la taille des partitions
-----
select * from sys.partitions where object_id =OBJECT_ID(​'Sales.​SalesOrderDetail_P')​;​
select  distinct SCHEMA_NAME(​o.​schema_id)​+'.​'+OBJECT_NAME(​i.​object_id)​ as
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
WHERE OBJECTPROPERTY(p.object_id, 'ISMSShipped') = 0
	  --order by 3,5








