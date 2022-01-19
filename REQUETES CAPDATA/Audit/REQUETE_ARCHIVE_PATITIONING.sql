/**EXEMPLE CREATION EN LAB 
BEGIN TRANSACTION
USE [SID_DEV]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DWH].[F_RESTAURANT_Archive](
	[SID_DATE] [date] NOT NULL,
	[SID_ORGANNE] [int] NOT NULL,
	[ID_UNIQUE_RESTAURANT] [int] NOT NULL,
	[SID_IMPLANTATION] [int] NOT NULL,
	[SID_EXPLOITATION] [int] NOT NULL,
	[SID_REVENUE_CENTER] [int] NOT NULL,
	[SID_CURRENCY] [int] NOT NULL,
	[PART_MONTH] [tinyint] NOT NULL,
	[TOT_TICKETS] [int] NOT NULL,
	[TOT_ITEMS] [int] NOT NULL,
	[TOT_ITEMS_REECLATE] [int] NOT NULL,
	[TOT_ITEMS_NONREECLATE] [int] NOT NULL,
	[REVENUE_TTC] [decimal](18, 6) NOT NULL,
	[REVENUE_HT] [decimal](18, 6) NOT NULL,
	[TOT_FOODCOST] [decimal](18, 6) NULL,
	[TOT_PENNY_PROFIT] [decimal](18, 6) NULL,
	[TOT_TRAINING] [decimal](18, 6) NULL,
	[TOT_BON_REPAS] [decimal](18, 6) NOT NULL,
	[TOT_DISCOUNT] [decimal](18, 6) NOT NULL,
	[TOT_VA] [decimal](18, 6) NOT NULL,
	[TOT_NET_REVENUE_TTC] [decimal](18, 6) NOT NULL,
	[TOT_TAXES] [decimal](18, 6) NOT NULL,
	[TOT_NET_REVENUE_HT] [decimal](18, 6) NOT NULL,
	[FLAG_PLUG_CA] [bit] NOT NULL,
	[REVENUE_TTC_A1] [decimal](18, 6) NULL,
	[TOT_NET_REVENUE_HT_A1] [decimal](18, 6) NULL,
	[TOT_TICKETS_A1] [int] NULL,
	[DT_INS] [datetime] NOT NULL,
	[DT_MAJ] [datetime] NOT NULL,
	[DT_SUP] [datetime] NULL,
	[SOURCE] [varchar](3) COLLATE French_CI_AS NOT NULL
) ON [SID_DEV_DWH_FG_04]

USE [SID_DEV]
CREATE NONCLUSTERED INDEX [F_RESTAURANT_Archive_IX_F_RESTAURANT] ON [DWH].[F_RESTAURANT_Archive]
(
	[SID_DATE] ASC,
	[ID_UNIQUE_RESTAURANT] ASC,
	[SID_REVENUE_CENTER] ASC
)WITH (PAD_INDEX = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [SID_DEV_DWH_FG_04]
USE [SID_DEV]
ALTER TABLE [DWH].[F_RESTAURANT_Archive]  WITH CHECK ADD  CONSTRAINT [chk_F_RESTAURANT_Archive_partition_5] CHECK  ([SID_DATE]>N'2015-12-31' AND [SID_DATE]<=N'2016-12-31')
ALTER TABLE [DWH].[F_RESTAURANT_Archive] CHECK CONSTRAINT [chk_F_RESTAURANT_Archive_partition_5]
ALTER TABLE [SID_DEV].[DWH].[F_RESTAURANT] SWITCH PARTITION 5 TO [SID_DEV].[DWH].[F_RESTAURANT_Archive] WITH (WAIT_AT_LOW_PRIORITY (MAX_DURATION = 0 MINUTES, ABORT_AFTER_WAIT = NONE))
COMMIT TRANSACTION

**/

