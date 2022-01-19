DECLARE @LongString NVARCHAR(100);
SET @LongString = 'SELECT *';
SET @LongString = @LongString + ' FROM ';
SET @LongString = @LongString + ' [AdminSQL].[dbo].[DBA_IndexStatistics]';
--EXEC sp_executesql @LongString;
PRINT  @LongString;