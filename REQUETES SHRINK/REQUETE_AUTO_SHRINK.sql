--2011.03.04 version

SET NOCOUNT ON

DECLARE @dbName varchar(40)

DECLARE @maxfrag DECIMAL
SET @maxfrag = 95    -- index will be reindex if ScanDensity < 95%

DECLARE @maxLogicalFrag DECIMAL

SET @maxLogicalFrag = 3    -- index will be reindex if Logical Scan Fragmentation > 3%
-- Therefore, perfect index will not be re-index again to save time.

DECLARE @TableName varchar(255)
DECLARE @IndexName varchar(255)
DECLARE @TableId int
DECLARE @IndexId int
DECLARE @FileName varchar(50), @FileSize int, @FileGrowth int
DECLARE @sql nvarchar(1500)
DECLARE @starttime datetime
-----------
  
-- Create the temporary table to hold fragmentation information
drop table tempdb..fraglist

CREATE TABLE tempdb..fraglist (
ObjectName CHAR (255),
ObjectId INT,
IndexName CHAR (255),
IndexId INT,
Lvl INT,
CountPages INT,
CountRows INT,
MinRecSize INT,
MaxRecSize INT,
AvgRecSize INT,
ForRecCount INT,
Extents INT,
ExtentSwitches INT,
AvgFreeBytes INT,
AvgPageDensity INT,
ScanDensity DECIMAL,
BestCount INT,
ActualCount INT,
LogicalFrag DECIMAL,
ExtentFrag DECIMAL)

----------
DECLARE dbCursor CURSOR FOR
SELECT NAME --DB_NAME(dbid) AS DB_NAME
FROM master.dbo.sysdatabases
WHERE 
NAME IN ('SID_PRD')  --The cursor is a list for the DB to be show
                                  --shrinked /reindex 
ORDER BY NAME DESC

--select * from master.dbo.sysdatabases --show all databases in the SQL server

OPEN dbCursor

