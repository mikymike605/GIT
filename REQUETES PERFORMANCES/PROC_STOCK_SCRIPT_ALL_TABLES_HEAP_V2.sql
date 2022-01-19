 DROP TABLE #Table_Policy
 
 SET NOCOUNT ON
GO
USE [SID_PRD];
CREATE TABLE #Table_Policy
( 
ID INT PRIMARY KEY IDENTITY(1, 1) NOT NULL 
, Schem_Name NVARCHAR(50)
, Table_Name NVARCHAR(100) 
, Rows_Count INT 
, Is_Heap INT 
, Is_Clustered INT 
, num_Of_nonClustered INT
 );
WITH cte AS 
( 
SELECT s.name,
table_name = o.name 
,o.[object_id] 
,i.INDEX_id 
,i.type 
,i.type_desc 
FROM sys.INDEXES i 
INNER JOIN sys.OBJECTS o ON i.[object_id] = o.[object_id]
 inner join sys.schemas s on o.schema_id=s.schema_id
WHERE o.type IN ( 'U' )
and o.name='F_PRODUCT'
AND o.is_ms_shipped = 0 
AND i.is_disabled = 0 
AND i.is_hypothetical = 0 
AND i.type <= 2 )
,
cte2 AS ( 
SELECT * 
FROM cte c PIVOT 
( COUNT(type) FOR type_desc IN ( [HEAP], [CLUSTERED], [NONCLUSTERED] ) ) pv ) 
INSERT INTO #Table_Policy 
( Schem_Name,
Table_Name 
, Rows_Count 
, Is_Heap 
, Is_Clustered 
,num_Of_nonClustered
)
SELECT c2.name,
c2.table_name 
,[rows] = MAX(p.rows) 
,is_heap = SUM([HEAP]) 
,is_clustered = SUM([CLUSTERED]) 
,num_of_nonclustered = SUM([NONCLUSTERED]) 
FROM cte2 c2 INNER JOIN sys.partitions p ON c2.[object_id] = p.[object_id]
AND c2.INDEX_id = p.index_id 
--where c2.table_name like 'F_PRODUCT'
GROUP BY table_name,c2.name 
order by rows desc---–DMV
SELECT * 
FROM #Table_Policy 
WHERE num_Of_nonClustered = 0 
AND Is_Heap = 1

DECLARE @name NVARCHAR(100)
DECLARE db_cursor CURSOR
FOR
SELECT Table_Name 
FROM #Table_Policy 
WHERE num_Of_nonClustered = 0
AND Is_Heap = 1

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @name
WHILE @@FETCH_STATUS = 0

BEGIN

DECLARE @name2 NVARCHAR(100)
DECLARE db_cursor2 CURSOR

FOR

WITH CTE
AS ( SELECT TOP 1 COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @name AND DATA_TYPE IN ( 'int' )
UNION
SELECT TOP 1 COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @name AND DATA_TYPE IN ( 'bigint' )
UNION
SELECT TOP 1 COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @name AND DATA_TYPE IN ( 'NVARCHAR' )
UNION
SELECT TOP 1 COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @name
AND DATA_TYPE IN ( 'Varchar' )
UNION
SELECT TOP 1
COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @name
AND DATA_TYPE IN ( 'Char' )
)

SELECT TOP 1
COLUMN_NAME
FROM CTE
OPEN db_cursor2
FETCH NEXT FROM db_cursor2 INTO @name2
WHILE @@FETCH_STATUS = 0

BEGIN
 
DECLARE @sch_name NVARCHAR(100)
DECLARE db_cursor3 CURSOR
FOR
SELECT Schem_Name 
FROM #Table_Policy 
WHERE num_Of_nonClustered = 0
AND Is_Heap = 1

OPEN db_cursor3
FETCH NEXT FROM db_cursor3 INTO @sch_name
WHILE @@FETCH_STATUS = 0

BEGIN

DECLARE @SQL2 NVARCHAR(MAX)= N'Create Clustered index [IX_'
+ @name + '] on ['+@sch_name+'].[' + @name + ']
(' + @name2
+ ' ASC) with (Fillfactor=80,Data_Compression=page)
GO'
PRINT @SQL2

FETCH NEXT FROM db_cursor3 INTO @sch_name
END

CLOSE db_cursor3
DEALLOCATE db_cursor3

FETCH NEXT FROM db_cursor2 INTO @name2
END

CLOSE db_cursor2
DEALLOCATE db_cursor2

FETCH NEXT FROM db_cursor INTO @name
END

CLOSE db_cursor
DEALLOCATE db_cursor
GO

DROP TABLE #Table_Policy
go