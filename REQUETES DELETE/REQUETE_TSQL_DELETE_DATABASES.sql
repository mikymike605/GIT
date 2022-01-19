select d.name, mf.name, mf.physical_name,'EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = ''' + d.name+''''+ CHAR(13)  + 'GO'
 + CHAR(13)  +'USE [master]'+ CHAR(13)  + 'GO'
, 'ALTER DATABASE ['+ d.name+'] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE'+ CHAR(13)  +'GO'
+ CHAR(13)  +'USE [master]'+ CHAR(13)  + 'GO' 
,'DROP DATABASE ['+ d.name+'] '+ CHAR(13)  +'GO' 
from sys.databases d
inner join sys.master_files mf on d.database_id=mf.database_id
where d.name in ('dbACPS','dbBVR','dbGFM','dbGFM_CHATEAU','dbGFM_V2','dbMaster_GFM_REC') 
and mf.type_desc='ROWS'
order by  d.name,type

--USE master;  
--GO
--IF DB_ID ( N'Music' ) IS NOT NULL
--DROP DATABASE Music;
--GO
--CREATE DATABASE Music;  
--GO
--USE master;  
--GO
--IF DB_ID ( N'Music1' ) IS NOT NULL
--DROP DATABASE Music1;
--GO
--CREATE DATABASE Music1;  
--GO
--USE master;  
--GO
--IF DB_ID ( N'Music2' ) IS NOT NULL
--DROP DATABASE Music2;
--GO
--CREATE DATABASE Music2;  
--GO
DECLARE @name VARCHAR(50); -- Database name
DECLARE @name1 VARCHAR(50); -- Database name
DECLARE @path VARCHAR(256); -- Path for backup files
DECLARE @fileName VARCHAR(256); -- Filename for backup
DECLARE @fileName1 VARCHAR(256); -- Filename for backup
DECLARE @fileDate VARCHAR(30); -- Used for file name
DECLARE @DeleteDate DATETIME =DATEADD(MINUTE,-5,GETDATE()); -- Cutoff date
--SELECT @DeleteDate
-- Path to backups.
SET @path = 'G:\bases\mssql\backup\';
-- Get date to include in file name.
--SELECT @fileDate = REPLACE (CONVERT(VARCHAR(30),GETDATE(),120),':', '') ;
SELECT @fileDate = CONVERT(VARCHAR(24),GETDATE(),112) + '_'+ 
       REPLACE(CONVERT(VARCHAR(24),GETDATE(),108),':','')
--SELECT @fileDate = CONVERT(VARCHAR(30),GETDATE(),120);
--SELECT @fileDate
-- Dynamically get each database on the server.
DECLARE db_cursor CURSOR FOR
SELECT name
FROM master.sys.databases
WHERE name NOT IN ('master','model','msdb','tempdb');
OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @name;
-- Loop through the list to backup each database.
WHILE @@FETCH_STATUS = 0
BEGIN 
      -- Build the path and file name.
      SET @fileName = @path + @name + '_' +@fileDate+ '.BAK';
      -- Backup the database.
      BACKUP DATABASE @name TO DISK = @fileName WITH INIT;
	 SET @fileName1 =  'USE [master]'+ CHAR(13)  +  CHAR(13)  +
 'ALTER DATABASE ['+ @name+'] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE'+ CHAR(13) + 
 CHAR(13)  +'USE [master]'+ CHAR(13) + CHAR(13)  +
'DROP DATABASE ['+ @name+'] '+ CHAR(13)   ;
      -- Backup the database.
	  print @fileName1
	  EXEc (@fileName1)


--DECLARE @path VARCHAR(256); -- Path for backup files
--SET @path = 'G:\bases\mssql\backup\';
--DECLARE @DeleteDate DATETIME =DATEADD(MINUTE,-5,GETDATE()); -- Cutoff date
------SELECT @DeleteDate
------ Path to backups.
--SET @path = 'G:\bases\mssql\backup\';
-- ----Purge old backup files from disk.
EXEC master.sys.xp_delete_file 0,@path,'BAK',@DeleteDate,0;

EXEC master.sys.xp_delete_file 0,@path,'TRN',@DeleteDate,0;
---- Clean up.

      FETCH NEXT FROM db_cursor INTO @name;
--END 
END
CLOSE db_cursor;
DEALLOCATE db_cursor;

--END


