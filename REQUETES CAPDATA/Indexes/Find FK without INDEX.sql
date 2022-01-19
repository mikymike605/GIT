
IF OBJECT_ID('tempdb..#t1') IS NOT NULL DROP TABLE #t1

IF OBJECT_ID('tempdb..#FKTable') IS NOT NULL DROP TABLE #FKTable

--Create index temp table
CREATE TABLE #t1
 ( do integer default(0), 
 index_name varchar(1000), 
 index_descrip varchar(2000), 
 index_keys varchar(2000), 
 table_name varchar(1000)) 

 --Create FK temp table 
 CREATE TABLE #FKTable
 ( fk_name varchar(1000), 
 fk_keys varchar(2000), 
 fk_keyno int,
 table_name varchar(1000)) 

--Collect and uppdate all index info 
EXEC sp_msforeachtable "insert #t1 (index_name, index_descrip, index_keys) exec sp_helpindex '?'; update #t1 set table_name = '?', do = 1 where do = 0"
UPDATE #t1 SET table_name = replace(table_name , '[', '')
UPDATE #t1 set table_name = replace(table_name , ']', '')


--Collect all index info 
INSERT INTO #FKTable
SELECT OBJECT_NAME(constid) AS FKName, COL_NAME(fkeyid, fkey) AS FKColumn, keyno, 
s.name + '.' + OBJECT_NAME(fkeyid) AS TabName
FROM sysforeignkeys k 
JOIN sys.objects c 
ON k.constid = c.object_id
JOIN sys.schemas s
ON c.schema_id = s.schema_id


--If FK have two or more columns add them in one row to be able to compare with index columns. 

DECLARE @FKName AS VARCHAR(200), @FKColumn as VARCHAR(100)

DECLARE FKCurusor CURSOR FOR
SELECT OBJECT_NAME(constid) AS FKName, COL_NAME(fkeyid, fkey) AS FKColumn
FROM sysforeignkeys k 
JOIN sysobjects c 
ON k.constid = c.id
WHERE keyno > 1
ORDER BY keyno 

 DELETE FROM #FKTable WHERE fk_keyno > 1 

 OPEN FKCurusor
	FETCH NEXT FROM FKCurusor INTO @FKName,@FKColumn
	WHILE (@@FETCH_STATUS = 0)
	BEGIN

	UPDATE #FKTable SET 
	fk_keys = fk_keys + ', ' + @FKColumn 
	WHERE fk_name = @FKName


	FETCH NEXT FROM FKCurusor INTO @FKName,@FKColumn

	END 

CLOSE FKCurusor
DEALLOCATE FKCurusor
/*
SELECT * FROM #FKTable
ORDER BY table_name

SELECT * FROM #t1
ORDER BY table_name
*/
PRINT '
---------------------------------------------------------------------
FK MISSING Indexes
----------------------------------------------------------------------------
'

SELECT DISTINCT table_name, fk_name 
FROM #FKTable f1
WHERE NOT EXISTS (
SELECT fk_name 
FROM #FKTable f
INNER JOIN #t1 t
ON f.table_name = t.table_name
WHERE f1.fk_name = f.fk_name
AND fk_keys = index_keys
)