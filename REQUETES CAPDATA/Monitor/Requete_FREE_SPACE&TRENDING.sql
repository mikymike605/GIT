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

DECLARE @command VARCHAR(5000)  

SELECT @command = 'Use [' + '?' + '] SELECT  
@@servername as ServerName,  
' + '''' + '?' + '''' + ' AS DatabaseName,  
CAST(sysfiles.size/128.0 AS int)/1000 AS FileSize,  
sysfiles.name AS LogicalFileName, sysfiles.filename AS PhysicalFileName,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Status'')) AS Status,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Updateability'')) AS Updateability,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Recovery'')) AS RecoveryMode,  
CAST(sysfiles.size/128.0 - CAST(FILEPROPERTY(sysfiles.name, ' + '''' +  
       'SpaceUsed' + '''' + ' ) AS int)/128.0 AS int)/1000 AS FreeSpaceGB,  
CAST(100 * (CAST (((sysfiles.size/128.0 -CAST(FILEPROPERTY(sysfiles.name,  
' + '''' + 'SpaceUsed' + '''' + ' ) AS int)/128.0)/(sysfiles.size/128.0))  
AS decimal(4,2))) AS varchar(8)) + ' + '''' + '%' + '''' + ' AS FreeSpacePct,  
GETDATE() as PollDate FROM dbo.sysfiles'  
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
--where ServerName = 'AUBFRCOGNOSSQL'
--and DatabaseName='ODS'
where  FreeSpaceGB >= '20'
ORDER BY  FreeSpacePct