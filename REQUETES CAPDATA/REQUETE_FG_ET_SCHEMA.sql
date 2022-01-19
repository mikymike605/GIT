SELECT s.name as SchemaName ,o.[name] as TableName, o.[type],  i.[index_id],i.name as IndexName, f.[name] as FgName 
FROM sys.indexes i 
INNER JOIN sys.filegroups f ON i.data_space_id = f.data_space_id 
INNER JOIN sys.all_objects o ON i.[object_id] = o.[object_id] 
INNER JOIN sys.tables t ON t.object_id=o.object_id 
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id 
WHERE i.data_space_id = f.data_space_id AND o.type = 'U' -- User Created Tables 
ORDER BY 1,2,4
