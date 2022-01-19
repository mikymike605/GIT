DECLARE cursore CURSOR FOR 


select specific_schema as 'schema', specific_name AS 'name'
FROM INFORMATION_SCHEMA.routines
WHERE specific_schema = 'MIG' 

UNION ALL

SELECT TABLE_SCHEMA AS 'schema', TABLE_NAME AS 'name'
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'MIG'  



DECLARE @schema sysname, 
 @sql varchar(500) 

 @tab sysname, 

OPEN cursore     
FETCH NEXT FROM cursore INTO @schema, @tab 

WHILE @@FETCH_STATUS = 0     
BEGIN 
 SET @sql = 'ALTER SCHEMA ODS TRANSFER [' + @schema + '].[' + @tab +']'    
 PRINT @sql   
 --exec (@sql)  
 FETCH NEXT FROM cursore INTO @schema, @tab     
END 

CLOSE cursore     
DEALLOCATE cursore