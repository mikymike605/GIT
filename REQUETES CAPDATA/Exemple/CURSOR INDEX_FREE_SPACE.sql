DECLARE @servername varchar(250) 
DECLARE @requete varchar(MAX) 
DECLARE @command VARCHAR(MAX)  
DECLARE product_cursor CURSOR FOR 


SELECT name FROM [AdminMonitor]..[Server] 

OPEN product_cursor 
FETCH FROM product_cursor INTO @SERVERNAME 

WHILE @@FETCH_STATUS = 0 
BEGIN 

SELECT @command =
'
DECLARE @DBInfo TABLE  
( ServerName VARCHAR(100),  
DatabaseName VARCHAR(100),  
FileSizeGB INT,  
LogicalFileName sysname,  
PhysicalFileName NVARCHAR(520),  
Status sysname,  
Updateability sysname,  
RecoveryMode sysname,  
FreeSpaceGB INT,  
FreeSpacePct VARCHAR(7),  
FreeSpacePages INT,  
PollDate datetime)  

DECLARE @command VARCHAR(MAX)  
SELECT @command =
 ''Use ['' + ''?'' + ''] SELECT  
@@servername as ServerName,  
'' + '''''''' + ''?'' + '''''''' + '' AS DatabaseName,  
CAST(sysfiles.size/128.0 AS int)/1000 AS FileSize,  
sysfiles.name AS LogicalFileName, sysfiles.filename AS PhysicalFileName,  
CONVERT(sysname,DatabasePropertyEx(''''?'''',''''Status'''')) AS Status,  
CONVERT(sysname,DatabasePropertyEx(''''?'''',''''Updateability'''')) AS Updateability,  
CONVERT(sysname,DatabasePropertyEx(''''?'''',''''Recovery'''')) AS RecoveryMode,  
CAST(sysfiles.size/128.0 - CAST(FILEPROPERTY(sysfiles.name, '' + '''''''' +  
       ''SpaceUsed'' + '''''''' + '' ) AS int)/128.0 AS int)/1000 AS FreeSpaceGB,  
CAST(100 * (CAST (((sysfiles.size/128.0 -CAST(FILEPROPERTY(sysfiles.name,  
'' + '''''''' + ''SpaceUsed'' + '''''''' + '' ) AS int)/128.0)/(sysfiles.size/128.0))  
AS decimal(4,2))) AS varchar(8)) + '' + '''''''' + ''%'' + '''''''' + '' AS FreeSpacePct,  
GETDATE() as PollDate FROM ['+@SERVERNAME+'].[master].dbo.sysfiles  ''
INSERT INTO @DBInfo  
   (ServerName,  
   DatabaseName,  
   FileSizeGB,  
   LogicalFileName,  
   PhysicalFileName,  
   Status,  
   Updateability,  
   RecoveryMode,  
   FreeSpaceGB,  
   FreeSpacePct,  
   PollDate)  
EXEC sp_MSforeachdb @command  

SELECT  
   ServerName,  
   DatabaseName,  
   FileSizeGB,  
   LogicalFileName,  
   PhysicalFileName,  
   Status,  
   Updateability,  
   RecoveryMode,  
   FreeSpaceGB,  
   FreeSpacePct,  
   PollDate  
FROM @DBInfo  
--where   FileSizeGB >= ''20''
ORDER BY  FreeSpacePct
'
PRINT @command 
--set @requete = 'Select * from ' + @SERVERNAME ; 

PRINT @requete 

  EXEC  (@requete) 
                                                                
FETCH FROM product_cursor INTO @SERVERNAME 
END 
CLOSE product_cursor 
DEALLOCATE product_cursor 
GO

