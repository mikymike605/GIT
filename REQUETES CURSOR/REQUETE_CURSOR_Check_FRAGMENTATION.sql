DECLARE @name varchar(250) 
DECLARE @requete varchar(MAX) 
DECLARE @command VARCHAR(MAX)  
DECLARE product_cursor CURSOR FOR 


SELECT dbid FROM SYs.SYSDATABASES where name not in ('master','tempdb','model','msdb','ReportServer','ReportServerTempDB')   

OPEN product_cursor 
FETCH FROM product_cursor INTO @NAME 
print @name

WHILE @@FETCH_STATUS = 0 
BEGIN 

 SELECT @command = '
	   Select 
       schemas.[name] AS SchemaName,
       objects.[name] AS ObjectName,
       indexes.[name] AS IndexName,
       objects.type_desc AS ObjectType,
       indexes.type_desc AS IndexType,
       dm_db_index_physical_stats.partition_number AS PartitionNumber,
       dm_db_index_physical_stats.page_count AS [PageCount],
       dm_db_index_physical_stats.avg_fragmentation_in_percent AS AvgFragmentationInPercent
FROM sys.dm_db_index_physical_stats ('+@name+', NULL, NULL, NULL, ''LIMITED'') dm_db_index_physical_stats
INNER JOIN sys.indexes indexes ON dm_db_index_physical_stats.[object_id] = indexes.[object_id] AND dm_db_index_physical_stats.index_id = indexes.index_id
INNER JOIN sys.objects objects ON indexes.[object_id] = objects.[object_id]
INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id]
WHERE objects.[type] IN(''U'',''V'')
AND objects.is_ms_shipped = 0
AND indexes.[type] IN(1,2,3,4)
AND indexes.is_disabled = 0
AND indexes.is_hypothetical = 0
AND dm_db_index_physical_stats.alloc_unit_type_desc = ''IN_ROW_DATA''
AND dm_db_index_physical_stats.index_level = 0
AND dm_db_index_physical_stats.page_count >= 1000
and avg_fragmentation_in_percent >=30
and indexes.[name] is not null
ORDER BY avg_fragmentation_in_percent desc
	   '
	   
PRINT @command 
--set @requete = 'Select * from ' + @SERVERNAME ; 

PRINT @requete 

  --EXEC  (@requete) 
                                                                
FETCH FROM product_cursor INTO @NAME 
END 
CLOSE product_cursor 
DEALLOCATE product_cursor 
GO

