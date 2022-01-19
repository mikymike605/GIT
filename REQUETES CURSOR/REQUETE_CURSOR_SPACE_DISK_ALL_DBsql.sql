DECLARE @DB_Name varchar(100) 
DECLARE @Command varchar(MAX) 
DECLARE database_cursor CURSOR FOR 
SELECT name 
FROM MASTER.sys.sysdatabases where dbid >6 order by 1

/*
DECLARE @shrink int 
declare @command varchar (max)

set @shrink = 117506
	while @shrink >0 
	BEGIN 
	SELECT @command='DBCC SHRINKFILE (''SID_PRD_SAS_DATA'','+cast(@shrink as varchar(50))+') '
	PRINT @command
	set @shrink = @shrink - 100 
END 
*/

OPEN database_cursor 

FETCH NEXT FROM database_cursor INTO @DB_Name 

WHILE @@FETCH_STATUS = 0 
BEGIN 
--PRINT '['+@DB_Name+']'
     SELECT @Command = --@DB_Name
'USE ['+@DB_Name+']
DECLARE @dbsize bigint 
DECLARE @logsize bigint 
DECLARE @ftsize bigint 
set @dbsize = 1
set @logsize = 1
set @ftsize = 1 

SELECT @dbsize = SUM(convert(bigint,case when type = 0 then size else 0 end)) 
      ,@logsize = SUM(convert(bigint,case when type = 1 then size else 0 end)) 
      ,@ftsize = SUM(convert(bigint,case when type = 4 then size else 0 end)) 
	   
FROM sys.database_files

--print @dbsize
--print @logsize
--print @ftsize
'
     
     EXEC  (@Command)

     FETCH NEXT FROM database_cursor INTO @DB_Name 
END 

CLOSE database_cursor 
DEALLOCATE database_cursor 