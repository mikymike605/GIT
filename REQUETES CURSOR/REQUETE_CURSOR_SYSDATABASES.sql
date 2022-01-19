DECLARE @databasesExclusion table (db varchar(128))
DECLARE @backuppath VARCHAR(4000)
DECLARE @db_id INT

--Databases exclusion list
INSERT INTO @databasesExclusion VALUES 
	('LVMM4QA1') 

SET @backuppath='NULL'

PRINT  '										'
--Backup loop

DECLARE database_cursor CURSOR FOR 
SELECT database_id FROM sys.databases 


OPEN database_cursor 

FETCH NEXT FROM database_cursor INTO @db_id 

WHILE @@FETCH_STATUS = 0 
BEGIN 
--PRINT '['+@DB_Name+']'
     PRINT '-- Base '+DB_NAME(@db_id)+'	'
     
     PRINT  (@db_id)
--SELECT @db_id=MAX(distinct database_id) FROM sys.databases 
----SELECT @db_name=(name) FROM sys.databases where @db_name is not null
----WHILE @db_name is not null
--WHILE (@db_id > 0)
--BEGIN
----IF @db_id <>34
--	IF  (SELECT db_name(@db_id) WHERE databasepropertyex(db_name(@db_id),'Updateability')='READ_WRITE' 
--	AND db_name(@db_id) IN (SELECT db FROM @databasesExclusion) ) IS NOT NULL 
--	BEGIN
--		PRINT '-- Base '+DB_NAME(@db_id)+'	'
--		PRINT @db_id	
--	END
--	SET @db_id=@db_id -1
--END
     FETCH NEXT FROM database_cursor INTO @db_id 
END 

CLOSE database_cursor 
DEALLOCATE database_cursor 