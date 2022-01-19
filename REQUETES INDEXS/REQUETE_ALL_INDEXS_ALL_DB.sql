


		
DECLARE @name VARCHAR(50) -- database name
DECLARE @Sql varchar(5000)-- Script for SQL Queries
DECLARE db_cursor CURSOR FOR
SELECT name
FROM master.dbo.sysdatabases
WHERE name  not IN ('master','model','msdb','tempdb')
OPEN db_cursor 
FETCH NEXT FROM db_cursor INTO @name 
WHILE @@FETCH_STATUS = 0 
BEGIN 
     print '--'+@name+''       
       SET @Sql='
	   USE ['+@name+']
	   GO

SELECT [DatabaseName]
    ,[ObjectId]
    ,[ObjectName]
    ,[IndexId]
    ,[IndexDescription]
    ,CONVERT(DECIMAL(16, 1), (SUM([avg_record_size_in_bytes] * [record_count]) / (1024.0 * 1024))) AS [IndexSize(MB)]
    ,[lastupdated] AS [StatisticLastUpdated]
    ,[AvgFragmentationInPercent]
FROM (
    SELECT DISTINCT DB_Name(Database_id) AS ''DatabaseName''
        ,OBJECT_ID AS ObjectId
        ,Object_Name(Object_id) AS ObjectName
        ,Index_ID AS IndexId
        ,Index_Type_Desc AS IndexDescription
        ,avg_record_size_in_bytes
        ,record_count
        ,STATS_DATE(object_id, index_id) AS ''lastupdated''
        ,CONVERT([varchar](512), round(Avg_Fragmentation_In_Percent, 3)) AS ''AvgFragmentationInPercent''
    FROM ['+@name+'].sys.dm_db_index_physical_stats(db_id(), NULL, NULL, NULL, ''detailed'')
    WHERE OBJECT_ID IS NOT NULL
        AND Avg_Fragmentation_In_Percent <> 0
    ) T
GROUP BY DatabaseName
    ,ObjectId
    ,ObjectName
    ,IndexId
    ,IndexDescription
    ,lastupdated
    ,AvgFragmentationInPercent
HAVING CONVERT(DECIMAL(16, 1), (SUM([avg_record_size_in_bytes] * [record_count]) / (1024.0 * 1024)))  >1000 
order by 6 desc 
GO'
                                           
                                           
        PRINT(@Sql)
       
     --print @name          
           
FETCH NEXT FROM db_cursor INTO @name             
           
END                                       
CLOSE db_cursor 
DEALLOCATE db_cursor