//**REQUETE AIDE PARTIONNEMENT SQL 
http://marlonribunal.com/split-table-partitions/
**//
------Test Table Partitions

CREATE TABLE PartitionedTable (
 ID INT NOT NULL,
 SalesDate SMALLDATETIME NOT NULL,
 ColA VARCHAR(100) NULL,
 ColB VARCHAR(100) NULL,
 )
 
 
 SELECT o.name objectname ,
i.name indexname ,
partition_id ,
partition_number ,
[rows]
FROM sys.partitions p
INNER JOIN sys.objects o ON o.object_id = p.object_id
INNER JOIN sys.indexes i ON i.object_id = p.object_id
AND p.index_id = i.index_id
WHERE o.name = 'PartitionedTable';
 
 
-----Partition Function and Scheme

 CREATE PARTITION FUNCTION pfPartitionedTableDate (SMALLDATETIME)
AS RANGE LEFT FOR VALUES ('20170101');

CREATE PARTITION SCHEME schPartitionedTableDate
AS PARTITION pfPartitionedTableDate ALL TO ([PRIMARY]);

--Partition scheme 'schPartitionedTableDate' has been created successfully. 'PRIMARY' is marked as the next used filegroup in partition scheme 'schPartitionedTableDate'.


------Add Indexes

ALTER TABLE PartitionedTable ADD CONSTRAINT PK_PartitionedTable PRIMARY KEY CLUSTERED (ID)
ON [PRIMARY]

CREATE NONCLUSTERED INDEX IX_PartitionedTable_ID ON PartitionedTable (SalesDate) 
 ON schPartitionedTableDate(SalesDate)
 
 --------Create Additional Partition
 
  ALTER PARTITION SCHEME schPartitionedTableDate 
 NEXT USED [PRIMARY]
 ALTER PARTITION FUNCTION pfPartitionedTableDate() SPLIT RANGE('20170201')

 ALTER PARTITION SCHEME schPartitionedTableDate 
 NEXT USED [PRIMARY]
 ALTER PARTITION FUNCTION pfPartitionedTableDate() SPLIT RANGE('20170301')

 ALTER PARTITION SCHEME schPartitionedTableDate 
 NEXT USED [PRIMARY]
 ALTER PARTITION FUNCTION pfPartitionedTableDate() SPLIT RANGE('20170401')

 ALTER PARTITION SCHEME schPartitionedTableDate 
NEXT USED [PRIMARY] 
ALTER PARTITION FUNCTION pfPartitionedTableDate() SPLIT RANGE('20170501')


-------Insert Additional Records

INSERT INTO PartitionedTable
VALUES (1001, '2017/04/01','Product1001','ProductDescription1001'),
(1002, '2017/04/01','Product1002','ProductDescription1002'),
(1003, '2017/04/01','Product1003','ProductDescription1003')

SELECT OBJECT_NAME(p.object_id) AS ObjectName ,
 i.name AS IndexName ,
 p.index_id AS IndexID ,
 ds.name AS PartitionScheme ,
 p.partition_number AS PartitionNumber ,
 fg.name AS FileGroupName ,
 prv_left.value AS LowerBoundaryValue ,
 prv_right.value AS UpperBoundaryValue ,
 CASE pf.boundary_value_on_right
 WHEN 1 THEN 'RIGHT'
 ELSE 'LEFT'
 END AS PartitionFunctionRange ,
 p.rows AS Rows
FROM sys.partitions AS p
 INNER JOIN sys.indexes AS i ON i.object_id = p.object_id
 AND i.index_id = p.index_id
 INNER JOIN sys.data_spaces AS ds ON ds.data_space_id = i.data_space_id
 INNER JOIN sys.partition_schemes AS ps ON ps.data_space_id = ds.data_space_id
 INNER JOIN sys.partition_functions AS pf ON pf.function_id = ps.function_id
 INNER JOIN sys.destination_data_spaces AS dds ON dds.partition_scheme_id = ps.data_space_id
 AND dds.destination_id = p.partition_number
 INNER JOIN sys.filegroups AS fg ON fg.data_space_id = dds.data_space_id
 LEFT OUTER JOIN sys.partition_range_values AS prv_left ON ps.function_id = prv_left.function_id
 AND prv_left.boundary_id = p.partition_number- 1
 LEFT OUTER JOIN sys.partition_range_values AS prv_right ON ps.function_id = prv_right.function_id
 AND prv_right.boundary_id = p.partition_number
WHERE p.object_id = OBJECT_ID('PartitionedTable');


--------Dynamic Table Partition Split

--Variable Declaration
DECLARE @currentpartition INT
 , @chunk INT
 , @partvalue SMALLDATETIME
 , @maintainbucket INT
 , @availablepartition INT
 , @partitiontocreate INT
 , @lastavailablepartid INT
 , @lastavailablepartval INT
 , @sql NVARCHAR(4000)
 ,@sqlmaxdate NVARCHAR(4000)
 ,@maxdate SMALLDATETIME
 , @pscheme VARCHAR(400) ;

