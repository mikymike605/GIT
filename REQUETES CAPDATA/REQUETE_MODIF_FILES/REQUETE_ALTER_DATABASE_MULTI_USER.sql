select physical_name,name from sys.master_files
where physical_name like 'D:\%'

select physical_name,name from sys.master_files
where physical_name like 'E:\%'


select physical_name,name from sys.master_files
where physical_name like 'L:\%'



SELECT ' ALTER DATABASE ' +d.name+ ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
'
from sys.databases d
inner join sys.master_files m
on d.database_id=m.database_id
where physical_name like 'E:\%'
and file_id=1
and d.state_desc = 'online'

SELECT ' ALTER DATABASE ' +d.name+ ' SET OFFLINE
GO
'
from sys.databases d
inner join sys.master_files m
on d.database_id=m.database_id
where physical_name like 'E:\%'
and file_id=1
and d.state_desc = 'online'

SELECT ' ALTER DATABASE [' +d.name+ '] SET ONLINE
GO
'
from sys.databases d
inner join sys.master_files m
on d.database_id=m.database_id
where physical_name like 'E:\%'
and file_id=1
and d.state_desc = 'online'

SELECT ' ALTER DATABASE [' +d.name+ '] SET MULTI_USER
GO
'
from sys.databases d
inner join sys.master_files m
on d.database_id=m.database_id
where physical_name like 'E:\%'
and file_id=1
and d.state_desc = 'online'



SELECT name as [logical_file_name], physical_name
from sys.master_files

 ALTER DATABASE AdminSQL SET SINGLE_USER WITH ROLLBACK IMMEDIATE  
 GO  
 ALTER DATABASE AdminSQL SET OFFLINE  
 GO  
 ALTER DATABASE AdminSQL MODIFY FILE (Name='AdminSQL', FILENAME='E:\AdminSQL.mdf')  
 GO  
 ALTER DATABASE AdminSQL MODIFY FILE (Name='AdminSQL_log', FILENAME='L:\AdminSQL_log.ldf')  
 GO  
 ALTER DATABASE AdminSQL SET ONLINE  
 GO  
 ALTER DATABASE AdminSQL SET MULTI_USER  
 GO  