FETCH NEXT FROM dbCursor INTO @dbName
WHILE @@FETCH_STATUS = 0
BEGIN
   
    set @starttime = getdate()
    PRINT convert(varchar(30), @starttime, 120) + ': Job Started - ' + @dbName
  
    PRINT convert(varchar(30), getdate(), 120) + ': Truncate Log started'

    set @sql = 'select rtrim(name) as name, size, growth'
    set @sql = @sql + ' INTO tempdb..temp_File '
    set @sql = @sql + ' FROM "' + @dbName + '".dbo.sysfiles '
    set @sql = @sql + ' WHERE groupid > 1'
    drop table tempdb..temp_File
    exec sp_executesql @sql

    DECLARE FileCursor CURSOR FOR
    select * from tempdb..temp_File

    OPEN FileCursor
    FETCH NEXT FROM FileCursor INTO @FileName, @FileSize, @FileGrowth
    WHILE @@FETCH_STATUS = 0
    BEGIN  
        print convert(varchar(30), getdate(), 120) + ': '+ @FileName + ': File Size before shrink: ' + convert(varchar(20), @FileSize) + '; FileGrowth : ' + convert(varchar(20), @FileGrowth)
        set @sql = 'alter database ' + @dbName + ' modify file (NAME = ' + @FileName + ', FILEGROWTH =300MB)'   -- will grow 300MB each time when running out of space
        print @sql
        exec sp_executesql @sql 
        set @sql = 'USE ' + @dbName  + '; DBCC SHRINKFILE (' + @FileName + ', 10) ' -- Shrink to target size 10MB only
        print @sql
        exec sp_executesql @sql 
        FETCH NEXT FROM FileCursor INTO @FileName, @FileSize, @FileGrowth
    END
    CLOSE FileCursor
    DEALLOCATE FileCursor

   -- Report the file size after file shrink
    set @sql = 'select rtrim(name) as name, size, growth'
    set @sql = @sql + ' INTO tempdb..temp_File '
    set @sql = @sql + ' FROM "' + @dbName + '".dbo.sysfiles '
    drop table tempdb..temp_File
    exec sp_executesql @sql

    DECLARE FileCursor CURSOR FOR
    select * from tempdb..temp_File

    OPEN FileCursor
    FETCH NEXT FROM FileCursor INTO @FileName, @FileSize, @FileGrowth
    WHILE @@FETCH_STATUS = 0
    BEGIN  
        print convert(varchar(30), getdate(), 120) + ': '+  @FileName + ': File size after shrink: ' + convert(varchar(20), @FileSize) + '; FileGrowth : ' + convert(varchar(20), @FileGrowth)
        FETCH NEXT FROM FileCursor INTO @FileName, @FileSize, @FileGrowth
    END
    CLOSE FileCursor
    DEALLOCATE FileCursor  --End all Shrink file operation

    --Start reindex
    set @starttime = getdate()
    PRINT convert(varchar(30), @starttime, 120) + ': Reindex Job Started - ' + @dbName

    --Get all the tables  into a cursor TableCursor
    set @sql = 'SELECT T.name as tblname, I.name as indexname, T.id, I.indid '
    set @sql = @sql + ' INTO tempdb..temp_table '
    set @sql = @sql + ' FROM "' + @dbName + '".dbo.sysobjects T '
    set @sql = @sql + ' LEFT OUTER JOIN "' + @dbName + '".dbo.sysindexes I ON T.id = I.id '
    set @sql = @sql + ' where type = ''U'' and I.indid < 2 and rowcnt > 0 '
    set @sql = @sql + ' AND INDEXPROPERTY (T.id, I.name, ''IndexDepth'') > 0 '
    set @sql = @sql + ' order by T.name, I.indid'

    print @sql
    drop table tempdb..temp_table
    exec sp_executesql @sql

    DECLARE TableCursor CURSOR FOR
    select * from tempdb..temp_table
   
    OPEN TableCursor

    truncate table tempdb..fraglist
    FETCH NEXT FROM TableCursor INTO @TableName, @IndexName , @TableId, @IndexId
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Do the showcontig of all indexes of the table
        INSERT INTO tempdb..fraglist
        EXEC ('USE ' +@dbName + '; DBCC SHOWCONTIG (' + @TableName + ') WITH FAST, TABLERESULTS, ALL_INDEXES, NO_INFOMSGS')
        FETCH NEXT FROM TableCursor INTO @TableName, @IndexName , @TableId, @IndexId
    END

    CLOSE TableCursor
    DEALLOCATE TableCursor

    -- break   

    DECLARE FragListCursor CURSOR FOR
    select ObjectName, IndexName, ObjectId, IndexId
        from tempdb..fraglist
        where IndexId < 255 and IndexId > 0
            and IndexName is not null
            and  (ScanDensity <= @maxfrag
                    or LogicalFrag >=@maxLogicalFrag)
    OPEN FragListCursor

    FETCH NEXT FROM FragListCursor INTO @TableName, @IndexName , @TableId, @IndexId
    WHILE @@FETCH_STATUS = 0
    BEGIN
       

        set @sql = 'DBCC DBREINDEX(''' + @dbName + '.dbo.' + rtrim(@TableName) + ''', ''' + rtrim(@IndexName) + ''' ,100) WITH NO_INFOMSGS '  -- fill factore = 100%.  Only good for read-only database
        print convert(varchar(30), getdate(), 120) +': ' + @sql
        exec sp_executesql @sql -- debug
   
        set @sql =  'USE ' + @dbName + ';'+ 'update statistics ' + rtrim(@TableName) + ' ' + rtrim(@IndexName)
        exec sp_executesql @sql -- debug
   
        FETCH NEXT FROM FragListCursor INTO @TableName, @IndexName , @TableId, @IndexId
    END
   
    CLOSE FragListCursor
    DEALLOCATE FragListCursor

    --The database will be grow again after re-index.  It is useful to shrink the database again.  The TRUNCATEONLY option will prevent SQL server to claim free space in the middle of the file and prevent further index fragmentation.
    --DBCC SHRINKDATABASE(@dbName, 10, TRUNCATEONLY)

    set @sql = 'select rtrim(name) as name, size, growth'
    set @sql = @sql + ' INTO tempdb..temp_File '
    set @sql = @sql + ' FROM "' + @dbName + '".dbo.sysfiles '
    set @sql = @sql + ' WHERE groupid = 0'   -- GroupID=0 --> Log File
    drop table tempdb..temp_File
    exec sp_executesql @sql

    DECLARE FileCursor CURSOR FOR
    select * from tempdb..temp_File

    OPEN FileCursor
    FETCH NEXT FROM FileCursor INTO @FileName, @FileSize, @FileGrowth
    WHILE @@FETCH_STATUS = 0
    BEGIN  
        print convert(varchar(30), getdate(), 120) + ': '+ @FileName + ': File Size before shrink: ' + convert(varchar(20), @FileSize) + '; FileGrowth : ' + convert(varchar(20), @FileGrowth)
        set @sql = 'alter database ' + @dbName + ' modify file (NAME = ' + @FileName + ', FILEGROWTH =100MB)'
        print @sql
        exec sp_executesql @sql -- debug
        set @sql = 'USE ' + @dbName  + '; DBCC SHRINKFILE (' + @FileName + ', 10) ' -- Shrink to 10MB only
        print @sql
        exec sp_executesql @sql --debug
        FETCH NEXT FROM FileCursor INTO @FileName, @FileSize, @FileGrowth
    END
    CLOSE FileCursor
    DEALLOCATE FileCursor

   PRINT convert(varchar(30), getdate(), 120) + ': Reindex Job Ended. It took ' + convert(varchar(6), datediff(hh, @starttime, getdate())) +' to complete the job.'

    FETCH NEXT FROM dbCursor INTO @dbName
END
CLOSE dbCursor
DEALLOCATE dbCursor