
SET XACT_ABORT on 
BEGIN DISTRIBUTED TRANSACTION T1

CREATE TABLE [AUBFRCOGNOSSQL]..#T3
(
TableName varchar (250),
SchemaName varchar (250),
object_id int,
Rowcounts bigint,
TotalSpaceKB bigint,
UsedSpaceKB bigint,
UnusedSpaceKB bigint)

INSERT INTO [AUBFRCOGNOSSQL]..#T3

EXEC [AUBFRCOGNOSSQL].master.sys.sp_MSforeachdb 
'
SELECT t.NAME AS TableName,s.Name AS SchemaName,
   i.object_id,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
FROM [AUBFRCOGNOSSQL].[?].sys.tables t 
INNER JOIN [AUBFRCOGNOSSQL].[?].sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN [AUBFRCOGNOSSQL].[?].sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN [AUBFRCOGNOSSQL].[?].sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN [AUBFRCOGNOSSQL].[?].sys.schemas s ON t.schema_id = s.schema_id
WHERE t.NAME NOT LIKE ''dt%'' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY t.NAME,s.Name,i.object_id, p.Rows
--ORDER BY i.object_id,t.Name
'
SELECT  RowCounts,TotalSpaceKB,  UsedSpaceKB,  UnusedSpaceKB,
 rank() OVER (ORDER BY (migs.user_seeks + migs.user_scans) DESC) AS rank, 
(migs.user_seeks + migs.user_scans) AS seek_and_scan, migs.avg_user_impact, 
UPPER  ('AUBFRCOGNOSSQL') AS ServerName,  
'CREATE INDEX [missing_index]' + ' ON ' + mid.statement + ' (' + ISNULL(mid.equality_columns, '') + CASE WHEN mid.equality_columns IS NOT NULL AND 
mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END + ISNULL(mid.inequality_columns, '') + ')' + ISNULL(' INCLUDE (' + mid.included_columns + ')', '') 
AS create_index_statement,
[timestamp]=getdate()
INTO  #T1
FROM [AUBFRCOGNOSSQL].master.sys.dm_db_missing_index_groups mig 
INNER JOIN [AUBFRCOGNOSSQL].master.sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle 
INNER JOIN [AUBFRCOGNOSSQL].master.sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
INNER JOIN [AUBFRCOGNOSSQL]..#T3 on #T3.object_id=mid.object_id
WHERE        migs.avg_user_impact > 80 AND (migs.user_seeks + migs.user_scans) > 1000 AND mid.included_columns IS NULL
--/*ORDER BY 3 DESC*/ 
SELECT * INTO #T2 FROM #T1 a
 WHERE NOT EXISTS
(SELECT        *
  FROM #T1 b
  WHERE a.rank <> b.rank AND CHARINDEX(REPLACE(a.create_index_statement, ')', ''), REPLACE(b.create_index_statement, ')', '')) > 0)
SELECT * FROM #T2
--ORDER BY 4 DROP TABLE #T1 DROP TABLE #T2 DROP TABLE #T3
SET XACT_ABORT OFF
 COMMIT TRANSACTION T1 