/**
-- Create partition function and scheme
CREATE PARTITION FUNCTION myDateRangePF (datetime)
AS RANGE LEFT FOR VALUES ('20120401', '20120501','20120601',
                          '20120701', '20120801','20120901')
GO
CREATE PARTITION SCHEME myPartitionScheme AS PARTITION myDateRangePF ALL TO ([PRIMARY]) 
GO 
-- Create table and indexes
CREATE TABLE myPartitionTable (i INT IDENTITY (1,1),
                               s CHAR(10) , 
                               PartCol datetime NOT NULL) 
    ON myPartitionScheme (PartCol) 
GO
ALTER TABLE dbo.myPartitionTable ADD CONSTRAINT 
    PK_myPartitionTable PRIMARY KEY NONCLUSTERED (i,PartCol) 
  ON myPartitionScheme (PartCol) 
GO
CREATE CLUSTERED INDEX IX_myPartitionTable_PartCol 
  ON myPartitionTable (PartCol) 
  ON myPartitionScheme(PartCol)
GO
-- Polulate table data
DECLARE @x INT, @y INT
SELECT @y=3
WHILE @y < 10
BEGIN
 SELECT @x=1
 WHILE @x < 20000
 BEGIN  
    INSERT INTO myPartitionTable (s,PartCol) 
              VALUES ('data ' + CAST(@x AS VARCHAR),'20120' + CAST (@y AS VARCHAR)+ '15')
    SELECT @x=@x+1
 END
 SELECT @y=@y+1 
END 
GO

===========================ATTENTION AVOIR UN INDEXS CLUSTER SUR LA TABLE SOURCE SINON LA REQUETE SORTIRA UNE ERREUR "does not have clustered index."===================


CREATE TABLE myPartitionTableArchive (i INT NOT NULL,
                                           s CHAR(10) , 
                                           PartCol datetime NOT NULL) 
GO
ALTER TABLE myPartitionTableArchive ADD CONSTRAINT 
    PK_myPartitionTableArchive PRIMARY KEY NONCLUSTERED (i,PartCol) 
GO
CREATE CLUSTERED INDEX IX_myPartitionTableArchive_PartCol
  ON myPartitionTableArchive (PartCol) 
GO


ALTER TABLE myPartitionTable SWITCH PARTITION 1 TO myPartitionTableArchive 
GO

ALTER PARTITION FUNCTION myDateRangePF () MERGE RANGE ('20120401')
GO
=========> MEGAsync\DataBaseAdmin\REQUETTES SQL\BCP / 
EXEC xp_cmdshell 'bcp.exe master..myPartitionTableArchive format nul -T -n -f \\SLBKQ030\Share_SQL\FG.FMT -S AUBFRM83T040'
EXEC xp_cmdshell 'bcp.exe "select * from master..myPartitionTable" queryout "\\SLBKQ030\Share_SQL\toto.txt" -f "\\SLBKQ030\Share_SQL\FG.FMT" -n -T -S'

--DROP TABLE myPartitionTableArchive
--GO




-- Split last partition by altering partition function
-- Note: When splitting a partition you need to use the following command before issuing the 
         ALTER PARTITION command however this is not needed for the first split command issued.
--    ALTER PARTITION SCHEME myPartitionScheme NEXT USED [PRIMARY]
ALTER PARTITION FUNCTION myDateRangePF () SPLIT RANGE ('20121001')
GO

/* Add the filegroup into the scheme by setting it NEXT USED */
-- ALTER PARTITION SCHEME [SCH_SID_PRD_DWH_DATE] NEXT USED [SID_PRD_DWH_FG_17]; 
-- GO 
/* Then we can SPLIT */
-- ALTER PARTITION FUNCTION [FCT_SID_PRD_DWH_DATE] () SPLIT RANGE ( '20180101' );
-- GO

select ps.name,pf.name,boundary_id,value 
from sys.partition_schemes ps
join sys.partition_functions pf on pf.function_id=ps.function_id
join sys.partition_range_values prf on pf.function_id=prf.function_id

