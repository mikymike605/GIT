USE master
GO 

CREATE TABLE #TMPFIXEDDRIVES ( DRIVE CHAR(1), MBFREE INT) 

INSERT INTO #TMPFIXEDDRIVES 
EXEC xp_FIXEDDRIVES 

CREATE TABLE #TMPSPACEUSED ( DBNAME VARCHAR(50), FILENME VARCHAR(50), SPACEUSED FLOAT) 

INSERT INTO #TMPSPACEUSED 
EXEC( 'sp_msforeachdb''use [?]; Select ''''?'''' DBName, Name FileNme, fileproperty(Name,''''SpaceUsed'''') SpaceUsed from sysfiles''') 

SELECT   C.DRIVE, 
         CASE  
           WHEN (C.MBFREE) > 1000 THEN CAST(CAST(((C.MBFREE) / 1024.0) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' GB' 
           ELSE CAST(CAST((C.MBFREE) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' MB' 
           END AS DISKSPACEFREE, 
         A.NAME AS DATABASENAME, 
         B.NAME AS FILENAME, 
         CASE B.TYPE  
           WHEN 0 THEN 'DATA' 
           ELSE TYPE_DESC 
           END AS FILETYPE, 
         CASE  
           WHEN (B.SIZE * 8 / 1024.0) > 1000 
           THEN CAST(CAST(((B.SIZE * 8 / 1024) / 1024.0) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' GB' 
           ELSE CAST(CAST((B.SIZE * 8 / 1024.0) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' MB' 
           END AS FILESIZE, 
         CAST((B.SIZE * 8 / 1024.0) - (D.SPACEUSED / 128.0) AS DECIMAL(15,2)) SPACEFREE, 
         B.PHYSICAL_NAME ,
		  'DECLARE @shrink int set @shrink = '+cast(B.size/128 as varchar(50))+' 
	while @shrink >0 BEGIN DBCC SHRINKFILE ('''+B.name+''' , @shrink) set @shrink = @shrink - 1000 END --print '''+ B.name+'''; USE '+'['+DB_NAME()+']'+' DBCC SHRINKFILE (N''' + B.name+''',0) ;'
    
FROM     SYS.DATABASES A 
         JOIN SYS.MASTER_FILES B ON A.DATABASE_ID = B.DATABASE_ID 
         JOIN #TMPFIXEDDRIVES C  ON LEFT(B.PHYSICAL_NAME,1) = C.DRIVE 
         JOIN #TMPSPACEUSED D    ON A.NAME = D.DBNAME AND B.NAME = D.FILENME 
ORDER BY DISKSPACEFREE, 
         SPACEFREE DESC 
          
DROP TABLE #TMPFIXEDDRIVES 

DROP TABLE #TMPSPACEUSED 