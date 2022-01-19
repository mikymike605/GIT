--Find out the disk size of an index:
USE [SID_PRD]
go
SELECT I.OBJECT_ID,
OBJECT_NAME(I.OBJECT_ID) AS TableName,
I.name AS IndexName,   
8 * SUM(AU.used_pages) AS 'Index size (KB)',
CAST(8 * SUM(AU.used_pages) / 1024.0 AS DECIMAL(18,2)) AS 'Index size (MB)',
CAST(8 * SUM(AU.used_pages) / 1024.0/1024.0 AS DECIMAL(18,2)) AS 'Index size (GB)'
FROM
sys.indexes I
JOIN sys.partitions P ON P.OBJECT_ID = I.OBJECT_ID AND P.index_id = I.index_id
JOIN sys.allocation_units AU ON AU.container_id = P.partition_id
--WHERE I.OBJECT_ID = '550397130'    
GROUP BY
I.OBJECT_ID,    
I.name
having CAST(8 * SUM(AU.used_pages) / 1024.0/1024.0 AS DECIMAL(18,2)) >150
ORDER BY
TableName

SELECT * FROM sys.indexes WHERE object_id=550397130


--========================================================================================

--http://msdn.microsoft.com/en-us/library/fooec9de780-68fd-4551-b70b-2d3ab3709b3e.aspx

--I believe that keeping the GROUP BY 
--is the best option in this case
--because of sys.allocation_units
--can have 4 types of data inside
--as below:

--type tinyint
--Type of allocation unit.
--0 = Dropped
--1 = In-row data (all data types, except LOB data types)
--2 = Large object (LOB) data (text, ntext, image, xml, large value types, and CLR     user-defined types)
--3 = Row-overflow data

--marcelo miorelli 8-NOV-2013
--========================================================================================