SET NOCOUNT ON;

DECLARE @v_Object_Id int;

DECLARE @v_Index_Id int;

DECLARE @v_Schema_Nm nvarchar(130); 

DECLARE @v_Object_Nm nvarchar(130); 

DECLARE @v_Index_Nm nvarchar(130); 

DECLARE @v_Rebuild_Stmt nvarchar(2000);

DECLARE @v_Frag_Flt float

DECLARE @v_Start_DtTm datetime;

DECLARE @v_End_DtTm datetime;

DECLARE @v_Duration_DtTm datetime;

--Uncomment if you are running the code and not the procedure

DECLARE @ip_Frag_Limit Int

SET @ip_Frag_Limit = 30

IF (((SELECT DB_NAME(DB_ID())) = 'master') OR ((SELECT DB_NAME(DB_ID())) = 'model') OR ((SELECT DB_NAME(DB_ID())) = 'msdb') OR ((SELECT DB_NAME(DB_ID())) = 'tempdb'))

BEGIN

PRINT 'You cannot execute this procedure in this database'

RETURN;

END

-- We want records in a permenant table so we see if it exists from a previous run

-- If it does exist, then we TRUNCATE it, otherwise, we create it

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DBA_IndexStatistics]') AND type in (N'U'))

TRUNCATE TABLE [dbo].[DBA_IndexStatistics]

ELSE

CREATE TABLE [dbo].[DBA_IndexStatistics](

[Object_Id] int NULL,

[Table_Nm] varchar(255) NULL,

[Index_Id] int NULL,

[Index_Nm] varchar(255) NULL,

[Frag] float NULL,

[IndexRebuilt_Ind] BIT NULL,

[Start_DtTm] datetime NULL,

[End_DtTm] datetime NULL,

[Duration] varchar(20) NULL

) ON [PRIMARY]


-- Load our temporary working table that will contain all of our index information

SELECT object_id AS [Object_Id], CAST('' AS sysname) AS [Table_Nm], index_id AS [Index_Id], CAST('' AS sysname) AS [Index_Nm], avg_fragmentation_in_percent AS [Frag],0 AS [IndexRebuilt_Ind], GetDate() AS [Start_DtTm], GetDate() AS [End_DtTm], '00:00:00' AS [Duration]

INTO #Tmp_Index_Stats

FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, NULL)

WHERE Index_ID > 0

ORDER BY [Object_Id],[Index_Id];


-- Create a cursor to run through each distinct table object_id from our working table

DECLARE cur_Object CURSOR FAST_FORWARD FOR SELECT DISTINCT [Object_Id] FROM #Tmp_Index_Stats ORDER BY [Object_Id]

OPEN cur_Object

FETCH NEXT FROM cur_Object INTO @v_Object_Id

WHILE @@FETCH_STATUS = 0

BEGIN

-- Check to see if the table has a Clustered index AND has any other NonClustered index with fragmentation >= the limit passed in the procedure 