SET @pscheme = 'schPartitionedTableDate' ;

SET @chunk = 1 ; --1 Month - Preset Partition Size/Chunk 
SET @maintainbucket = 3 ; --Number of Partitions to maintain any given time

--Prep: Create and Populate Temp Table #Partitions
WITH cte_part
 AS
 (
 SELECT i.index_id
 , prv_left.value AS LowerBoundaryValue
 , prv_right.value AS UpperBoundaryValue

, CASE pf.boundary_value_on_right
 WHEN 1
 THEN 'RIGHT'
 ELSE 'LEFT'
 END AS PartitionFunctionRange
 , p.partition_number AS PartitionNumber
 , p.rows AS Rows
 --In case the table has multiple indexes
 , ROW_NUMBER() OVER (PARTITION BY prv_left.value, prv_right.value, p.rows
 ORDER BY i.index_id,prv_left.value , prv_right.value 
 ) AS row_num
 FROM sys.partitions AS p
 INNER JOIN sys.indexes AS i
 ON i.object_id = p.object_id
 AND i.index_id = p.index_id
 INNER JOIN sys.data_spaces AS ds
 ON ds.data_space_id = i.data_space_id
 INNER JOIN sys.partition_schemes AS ps
 ON ps.data_space_id = ds.data_space_id
 INNER JOIN sys.partition_functions AS pf
 ON pf.function_id = ps.function_id
 LEFT OUTER JOIN sys.partition_range_values AS prv_left
 ON ps.function_id = prv_left.function_id
 AND prv_left.boundary_id = p.partition_number - 1
 LEFT OUTER JOIN sys.partition_range_values AS prv_right
 ON ps.function_id = prv_right.function_id
 AND prv_right.boundary_id = p.partition_number
 WHERE ds.name = @pscheme --Partition Scheme Name
 )
SELECT cte_part.index_id
 , cte_part.LowerBoundaryValue
 , cte_part.UpperBoundaryValue
 , cte_part.PartitionFunctionRange
 , cte_part.PartitionNumber
 , cte_part.Rows
INTO #Partitions
 FROM cte_part
 WHERE cte_part.row_num = 1
 ORDER BY cte_part.LowerBoundaryValue
 , cte_part.UpperBoundaryValue 
 , cte_part.PartitionFunctionRange


SET @sqlmaxdate = 'SELECT @maxdate = MAX(SalesDate) FROM PartitionedTable' ; 

EXEC sp_executesql @sqlmaxdate
 , N'@maxdate SMALLDATETIME OUTPUT'
 , @maxdate = @maxdate OUTPUT ;

SELECT @currentpartition = $PARTITION.[pfPartitionedTableDate](@maxdate) ;

--Count the number of available Partitions
SET @availablepartition = ((SELECT MAX( PartitionNumber ) FROM #Partitions) - @currentpartition) - 1 /* Minus 1 excluding unpartitioned in the count*/ ;
SET @partitiontocreate = @maintainbucket - @availablepartition ;
SET @lastavailablepartid = ((SELECT MAX( PartitionNumber ) FROM #Partitions) - 1) ; /* Minus 1 excluding unpartitioned in the count*/
SET @lastavailablepartval = (SELECT CONVERT(VARCHAR(8),UpperBoundaryValue,112)FROM #Partitions WHERE PartitionNumber = @lastavailablepartid) ;

BEGIN
IF @maintainbucket = @availablepartition OR @maintainbucket &lt; @availablepartition
 BEGIN
 PRINT 'No Action Needed. Available Partition is: ' + CONVERT( VARCHAR(MAX), @availablepartition ) + ' and Number of Partition to Maintain is: ' + CONVERT( VARCHAR(MAX), @maintainbucket ) ;
 END ;
ELSE 
 BEGIN
 SET @partvalue = CAST(CAST(@lastavailablepartval as VARCHAR(8)) AS DATETIME);

 WHILE @partitiontocreate &gt; 0
 BEGIN
 SET @partvalue = DATEADD(MONTH, @chunk, @partvalue) ; -- Plus @chunk = 1 Month
 SET @sql = 'ALTER PARTITION SCHEME schPartitionedTableDate 
 NEXT USED [PRIMARY] 
 
 ALTER PARTITION FUNCTION [pfPartitionedTableDate]() SPLIT RANGE (''' + CONVERT( VARCHAR(10), @partvalue, 112 ) + ''') --Range Partition Value' ;

 EXEC sp_executesql @statement = @sql ;

SET @partitiontocreate = @partitiontocreate - 1 ;
 END ; 
 END 
END

--Cleanup
DROP TABLE #Partitions ;

No Action Needed. Available Partition is: 3 and Number of Partition to Maintain is: 3


