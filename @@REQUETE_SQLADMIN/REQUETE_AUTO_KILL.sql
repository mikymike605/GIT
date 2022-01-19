/******************************************
Script By: Adriano Boller
Purpose: To detect long running sessions,
send complete information through mail about such sessions
and killing session, which are acceding given limit of execution time.
******************************************/
USE master
GO

SET NOCOUNT ON

-- 1 - Variable Declaration
DECLARE @DBID int
DECLARE @CMD1 VARCHAR(8000)
DECLARE @spidNumber int
DECLARE @SpidListLoop int
DECLARE @SpidListTable TABLE
(UIDSpidList int IDENTITY (1,1),
SpidNumber int)

-- 2 - Populate @SpidListTable with the spid information
-- master, Tempdb, Model, MSDB
INSERT INTO @SpidListTable (SpidNumber)
SELECT spid
FROM master.dbo.sysprocesses
WHERE DBID NOT IN (1,2,3,4) AND spid > 50 AND spid <>@@spid 
And last_batch <= dateadd(hh,-48,getdate()) 
ORDER BY spid DESC

-- 3b - Determine the highest UIDSpidList to loop through the records
SELECT @SpidListLoop = MAX(UIDSpidList) FROM @SpidListTable

-- 3c - While condition for looping through the spid records
WHILE @SpidListLoop > 0
BEGIN


-- 3d - Capture spids location
SELECT @spidNumber = SpidNumber
FROM @SpidListTable
WHERE UIDSpidList = @SpidListLoop

-- 3e - String together the KILL statement
SELECT @CMD1 = 'KILL ' + CAST(@spidNumber AS VARCHAR(5))

-- 3f - Execute the final string to KILL the spids
-- SELECT @CMD1
PRINT (@CMD1)

-- 3g - Descend through the spid list
SELECT @SpidListLoop = @SpidListLoop - 1
END

SET NOCOUNT OFF
GO