IF ((SELECT MIN([Index_Id]) FROM #Tmp_Index_Stats WHERE [Object_Id] = @v_Object_Id) = 1) AND ((SELECT COUNT([Object_Id]) FROM #Tmp_Index_Stats WHERE [Object_Id] = @v_Object_Id AND [Frag] >= @ip_Frag_Limit) > 0)

BEGIN

-- If true then rebuild the Clustered Index only

SELECT @v_Object_Nm = QUOTENAME(o.name), @v_Schema_Nm = QUOTENAME(s.name)

FROM sys.objects AS o

JOIN sys.schemas as s ON s.schema_id = o.schema_id

WHERE o.object_id = @v_Object_Id;

SELECT @v_Index_Nm = QUOTENAME(name)

FROM sys.indexes

WHERE object_id = @v_Object_Id AND Index_ID = 1;


-- Set Start time before rebuild

SET @v_Start_DtTm = GetDate() 


--SET @v_Rebuild_Stmt = N'ALTER INDEX ALL ON ' + @v_Schema_Nm + N'.' + @v_Object_Nm + N' REBUILD WITH (STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON)';

SET @v_Rebuild_Stmt = N'ALTER INDEX ' + @v_Index_Nm + N' ON ' + @v_Schema_Nm + N'.' + @v_Object_Nm + N' REBUILD WITH (STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON)';

--EXEC sp_executesql @v_Rebuild_Stmt

PRINT @v_Rebuild_Stmt


-- Set End Time and Duration after rebuild

SET @v_End_DtTm = GetDate()

SET @v_Duration_DtTm = (@v_End_DtTm - @v_Start_DtTm)

-- Update values in our temp table that we will store in the permenant table.

UPDATE #Tmp_Index_Stats SET [IndexRebuilt_Ind] = 1 WHERE [Object_Id] = @v_Object_Id AND [Index_Id] = 1

UPDATE #Tmp_Index_Stats SET [Table_Nm] = @v_Object_Nm WHERE [Object_Id] = @v_Object_Id AND [Index_Id] = 1

UPDATE #Tmp_Index_Stats SET [Index_Nm] = @v_Index_Nm WHERE [Object_Id] = @v_Object_Id AND [Index_Id] = 1

UPDATE #Tmp_Index_Stats SET [Start_DtTm] = @v_Start_DtTm WHERE [Object_Id] = @v_Object_Id AND [Index_Id] = 1

UPDATE #Tmp_Index_Stats SET [End_DtTm] = @v_End_DtTm WHERE [Object_Id] = @v_Object_Id AND [Index_Id] = 1

UPDATE #Tmp_Index_Stats SET [Duration] = CONVERT(Varchar(20),@v_Duration_DtTm,108) WHERE [Object_Id] = @v_Object_Id AND [Index_Id] = 1

END

ELSE

-- In this case, we do not have a Clustered index. Then we need to check each individual NonClustered index for fragmentation limits

BEGIN

-- Get a list of NonClustered indexes for this one table object_id 

DECLARE cur_Index CURSOR FAST_FORWARD FOR SELECT [Index_Id], [Frag] FROM #Tmp_Index_Stats WHERE [Object_Id] = @v_Object_Id ORDER BY [Index_Id]

OPEN cur_Index

FETCH NEXT FROM cur_Index into @v_Index_Id, @v_Frag_Flt

WHILE @@FETCH_STATUS = 0

BEGIN

-- Compare actual index fragmentation to our fragmentation limit passed in to the procedure.

IF @v_Frag_Flt >= @ip_Frag_Limit

-- If index is more fragmented than our limit then rebuild this index

BEGIN

SELECT @v_Object_Nm = QUOTENAME(o.name), @v_Schema_Nm = QUOTENAME(s.name)

FROM sys.objects AS o

JOIN sys.schemas as s ON s.schema_id = o.schema_id

WHERE o.object_id = @v_Object_Id;

SELECT @v_Index_Nm = QUOTENAME(name)

FROM sys.indexes

WHERE object_id = @v_Object_Id AND Index_ID = @v_Index_Id;


-- Set Start time before rebuild

SET @v_Start_DtTm = GetDate() 

SET @v_Rebuild_Stmt = N'ALTER INDEX ' + @v_Index_Nm + N' ON ' + @v_Schema_Nm + N'.' + @v_Object_Nm + N' REBUILD WITH (STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON)';

--EXEC sp_executesql @v_Rebuild_Stmt

PRINT @v_Rebuild_Stmt

-- Set End Time and Duration after rebuild

SET @v_End_DtTm = GetDate()

SET @v_Duration_DtTm = (@v_End_DtTm - @v_Start_DtTm)


-- Update values in our temp table that we will store in the permenant table.

UPDATE #Tmp_Index_Stats SET [IndexRebuilt_Ind] = 1 WHERE [Object_Id] = @v_Object_Id AND [Index_Id] = @v_Index_Id

UPDATE #Tmp_Index_Stats SET [Table_Nm] = @v_Object_Nm WHERE [Object_Id] = @v_Object_Id AND [Index_Id] = @v_Index_Id

UPDATE #Tmp_Index_Stats SET [Index_Nm] = @v_Index_Nm WHERE [Object_Id] = @v_Object_Id AND [Index_Id] = @v_Index_Id

UPDATE #Tmp_Index_Stats SET [Start_DtTm] = @v_Start_DtTm WHERE [Object_Id] = @v_Object_Id AND [Index_Id] = @v_Index_Id

UPDATE #Tmp_Index_Stats SET [End_DtTm] = @v_End_DtTm WHERE [Object_Id] = @v_Object_Id AND [Index_Id] = @v_Index_Id

UPDATE #Tmp_Index_Stats SET [Duration] = CONVERT(Varchar(20),@v_Duration_DtTm,108) WHERE [Object_Id] = @v_Object_Id AND [Index_Id] = @v_Index_Id

END


FETCH NEXT FROM cur_Index into @v_Index_Id, @v_Frag_Flt

END

CLOSE cur_Index

DEALLOCATE cur_Index

END

FETCH NEXT FROM cur_Object into @v_Object_Id

END

CLOSE cur_Object

DEALLOCATE cur_Object

-- Populate our permamnet table for our viewing. we only want to see what was rebuilt and how long it took.

INSERT [DBA_IndexStatistics] SELECT [Object_Id], [Table_Nm], [Index_Id], [Index_Nm], [Frag], [IndexRebuilt_Ind], [Start_DtTm], [End_DtTm], [Duration] FROM #Tmp_Index_Stats WHERE [IndexRebuilt_Ind] = 1 ORDER BY [Duration] DESC

-- Drop our temporary table

DROP TABLE #Tmp_Index_Stats


SELECT * FROM [DBA_IndexStatistics] ORDER BY [Duration] DESC


