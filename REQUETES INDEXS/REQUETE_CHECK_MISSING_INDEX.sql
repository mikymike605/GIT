SELECT  
rank() OVER (ORDER BY (migs.user_seeks + migs.user_scans) DESC) AS rank, 
(migs.user_seeks + migs.user_scans) AS seek_and_scan, migs.avg_user_impact, 
UPPER ('KINGSIDSQLPRD') AS ServerName,  
'CREATE INDEX [missing_index]' + ' ON ' + mid.statement + ' (' + ISNULL(mid.equality_columns, '') + CASE WHEN mid.equality_columns IS NOT NULL AND 
mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END + ISNULL(mid.inequality_columns, '') + ')' + ISNULL(' INCLUDE (' + mid.included_columns + ')', '') 
AS create_index_statement,
[timestamp]=getdate()
INTO  #T1
FROM [KINGSIDSQLPRD].master.sys.dm_db_missing_index_groups mig 
INNER JOIN [KINGSIDSQLPRD].master.sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle 
INNER JOIN [KINGSIDSQLPRD].master.sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE migs.avg_user_impact > 80 
AND (migs.user_seeks + migs.user_scans) > 1000 
AND mid.included_columns IS NULL
--/*ORDER BY 3 DESC*/ 
SELECT * INTO #T2 FROM #T1 a
 WHERE NOT EXISTS
(SELECT        *
  FROM #T1 b
  WHERE a.rank <> b.rank AND CHARINDEX(REPLACE(a.create_index_statement, ')', ''), REPLACE(b.create_index_statement, ')', '')) > 0)
SELECT * FROM #T2
 --ORDER BY 4 DROP TABLE #T1 DROP TABLE #T2

 DROP TABLE #T1
 DROP TABLE #T2



-- Missing Index Script
-- Original Author: Pinal Dave 
SELECT 
dm_mid.database_id AS DatabaseID,
dm_migs.avg_user_impact,
dm_migs.user_seeks,
dm_migs.user_scans,
--dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans) Avg_Estimated_Impact,
dm_migs.last_user_seek AS Last_User_Seek,
OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) AS [TableName],
'CREATE INDEX [IX_' + OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) + '_'
+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.equality_columns,''),', ','_'),'[',''),']','') 
+ CASE
WHEN dm_mid.equality_columns IS NOT NULL 
AND dm_mid.inequality_columns IS NOT NULL THEN '_'
ELSE ''
END
+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.inequality_columns,''),', ','_'),'[',''),']','')
+ ']'
+ ' ON ' + dm_mid.statement
+ ' (' + ISNULL (dm_mid.equality_columns,'')
+ CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns 
IS NOT NULL THEN ',' ELSE
'' END
+ ISNULL (dm_mid.inequality_columns, '')
+ ')'
+ ISNULL (' INCLUDE (' + dm_mid.included_columns + ')', '') AS Create_Statement
FROM sys.dm_db_missing_index_groups dm_mig
INNER JOIN sys.dm_db_missing_index_group_stats dm_migs
ON dm_migs.group_handle = dm_mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details dm_mid
ON dm_mig.index_handle = dm_mid.index_handle
WHERE dm_mid.database_ID = DB_ID()
AND   dm_migs.avg_user_impact > 80 
AND (dm_migs.user_seeks + dm_migs.user_scans) > 1000 
AND dm_mid.included_columns IS NULL
--and OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) like 'QSL_INVOICE'
--ORDER BY Avg_Estimated_Impact DESC
--ORDER BY  dm_migs.last_user_seek desc 
order by dm_migs.avg_user_impact desc 
GO

-- Missing Index Script
-- Original Author: Pinal Dave 
SELECT 
dm_mid.database_id AS DatabaseID,
--dm_migs.avg_user_impact,
--dm_migs.user_seeks,
--dm_migs.user_scans,
dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans) Avg_Estimated_Impact,
dm_migs.last_user_seek AS Last_User_Seek,
OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) AS [TableName],
'CREATE INDEX [IX_' + OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) + '_'
+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.equality_columns,''),', ','_'),'[',''),']','') 
+ CASE
WHEN dm_mid.equality_columns IS NOT NULL 
AND dm_mid.inequality_columns IS NOT NULL THEN '_'
ELSE ''
END
+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.inequality_columns,''),', ','_'),'[',''),']','')
+ ']'
+ ' ON ' + dm_mid.statement
+ ' (' + ISNULL (dm_mid.equality_columns,'')
+ CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns 
IS NOT NULL THEN ',' ELSE
'' END
+ ISNULL (dm_mid.inequality_columns, '')
+ ')'
+ ISNULL (' INCLUDE (' + dm_mid.included_columns + ')', '') AS Create_Statement
FROM sys.dm_db_missing_index_groups dm_mig
INNER JOIN sys.dm_db_missing_index_group_stats dm_migs
ON dm_migs.group_handle = dm_mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details dm_mid
ON dm_mig.index_handle = dm_mid.index_handle
WHERE dm_mid.database_ID = DB_ID()
AND   dm_migs.avg_user_impact > 80 
AND (dm_migs.user_seeks + dm_migs.user_scans) > 1000 
AND dm_mid.included_columns IS NULL
--and OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) like 'QSL_INVOICE'
ORDER BY Avg_Estimated_Impact DESC
--ORDER BY  dm_migs.last_user_seek desc 
--order by dm_migs.avg_user_impact desc 
GO