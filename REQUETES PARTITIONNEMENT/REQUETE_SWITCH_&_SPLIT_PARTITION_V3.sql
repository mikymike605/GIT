
--DROP DATABASE [admin_partition];
--GO

--CREATE DATABASE admin_partition
--    ON PRIMARY(
--        NAME = play_partition
--        , FILENAME = 'C:\Share_SQL\DATA\admin_partition.mdf');
--GO
 

-- USE admin_partition
-- GO
--DECLARE @fg varchar(50)
--DECLARE @ind int=0
--DECLARE @cmd varchar(max)

-- ------création des FG

--While @ind < 9
--BEGIN
--set @ind=@ind+1
--set @cmd = 'ALTER DATABASE [admin_partition] ADD FILEGROUP [admin_partition'+replicate ('0', 2-len (@ind))+cast(@ind as varchar)+']'
--exec(@cmd)
--END

-- ------création des Fichiers

--set @ind=0
--While @ind < 9
--BEGIN
--set @ind=@ind+1
--set @cmd = 'ALTER DATABASE [admin_partition] ADD FILE ( NAME = N''admin_partition'+replicate ('0', 2-len (@ind))+cast(@ind as varchar)+''', 
--FILENAME = N''C:\Share_SQL\DATA\admin_partition'+replicate ('0', 2-len (@ind))+cast(@ind as varchar)+'.ndf'' , SIZE = 5120KB , FILEGROWTH = 1024KB ) 
--TO FILEGROUP [admin_partition'+replicate ('0', 2-len (@ind))+cast(@ind as varchar)+']'      
--print(@cmd)
--END

-- --Create partition function and scheme
--CREATE PARTITION FUNCTION admin_partition_PF (date)
--AS RANGE LEFT FOR VALUES ('20161101', '20161201','20170101',
--                          '20170201', '20170301','20170401','20170501','20170601')
--GO
--CREATE PARTITION SCHEME admin_partition_Scheme AS PARTITION admin_partition_PF TO
--(admin_partition01,admin_partition02,admin_partition03,admin_partition04,
--admin_partition05,admin_partition06,admin_partition07,admin_partition08,admin_partition09)
--GO

-- Create table and indexes
CREATE TABLE myPartitionTable (i INT IDENTITY (1,1),
                               s CHAR(10) , 
                               PartCol date NOT NULL) 
    ON admin_partition_Scheme (PartCol) 
GO
ALTER TABLE myPartitionTable ADD CONSTRAINT 
    [PK_admin_partition] PRIMARY KEY NONCLUSTERED (i,PartCol) 
	ON [admin_partition_Scheme] (PartCol)
GO
CREATE CLUSTERED INDEX IX_admin_partition 
  ON myPartitionTable (PartCol) 
  ON [admin_partition_Scheme] (PartCol)
GO

CREATE TABLE myPartitionTableArchive (i INT NOT NULL,
                                           s CHAR(10) , 
                                           PartCol datetime NOT NULL) 
	 ON myPartitionScheme (PartCol) 
GO
ALTER TABLE [ODS].[admin_partition_ARCHIVE] ADD CONSTRAINT 
    PK_admin_partition_ARCHIVE PRIMARY KEY CLUSTERED (restaurantuniqueid,CommercialDate,InvoiceID) 
GO
CREATE CLUSTERED INDEX IX_myPartitionTableArchive_PartCol
  ON myPartitionTableArchive (PartCol) 
GO
CREATE CLUSTERED INDEX IX_admin_partition_ARCHIVE 
  ON [ODS].[admin_partition_ARCHIVE] (CommercialDate) 

GO

---- Create partition function and scheme
--CREATE PARTITION FUNCTION [admin_partition_FUNCTION_COMMERCIALDATE] (datetime)
--AS RANGE LEFT FOR VALUES ('20120401', '20120501','20120601','20120701', '20120801','20120901')
--GO
----CREATE PARTITION SCHEME myPartitionScheme AS PARTITION myDateRangePF ALL TO ([PRIMARY]) 
----GO 
--CREATE PARTITION SCHEME [admin_partition_SCHEMA_COMMERCIALDATE] AS PARTITION [admin_partition_FUNCTION_COMMERCIALDATE] 
--TO ('admin_partition01','admin_partition02','admin_partition03','admin_partition04','admin_partition05','admin_partition06','admin_partition07')
--GO

---- Create table and indexes
--CREATE TABLE myPartitionTable (i INT IDENTITY (1,1),s CHAR(10),PartCol datetime NOT NULL) 
--ON admin_partition_SCHEMA_COMMERCIALDATE (PartCol) 
--GO
--ALTER TABLE dbo.myPartitionTable ADD CONSTRAINT PK_myPartitionTable PRIMARY KEY NONCLUSTERED (i,PartCol) 
--ON admin_partition_SCHEMA_COMMERCIALDATE (PartCol) 
--GO
--CREATE CLUSTERED INDEX IX_myPartitionTable_PartCol 
--ON myPartitionTable (PartCol) 
--ON admin_partition_SCHEMA_COMMERCIALDATE (PartCol)
--GO
-- Polulate table data
DECLARE @x INT, @y INT
SELECT @y=3
WHILE @y < 10
BEGIN
 SELECT @x=1
 WHILE @x < 10000
 BEGIN  
    INSERT INTO myPartitionTable (s,PartCol) 
              VALUES ('data ' + CAST(@x AS VARCHAR),'20170' + CAST (@y AS VARCHAR)+ '15')
    SELECT @x=@x+1
 END
 SELECT @y=@y+1 
END 
GO

--SELECT * INTO myPartitionTableArchive3 FROM myPartitionTable 

--SWITCH DE LA PARTITION (ARCHIVAGE)
ALTER TABLE [ODS].[admin_partition] SWITCH PARTITION 1 TO [ODS].[admin_partition_ARCHIVE] PARTITION 1
GO


select ps.name,pf.name,boundary_id,value
from sys.partition_schemes ps
join sys.partition_functions pf on pf.function_id=ps.function_id
join sys.partition_range_values prf on pf.function_id=prf.function_id
where boundary_id=1

select o.name,i.name, partition_id, partition_number,[rows] ,*
from sys.partitions p
inner join sys.objects o on o.object_id=p.object_id
inner join sys.indexes i on i.object_id=o.object_id and p.index_id=i.index_id
where o.name like '%Archive'
and partition_number=1

--SUPRESZION DE LA PARTITION (MERGE)
ALTER PARTITION FUNCTION [FCT_SID_PRD_DWH_DATE] () MERGE RANGE ('20141231')
GO

EXEC SP_CONFIGURE 
---EXPORT DES DONNEES DE LA TABLE ARCHVIE 
EXEC xp_cmdshell 'bcp.exe "select * from ODS.admin_partition" 
queryout "C:\SQLSERVER_DATA\myPartitionTableArchive_20140401.txt" -T -S AUBFRM83T040 -c -t'
GO
----DROPER DE LA TABLE UNE FOIS LE BCP BIEN PASSE......
--DROP TABLE myPartitionTableArchive
--GO

---- Split last partition by altering partition function
-- Note: When splitting a partition you need to use the following command before issuing the 
--ALTER PARTITION command however this is not needed for the first split command issued.
   -- ALTER PARTITION SCHEME myPartitionScheme NEXT USED [xxxFILEGROUPARCHIVExxxxx] ------------xxxxxxMETTRE LE FILEGROUP ARCHIVER 
1. ALTER PARTITION SCHEME [admin_partition_Scheme] NEXT USED [admin_partition01]
2. ALTER PARTITION FUNCTION [admin_partition_PF] () SPLIT RANGE ('20170701') 
GO

TRUNCATE TABLE [ODS].[admin_partition_ARCHIVE]

select ps.name,pf.name,boundary_id,value
from sys.partition_schemes ps
join sys.partition_functions pf on pf.function_id=ps.function_id
join sys.partition_range_values prf on pf.function_id=prf.function_id

select o.name,i.name, partition_id, partition_number,[rows] 
from sys.partitions p
inner join sys.objects o on o.object_id=p.object_id
inner join sys.indexes i on i.object_id=o.object_id and p.index_id=i.index_id
where o.name like '%ARCHIVE'
order by o.name,partition_number


--paritioned table and index details
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
FROM sys.partitions AS p
JOIN sys.indexes AS i ON i.object_id = p.object_id AND i.index_id = p.index_id
JOIN sys.data_spaces AS ds ON ds.data_space_id = i.data_space_id
JOIN sys.partition_schemes AS ps ON ps.data_space_id = ds.data_space_id
JOIN sys.partition_functions AS pf ON pf.function_id = ps.function_id
JOIN sys.destination_data_spaces AS dds2 ON dds2.partition_scheme_id = ps.data_space_id AND dds2.destination_id = p.partition_number
JOIN sys.filegroups AS fg ON fg.data_space_id = dds2.data_space_id
LEFT JOIN sys.partition_range_values AS prv_left ON ps.function_id = prv_left.function_id AND prv_left.boundary_id = p.partition_number - 1 
LEFT JOIN sys.partition_range_values AS prv_right ON ps.function_id = prv_right.function_id AND prv_right.boundary_id = p.partition_number 
WHERE OBJECTPROPERTY(p.object_id, 'ISMSShipped') = 0
--and fg.name like '%01%'
ORDER BY 3,5

