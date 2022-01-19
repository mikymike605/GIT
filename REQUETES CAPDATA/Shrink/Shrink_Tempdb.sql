SELECT name, size
FROM sys.master_files
WHERE database_id = DB_ID(N'tempdb')

DBCC SHRINKFILE(tempdev, 5)


USE master;
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = tempdev, SIZE=10Mb);
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = templog, SIZE=10Mb);
GO
