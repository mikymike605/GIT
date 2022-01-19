WITH LastRestores AS
(
SELECT
    DatabaseName = [d].[name] ,
    [d].[create_date] ,
    [d].[compatibility_level] ,
    [d].[collation_name] ,
    r.*,
    RowNum = ROW_NUMBER() OVER (PARTITION BY d.Name ORDER BY r.[restore_date] DESC)
FROM master.sys.databases d
LEFT OUTER JOIN msdb.dbo.[restorehistory] r ON r.[destination_database_name] = d.Name
)
SELECT *
FROM [LastRestores]
WHERE [RowNum] = 1
order by restore_date desc 



SELECT SUM(SizeMB),'ALL DB EXCLU'
FROM (
    SELECT DB_NAME(database_id) AS DatabaseName,
           Name AS Logical_Name,
           Physical_Name,
           (size * 8) / 1024/1024 SizeMB
    FROM sys.master_files
WHERE DB_NAME(database_id) in ('tempdb','AP1M4TST','DSOM4HOT','GALM4HOT','TRANSFERT','ARPM4HOT','PROD001_DMS','LVMM4HOT','SAASPDT','LOGM4HOT',
'AP3M4TST','AP2M4TST','MUTM4DEV','PFRM4TST','PFRM4QA3','PFRM4QA4','MUTM4QA1','MUTM4QA2','PFRM4QA1','PFRM4QA6',
'PFRM4RD2','PFRM4RD1','PFRM4QA5','PFRM4RD4','PFRM4RD3','PFRM4RD5','MUTM4TST','PFRM4QA2') 
and type_desc = 'ROWS'
) AS TEMP


SELECT SUM(SizeMB),'NOT IN DB EXCLU'
FROM (
    SELECT DB_NAME(database_id) AS DatabaseName,
           Name AS Logical_Name,
           Physical_Name,
           (size * 8) / 1024/1024 SizeMB
    FROM sys.master_files
WHERE DB_NAME(database_id) not in ('tempdb','AP1M4TST','DSOM4HOT','GALM4HOT','TRANSFERT','ARPM4HOT','PROD001_DMS','LVMM4HOT','SAASPDT','LOGM4HOT',
'AP3M4TST','AP2M4TST','MUTM4DEV','PFRM4TST','PFRM4QA3','PFRM4QA4','MUTM4QA1','MUTM4QA2','PFRM4QA1','PFRM4QA6',
'PFRM4RD2','PFRM4RD1','PFRM4QA5','PFRM4RD4','PFRM4RD3','PFRM4RD5','MUTM4TST','PFRM4QA2') 
and type_desc = 'ROWS'
) AS TEMP


SELECT SUM(SizeMB),'ALL DB'
FROM (
    SELECT DB_NAME(database_id) AS DatabaseName,
           Name AS Logical_Name,
           Physical_Name,
           (size * 8) / 1024/1024 SizeMB
    FROM sys.master_files
--WHERE DB_NAME(database_id) not in ('PFRM4QA2','MUTM4TST','PFRM4RD5','PFRM4RD3','PFRM4RD4','PFRM4QA5','PFRM4RD1','PFRM4RD2','PFRM4QA6','PFRM4QA1',
--'MUTM4QA2','MUTM4QA1','PFRM4QA4','PFRM4QA3','PFRM4TST') 
WHERE type_desc = 'ROWS'
) AS TEMP