select o.name,i.name,partition_id,partition_number, [rows]
from sys.partitions p 
inner join sys.objects o on o.object_id=p.object_id
inner join sys.indexes i on i.object_id=o.object_id
and p.index_id=i.index_id
where o.name like 'mypartitiontable'

EXEC master.dbo.sp_configure 'show advanced options', 1
RECONFIGURE
EXEC master.dbo.sp_configure 'xp_cmdshell', 1
RECONFIGURE

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [i]
      ,[s]
      ,[PartCol]
  FROM [master].[dbo].[myPartitionTable]
**/

--paritioned table and index details

/**
https://www.mssqltips.com/sqlservertip/2780/archiving-sql-server-data-using-partitioning/
**/
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
,case when pf.boundary_value_on_right = 1 then 'less than' when pf.boundary_value_on_right is null then '' else 'less than or equal to' End as Comparison
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
--where fg.name not in ('PRIMARY')
where fg.name in ('SID_PRD_ODS_FG29','SID_PRD_DWH_FG_29')
--and tb.name in ('TICKET_UNIFIE','TICKET_UNIFIE_ARCHIVE','MD5_INVOICE','MD5_INVOICE_ARCHIVE','MD5_INVOICE_DETAIL','MD5_INVOICE_DETAIL_ARCHIVE','REB_INVOICE','REB_INVOICE_ARCHIVE','REB_INVOICEDETAIL','REB_INVOICEDETAIL_ARCHIVE')
order by value desc 



 
SELECT OBJECT_NAME(p.object_id) AS ObjectName
,p.Partition_Number AS PartitionNumber
,PRV.Value AS RangeValue
,Rows AS RowCnt 
FROM sys.partitions AS p 
INNER JOIN sys.indexes AS i  ON p.object_id = i.object_id AND p.index_id = i.index_id
INNER JOIN sys.partition_schemes ps ON i.data_space_id=ps.data_space_id
INNER JOIN sys.partition_functions PF  ON PF.function_id = ps.Function_ID
INNER JOIN sys.partition_range_values PRV  ON PRV.Function_ID = Ps.Function_ID
AND CASE WHEN PF.boundary_value_on_right = 1 THEN boundary_id + 1
ELSE boundary_id END = p.Partition_Number 
WHERE OBJECT_NAME(p.object_id) = 'ticket_unifie'
--ORDER BY  Partition_Number;



SELECT
      OBJECT_NAME(p.object_id) AS ObjectName,
      i.name                   AS IndexName,
      p.index_id               AS IndexID,
      ds.name                  AS PartitionScheme,   
      p.partition_number       AS PartitionNumber,
      fg.name                  AS FileGroupName,
      prv_left.value           AS LowerBoundaryValue,
      prv_right.value          AS UpperBoundaryValue,
      CASE pf.boundary_value_on_right
            WHEN 1 THEN 'RIGHT'
            ELSE 'LEFT' END    AS Range,
      p.rows AS Rows
FROM sys.partitions                  AS p
JOIN sys.indexes                     AS i
      ON i.object_id = p.object_id
      AND i.index_id = p.index_id
JOIN sys.data_spaces                 AS ds
      ON ds.data_space_id = i.data_space_id
JOIN sys.partition_schemes           AS ps
      ON ps.data_space_id = ds.data_space_id
JOIN sys.partition_functions         AS pf
      ON pf.function_id = ps.function_id
JOIN sys.destination_data_spaces     AS dds2
      ON dds2.partition_scheme_id = ps.data_space_id 
      AND dds2.destination_id = p.partition_number
JOIN sys.filegroups                  AS fg
      ON fg.data_space_id = dds2.data_space_id
LEFT JOIN sys.partition_range_values AS prv_left
      ON ps.function_id = prv_left.function_id
      AND prv_left.boundary_id = p.partition_number - 1
