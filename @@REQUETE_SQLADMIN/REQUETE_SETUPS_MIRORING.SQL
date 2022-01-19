--Execute the following T-SQL to set recovery mode:

USE master;
GO
ALTER DATABASE AdminSQL SET RECOVERY FULL;

--We then first backup the database

USE master;
GO

BACKUP DATABASE AdminSQL
TO DISK = '\\SQLTST999\Share_SQL\AdminSQL.bak'
WITH FORMAT
GO

--and afterwards the log:

USE master;
GO

BACKUP LOG AdminSQL
TO DISK = '\\SQLTST999\Share_SQL\AdminSQL_log.bak'

GO


ALTER DATABASE [AdminSQL] SET PARTNER = 'TCP://SQLTST999:5022' ---==========> BACKUP SECONDAIRE à lencer en deuxième 

--Copy the files to the mirror partner (SP-SQL2). Ensure they are placed in the same location, e.g. F:\BackUp in the above example. It is not a requirement, but the syntax of the T-SQL is slightly different if the location is different.

--Connect to the mirror partner (SP-SQL2) from the open Management Studio or RDP into the server and open SSMS from here.

--First we restore the database

USE master;
GO

RESTORE DATABASE AdminSQL
FROM DISK = 'C:\Share_SQL\AdminSQL.bak'
WITH NORECOVERY
GO

--and then the log

USE master;
GO

RESTORE LOG AdminSQL
FROM DISK = 'C:\Share_SQL\AdminSQL_log.bak'
WITH FILE=1, NORECOVERY
GO


ALTER DATABASE [AdminSQL] SET PARTNER = 'TCP://SQLTST998:5022' ---==========> BACKUP PRINCIPALE à lancer en premier