DECLARE @OldSchema VARCHAR(200)
DECLARE @NewSchema VARCHAR(200)
DECLARE @SQL nvarchar(4000)
SET @OldSchema = 'dbo'
SET @NewSchema = 'Inf'

DECLARE tableCursor CURSOR FAST_FORWARD FOR 
    SELECT 'ALTER SCHEMA  ['+ @NewSchema +'] TRANSFER [' + SysSchemas.Name + '].[' + DbObjects.Name + '];' AS Cmd
    FROM sys.Objects DbObjects
    INNER JOIN sys.Schemas SysSchemas ON DbObjects.schema_id = SysSchemas.schema_id
    WHERE SysSchemas.Name = @OldSchema
    AND (DbObjects.Type IN ('U', 'P', 'V'))
OPEN tableCursor 
FETCH NEXT FROM tableCursor INTO  @SQL
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @SQL
    --EXEC (@SQL)
    FETCH NEXT FROM tableCursor INTO  @SQL
END
CLOSE tableCursor 
DEALLOCATE tableCursor 
PRINT '*** Finished ***'