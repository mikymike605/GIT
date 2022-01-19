

 IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL 
        DROP TABLE tempdb..#TEMP
 IF OBJECT_ID('tempdb..#TEMP1') IS NOT NULL 
        DROP TABLE tempdb..#TEMP1
IF OBJECT_ID('tempdb..#MAIN') IS NOT NULL 
        DROP TABLE tempdb..#MAIN
		
		
DECLARE @NAME VARCHAR(50) -- database name
DECLARE @DATABASENAME VARCHAR(50) -- database name
DECLARE @SCHEMANAME VARCHAR(50) -- Schema name
DECLARE @TABLENAME VARCHAR(1000) -- table name
DECLARE @INDEXNAME VARCHAR(1000) -- index name
DECLARE @Sql varchar(5000)-- Script for SQL Queries
DECLARE @Sql1 varchar(5000)-- Script for SQL Queries
DECLARE @dbid int-- Database DB Id
DECLARE @objid int-- Database Object Id
--create #temp,#temp1 tables for operation
CREATE TABLE #TEMP (DATABASENAME VARCHAR(50),SCHEMANAME VARCHAR(50),TABLENAME VARCHAR(1000),ObjId int,INDEXNAME VARCHAR(1000),INDEXID INT)
CREATE TABLE #TEMP1 (DATABASENAME VARCHAR(50),SCHEMANAME VARCHAR(50),TABLENAME VARCHAR(1000),INDEX_ID INT,FRAG_VAL DECIMAL(8,3))
DECLARE db_cursor CURSOR FOR
SELECT name
FROM master.dbo.sysdatabases
WHERE name  not IN ('master','model','msdb','tempdb')
OPEN db_cursor 
FETCH NEXT FROM db_cursor INTO @name 
WHILE @@FETCH_STATUS = 0 
BEGIN 
       SET @Sql='USE '+@NAME+'  INSERT INTO #TEMP  select '''+@NAME+''' AS DATABASENAME,s.name as SCHEMANAME,
                                o.name as TableName,o.object_id objid,i.name as IndexName,I.INDEX_ID 
                                from sys.indexes i
                                join sys.objects o on i.object_id = o.object_id
								join sys.schemas s on o.schema_id = s.schema_id
                                where o.[type] = ''U'' order by o.[name], i.[name]'
                                           
                                           
        EXEC(@Sql)
       
               
           
FETCH NEXT FROM db_cursor INTO @name             
           
END                                       
CLOSE db_cursor 
DEALLOCATE db_cursor
DECLARE db_cursor1 CURSOR FOR SELECT DISTINCT DATABASENAME,SCHEMANAME,TABLENAME,OBJID FROM #TEMP ORDER BY DATABASENAME,SCHEMANAME,TABLENAME
OPEN db_cursor1 
FETCH NEXT FROM db_cursor1 INTO @DATABASENAME,@SCHEMANAME,@TABLENAME,@objid 
WHILE @@FETCH_STATUS = 0 
BEGIN 
SET @dbid=DB_ID(@DATABASENAME)
 
SET @Sql='USE '+@DATABASENAME+' INSERT INTO #TEMP1 SELECT '''+@DATABASENAME+''' DATABASENAME,'''+@TABLENAME+''' TABLENAME,s.name,a.index_id INDEX_ID,avg_fragmentation_in_percent FRAG_VAL
FROM sys.dm_db_index_physical_stats ('+cast(@dbid as varchar(100))+', '+cast(@objid as varchar(100))+', NULL, NULL, NULL) AS a
    JOIN sys.indexes AS b ON a.object_id = b.object_id AND a.index_id = b.index_id 
	join sys.objects o on b.object_id = o.object_id
	join sys.schemas as s on o.schema_id=s.schema_id
	where b.index_id > 0
	and a.page_count>1280;'
EXEC(@Sql)
--PRINT (@SQL)
FETCH NEXT FROM db_cursor1 INTO @DATABASENAME,@SCHEMANAME,@TABLENAME,@objid 
END
CLOSE db_cursor1 
DEALLOCATE db_cursor1
--operation of rebuild or reorganize based on avg_fragmentation_in_percent
--avg_fragmentation_in_percent >30 % then rebuild
--avg_fragmentation_in_percent <30 % then reorganize
SELECT
       'ALTER INDEX ['+A.INDEXNAME+'] ON '+A.DATABASENAME+'.'+A.SCHEMANAME+'.'+A.TABLENAME+CASE WHEN B.FRAG_VAL >30 THEN ' REBUILD' ELSE ' REORGANIZE' END [sql],A.INDEXNAME INDEXNAME INTO #MAIN
      --'+A.DATABASENAME+'.'+'dbo.'+A.TABLENAME+
FROM     #TEMP A INNER JOIN #TEMP1 B
        ON A.DATABASENAME=B.DATABASENAME
       
        AND A.TABLENAME=B.TABLENAME
       
        AND A.INDEXID=B.INDEX_ID
DECLARE db_cursor2 CURSOR FOR
SELECT [SQL],INDEXNAME FROM #MAIN WHERE [sql] IS NOT NULL
OPEN db_cursor2 
FETCH NEXT FROM db_cursor2 INTO @SQL,@INDEXNAME 
WHILE @@FETCH_STATUS = 0 
BEGIN
        PRINT 'PROCESS ON '+@INDEXNAME
       
        EXEC(@SQL)
		--PRINT (@SQL)
       
        PRINT 'PROCESS COMPLETED '+@INDEXNAME
       
        FETCH NEXT FROM db_cursor2 INTO @SQL,@INDEXNAME 
END
CLOSE db_cursor2 
DEALLOCATE db_cursor2