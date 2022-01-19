
USE AdminPartition
GO


DECLARE @fg varchar(50)
DECLARE @ind int=0
DECLARE @cmd varchar(max)

 ------création des FG

While @ind < 7
BEGIN
set @ind=@ind+1
set @cmd = 'ALTER DATABASE [AdminPartition] ADD FILEGROUP [AdminPartition_'+replicate ('0', 2-len (@ind))+cast(@ind as varchar)+']'
exec(@cmd)
END

 ------création des Fichiers

set @ind=0
While @ind < 7
BEGIN
set @ind=@ind+1
set @cmd = 'ALTER DATABASE [AdminPartition] ADD FILE ( NAME = N''AdminPartition_'+replicate ('0', 2-len (@ind))+cast(@ind as varchar)+''', 
FILENAME = N''C:\SQLSERVER_DATA\AdminPartition\AdminPartition_'+replicate ('0', 2-len (@ind))+cast(@ind as varchar)+'.ndf'' , SIZE = 5120KB , FILEGROWTH = 1024KB ) 
TO FILEGROUP [AdminPartition_'+replicate ('0', 2-len (@ind))+cast(@ind as varchar)+']'      
exec(@cmd)
END

-- Create partition function and scheme
CREATE PARTITION FUNCTION [AdminPartition_PART_FUNCTION_COMMERCIALDATE] (datetime)
AS RANGE LEFT FOR VALUES ('20120401', '20120501','20120601','20120701', '20120801','20120901')
GO
--CREATE PARTITION SCHEME myPartitionScheme AS PARTITION myDateRangePF ALL TO ([PRIMARY]) 
--GO 
CREATE PARTITION SCHEME [AdminPartition_PART_SCHEMA_COMMERCIALDATE] AS PARTITION [AdminPartition_PART_FUNCTION_COMMERCIALDATE] TO (
'AdminPartition_01','AdminPartition_02','AdminPartition_03','AdminPartition_04','AdminPartition_05','AdminPartition_06',
'AdminPartition_07')

---- Create partition function and scheme
--CREATE PARTITION FUNCTION myDateRangePF (datetime)
--AS RANGE LEFT FOR VALUES ('20120401', '20120501','20120601',
--                          '20120701', '20120801','20120901')
--GO
--CREATE PARTITION SCHEME myPartitionScheme AS PARTITION myDateRangePF ALL TO ([PRIMARY]) 
--GO 
-- Create table and indexes


CREATE TABLE myPartitionTable (i INT IDENTITY (1,1),
                               s CHAR(10) , 
                               PartCol datetime NOT NULL) 
    ON [AdminPartition_PART_SCHEMA_COMMERCIALDATE] (PartCol) 
GO
ALTER TABLE dbo.myPartitionTable ADD CONSTRAINT 
    PK_myPartitionTable PRIMARY KEY NONCLUSTERED (i,PartCol) 
  ON [AdminPartition_PART_SCHEMA_COMMERCIALDATE] (PartCol) 
GO
CREATE CLUSTERED INDEX IX_myPartitionTable_PartCol 
  ON myPartitionTable (PartCol) 
  ON [AdminPartition_PART_SCHEMA_COMMERCIALDATE](PartCol)
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


select ps.name,pf.name,boundary_id,value
from sys.partition_schemes ps
join sys.partition_functions pf on pf.function_id=ps.function_id
join sys.partition_range_values prf on pf.function_id=prf.function_id

select o.name,i.name, partition_id, partition_number,[rows] 
from sys.partitions p
inner join sys.objects o on o.object_id=p.object_id
inner join sys.indexes i on i.object_id=o.object_id and p.index_id=i.index_id
where o.name = 'mypartitiontable'

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
ALTER PARTITION FUNCTION myDateRangePF () MERGE RANGE ('20120501')
GO

select o.name,i.name, partition_id, partition_number,[rows] 
from sys.partitions p
inner join sys.objects o on o.object_id=p.object_id
inner join sys.indexes i on i.object_id=o.object_id and p.index_id=i.index_id
where o.name like 'mypartitiontable%'


EXEC xp_cmdshell 'bcp "select * from myPartitionTableArchive" 
queryout "C:\myPartitionTableArchive_#DATEHERE#.txt" -T -S#SERVERNAME# -c -t,'
GO
DROP TABLE myPartitionTableArchive
GO

-- Split last partition by altering partition function
-- Note: When splitting a partition you need to use the following command before issuing the 
--	  ALTER PARTITION command however this is not needed for the first split command issued.
--    ALTER PARTITION SCHEME myPartitionScheme NEXT USED [PRIMARY]
ALTER PARTITION FUNCTION myDateRangePF () SPLIT RANGE ('20121001')
GO



SELECT OBJECT_NAME(p.object_id) AS ObjectName,
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
JOIN sys.indexes AS i  ON i.object_id = p.object_id AND i.index_id = p.index_id
JOIN sys.data_spaces AS ds ON ds.data_space_id = i.data_space_id
JOIN sys.partition_schemes  AS ps ON ps.data_space_id = ds.data_space_id
JOIN sys.partition_functions  AS pf ON pf.function_id = ps.function_id
JOIN sys.destination_data_spaces  AS dds2 ON dds2.partition_scheme_id = ps.data_space_id AND dds2.destination_id = p.partition_number
JOIN sys.filegroups AS fg ON fg.data_space_id = dds2.data_space_id
LEFT JOIN sys.partition_range_values AS prv_left ON ps.function_id = prv_left.function_id AND prv_left.boundary_id = p.partition_number - 1
LEFT JOIN sys.partition_range_values AS prv_right ON ps.function_id = prv_right.function_id  AND prv_right.boundary_id = p.partition_number 
WHERE OBJECTPROPERTY(p.object_id, 'ISMSShipped') = 0
	  order by 3,5