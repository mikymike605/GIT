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
     SELECT @Command = --@DB_Name
          'USE 
['+@DB_Name+']
select  
--''print ''''''+ f.name+''''''; USE ''+''['+@DB_Name+']''+'' DBCC SHRINKFILE (N'''''' + f.name+'''''',0) ;'',
''DECLARE @shrink int set @shrink = ''+cast(f.size/128 as varchar(50))+''
	while @shrink >0 BEGIN DBCC SHRINKFILE (''''''+f.name+'''''' , @shrink) set @shrink = @shrink - 100 END print ''''''+ f.name+''''''; USE '+'['+DB_NAME()+']'+' DBCC SHRINKFILE (N'''''' + f.name+'''''',0) ;''
,@@servername
    ,f.type_desc as [Type]
    , f.name as [FileName]
    ,fg.name as [FileGroup]
    ,f.physical_name as [Path]
    ,f.size / 128.0 as [CurrentSizeMB]
    ,f.size /128.0 - convert(int,fileproperty(f.name,''SpaceUsed''))/128.0 as [FreeSpaceMb]
	,[TimeStamp]=getdate()
from 
    sys.database_files f with (nolock) left outer join 
      sys.filegroups fg with (nolock) on
            f.data_space_id = fg.data_space_id
            where f.size /128.0 - convert(int,fileproperty(f.name,''SpaceUsed''))/128.0 >1000
            and f.type_desc not in (''LOG'')
order by 8 desc 
option (recompile)
--UNION ALL
'
     
     exec  (@Command)

     FETCH NEXT FROM database_cursor INTO @DB_Name 
END 

CLOSE database_cursor 
DEALLOCATE database_cursor 