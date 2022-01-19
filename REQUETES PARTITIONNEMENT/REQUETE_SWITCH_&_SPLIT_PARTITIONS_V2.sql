select ps.name,pf.name,boundary_id,value
from sys.partition_schemes ps
join sys.partition_functions pf on pf.function_id=ps.function_id
join sys.partition_range_values prf on pf.function_id=prf.function_id

select o.name,i.name, partition_id, partition_number,[rows] 
from sys.partitions p
inner join sys.objects o on o.object_id=p.object_id
inner join sys.indexes i on i.object_id=o.object_id and p.index_id=i.index_id
where o.name like 'play%'

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
JOIN sys.filegroups  AS fg ON fg.data_space_id = dds2.data_space_id
LEFT JOIN sys.partition_range_values AS prv_left ON ps.function_id = prv_left.function_id AND prv_left.boundary_id = p.partition_number - 1
LEFT JOIN sys.partition_range_values AS prv_right ON ps.function_id = prv_right.function_id AND prv_right.boundary_id = p.partition_number 
WHERE OBJECTPROPERTY(p.object_id, 'ISMSShipped') = 0
order by 3,5


USE master;
GO

DROP DATABASE [play_partition];
GO

CREATE DATABASE play_partition
    ON PRIMARY(
        NAME = play_partition
        , FILENAME = 'C:\SQLSERVER_DATA\play_partition\play_partition.mdf')
    ,FILEGROUP play_fg1(
        NAME = play_fg1
        ,FILENAME = 'C:\SQLSERVER_DATA\play_partition\play_fg1f1.ndf')
    ,FILEGROUP play_fg2(
        NAME = play_fg2f1
        ,FILENAME = 'C:\SQLSERVER_DATA\play_partition\play_fg2f1.ndf');
GO

USE play_partition;


CREATE PARTITION FUNCTION play_range(INT) AS RANGE LEFT FOR VALUES(3);

-- Partition scheme
CREATE PARTITION SCHEME play_scheme AS PARTITION play_range TO (play_fg1, play_fg2);

-- Partitioned tables
CREATE TABLE play_partition..play_table(c1 INT NOT NULL CONSTRAINT PK_play_table_c1 PRIMARY KEY CLUSTERED)
    ON play_scheme(c1);

CREATE TABLE play_partition..archive_play_table(c1 INT NOT NULL CONSTRAINT PK_archive_play_table_c1 PRIMARY KEY CLUSTERED)
    ON play_scheme(c1);

-- partition 1 = {1, 2, 3}, partiion 2 = {4, 5, 6}
INSERT INTO play_partition..play_table(c1) VALUES (1), (2),  (3), (4), (5), (6);

-- move partition 1 from play_table to archive play_table
ALTER TABLE dbo.play_table SWITCH PARTITION 1 to dbo.archive_play_table PARTITION 1;

-- create empty table with same structure as dbo.play_table
SELECT * INTO play_partition..temp_table FROM dbo.play_table WHERE 1 = 0;

-- move temp_table to filegroup play_fg2
ALTER TABLE play_partition..temp_table ADD CONSTRAINT PK_temp_table_c1 PRIMARY KEY CLUSTERED(c1) ON play_fg2;

-- move contents of play_table to temp_table, which is not partitioned
-- but is in the same filegroup
ALTER TABLE dbo.play_table SWITCH PARTITION 2 TO temp_table;
PRINT 'Switched from partitioned table to non-partitioned table';

-- move data back to partitioned play_table from unpartitioned temp_table
-- FAIL
ALTER TABLE dbo.temp_tableSWITCH TO play_table partition 2;
PRINT 'Switched from non-partitioned table to partitioned table';


SELECT 'archive_play_table' as table_name, t1.c1
    FROM play_partition..archive_play_table AS t1
    UNION ALL
    SELECT 'temp_table' AS table_name, t1.c1
        FROM play_partition..temp_table as t1
    ORDER BY 1, 2;