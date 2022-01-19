SELECT ' ALTER DATABASE ' +d.name+ ' MODIFY FILE (Name='''+d.name+''', FILENAME=''E:\'+m.name+'.mdf'')
GO
'
--SELECT *
--from sys.master_files
from sys.databases d
inner join sys.master_files m
on d.database_id=m.database_id
where physical_name like 'E:\%'
and file_id=1
and d.state_desc = 'online'


SELECT ' ALTER DATABASE ' +d.name+ ' MODIFY FILE (Name='''+d.name+''', FILENAME=''E:\'+m.name+'.ndf'')
GO
'
--SELECT *
--from sys.master_files
from sys.databases d
inner join sys.master_files m
on d.database_id=m.database_id
where physical_name like 'E:\%'
and file_id<>1
and d.state_desc = 'online'

SELECT ' ALTER DATABASE ' +d.name+ ' MODIFY FILE (Name='''+d.name+''', FILENAME=''L:\'+m.name+'.ldf'')
GO
'
--SELECT * 
--from sys.master_files
from sys.databases d
inner join sys.master_files m
on d.database_id=m.database_id
where physical_name like 'L:\%'
and d.state_desc = 'online'


SELECT d.name as [Database_Name], d.state_desc,m.physical_name,* from sys.databases d
inner join sys.master_files m
on d.database_id=m.database_id




--ALTER DATABASE Manvendra MODIFY FILE (Name='Manvendra', FILENAME='F:\MSSQL12.MSSQLSERVER\MSSQL\DATA\Manvendra_Renamed.mdf')
--GO
--ALTER DATABASE Manvendra MODIFY FILE (Name='Manvendra_1', FILENAME='F:\MSSQL12.MSSQLSERVER\MSSQL\DATA\Manvendra_1_Renamed.ndf')
--GO
--ALTER DATABASE Manvendra MODIFY FILE (Name='Manvendra_2', FILENAME='F:\MSSQL12.MSSQLSERVER\MSSQL\DATA\Manvendra_2_Renamed.ndf')
--GO
--ALTER DATABASE Manvendra MODIFY FILE (Name='Manvendra_log', FILENAME='F:\MSSQL12.MSSQLSERVER\MSSQL\DATA\Manvendra_log_Renamed.ldf')
--GO