LEFT JOIN sys.partition_range_values AS prv_right
      ON ps.function_id = prv_right.function_id
      AND prv_right.boundary_id = p.partition_number 
WHERE
      OBJECTPROPERTY(p.object_id, 'ISMSShipped') = 0
	  
	  and   fg.name  = 'PRIMARY'
UNION ALL
--non-partitioned table/indexes
SELECT
      OBJECT_NAME(p.object_id)    AS ObjectName,
      i.name                      AS IndexName,
      p.index_id                  AS IndexID,
      NULL                        AS PartitionScheme,
      p.partition_number          AS PartitionNumber,
      fg.name                     AS FileGroupName,  
      NULL                        AS LowerBoundaryValue,
      NULL                        AS UpperBoundaryValue,
      NULL                        AS Boundary, 
      p.rows                      AS Rows
FROM sys.partitions     AS p
JOIN sys.indexes        AS i
      ON i.object_id = p.object_id
      AND i.index_id = p.index_id
JOIN sys.data_spaces    AS ds
      ON ds.data_space_id = i.data_space_id
JOIN sys.filegroups           AS fg
      ON fg.data_space_id = i.data_space_id
WHERE
      OBJECTPROPERTY(p.object_id, 'ISMSShipped') = 0
	  and i.name   is not null
	  and   fg.name  = 'PRIMARY'
ORDER BY
      rows desc 
	  
	  
	  
	  --SELECT min ([CommercialDate]), COUNT (*) FROM MK_Invoice_Disision_PLU union SELECT MAX ([CommercialDate]) , COUNT (*)  FROM MK_Invoice_Disision_PLU 
SELECT min ([CommercialDate]) , COUNT (*)  FROM MK_QA_Jour union SELECT MAX ([CommercialDate]) , COUNT (*)  FROM MK_QA_Jour 
SELECT min ([Date_Jour]) , COUNT (*)  FROM OP_CA_Jour union SELECT MAX ([Date_Jour]) , COUNT (*)  FROM OP_CA_Jour 
SELECT min ([Date_Jour]) , COUNT (*)  FROM OP_QA_Jour union SELECT MAX ([Date_Jour]) , COUNT (*)  FROM OP_QA_Jour 
--SELECT min ([FiscalDate]) , COUNT (*)  FROM Mk_CDV_Division_Ticket union SELECT MAX ([FiscalDate]) , COUNT (*)  FROM Mk_CDV_Division_Ticket 
--SELECT min ([FiscalDate]) , COUNT (*)  FROM Mk_Division_Item_Jour union SELECT MAX ([FiscalDate]) , COUNT (*)  FROM Mk_Division_Item_Jour 
SELECT min ([Date_Jour]) , COUNT (*)  FROM OP_Param_Jour union SELECT MAX ([Date_Jour]) , COUNT (*)  FROM OP_Param_Jour 
--SELECT min ([Date_Jour]) , COUNT (*)  FROM OP_CA_Jour_Old union SELECT MAX ([Date_Jour]) , COUNT (*)  FROM OP_CA_Jour_Old 

--EXEC xp_cmdshell 'bcp.exe DBCAHC..OP_CA_Jour_Old format nul -T -n -f \\VILFRMDBRIDGE\Share_SQL\Archive_20121231\FG_OP_CA_Jour_Old.FMT -S VILFRMDBRIDGE'
--EXEC xp_cmdshell 'bcp.exe "select * from DBCAHC..OP_CA_Jour_Old " queryout "\\VILFRMDBRIDGE\Share_SQL\Archive_20121231\OP_CA_Jour_Old.txt" -f "\\VILFRMDBRIDGE\Share_SQL\Archive_20121231\FG_OP_CA_Jour_Old.FMT" -n -T -S'


--select count (*) from DBCAHC..Mk_Division_Item_Jour where [FiscalDate] <='20121231'