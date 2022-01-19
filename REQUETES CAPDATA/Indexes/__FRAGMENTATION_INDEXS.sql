/*Perform a 'USE <database name>' to select the database in which to run the script.*/
-- Declare variables

---
--USE [SID_PRD] ALTER INDEX [TICKET_UNIFIE_IX1] ON [ODS].[TICKET_UNIFIE]REBUILD


SET NOCOUNT ON;
DECLARE @tablename varchar(255);
DECLARE @execstr   varchar(400);
DECLARE @objectid  int;
DECLARE @indexid   int;
DECLARE @frag      decimal;
DECLARE @maxfrag   decimal;

-- Decide on the maximum fragmentation to allow for.
SELECT @maxfrag = 30.0;

-- Declare a cursor.
DECLARE tables CURSOR FOR
   SELECT TABLE_SCHEMA + '.' + TABLE_NAME
   FROM INFORMATION_SCHEMA.TABLES
   WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME IN ('TICKET_UNIFIE');

-- Create the table.
CREATE TABLE #fraglist (
   ObjectName varchar(255),
   ObjectId int,
   IndexName varchar(255),
   IndexId int,
   Lvl int,
   CountPages int,
   CountRows int,
   MinRecSize int,
   MaxRecSize int,
   AvgRecSize int,
   ForRecCount int,
   Extents int,
   ExtentSwitches int,
   AvgFreeBytes int,
   AvgPageDensity int,
   ScanDensity decimal,
   BestCount int,
   ActualCount int,
   LogicalFrag decimal,
   ExtentFrag decimal);

-- Open the cursor.
OPEN tables;

-- Loop through all the tables in the database.
FETCH NEXT
   FROM tables
   INTO @tablename;

WHILE @@FETCH_STATUS = 0
BEGIN;
-- Do the showcontig of all indexes of the table
   INSERT INTO #fraglist 
   EXEC ('DBCC SHOWCONTIG (''' + @tablename + ''') 
      WITH FAST, TABLERESULTS, ALL_INDEXES, NO_INFOMSGS');
   FETCH NEXT
      FROM tables
      INTO @tablename;
END;

-- Close and deallocate the cursor.
CLOSE tables;
DEALLOCATE tables;
--select * from #fraglist
-- Declare the cursor for the list of indexes to be defragged.
SELECT '['+ObjectName+']', ObjectId,IndexId,'['+IndexName+']', LogicalFrag   
--'USE ''[SID_PRD]''ALTER INDEX  ''[''+ObjectName+'']''ON [ODS].''[''+IndexName+'']''' 
FROM #fraglist
   WHERE LogicalFrag >= @maxfrag
      AND INDEXPROPERTY (ObjectId, IndexName, 'IndexDepth') > 0
     order by 4 desc 
      
----- USE [SID_PRD] ALTER INDEX [TICKET_UNIFIE_IX1] ON [ODS].[TICKET_UNIFIE]REBUILD     
      
DROP TABLE  #fraglist
