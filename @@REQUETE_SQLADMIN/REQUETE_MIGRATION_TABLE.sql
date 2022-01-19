USE SID_PRD

---- volume schéma mig + timeleft



--SCRIPT NO 2

--–Get total size of each schema available in your SQL Server database

SELECT

SCHEMA_NAME(sysTab.SCHEMA_ID) as SchemaName,
SUM(alloUni.total_pages) * 8/1024/1024 AS TotalAsGB,
(1024 - SUM(alloUni.total_pages) * 8/1024/1024) / 60 as estimatedtimeleftHours,
SUM(alloUni.total_pages) * 8 AS TotalSpaceKB,

SUM(alloUni.used_pages) * 8 AS UsedSpaceKB,

(SUM(alloUni.total_pages) - SUM(alloUni.used_pages)) * 8 AS UnusedSpaceKB

FROM

sys.tables sysTab

INNER JOIN

sys.indexes ind ON sysTab.OBJECT_ID = ind.OBJECT_ID and ind.Index_ID<=1

INNER JOIN

sys.partitions parti ON ind.OBJECT_ID = parti.OBJECT_ID AND ind.index_id = parti.index_id

INNER JOIN

sys.allocation_units alloUni ON parti.partition_id = alloUni.container_id

WHERE

sysTab.is_ms_shipped = 0

AND ind.OBJECT_ID > 255


AND parti.rows>0
AND SCHEMA_NAME(sysTab.SCHEMA_ID) = 'MIG'
GROUP BY

sysTab.SCHEMA_ID

ORDER BY

TotalSpaceKB DESC


---SCHEMA ODS
SELECT t.NAME AS TableName,
	s.name as SchemaName,
    i.name as indexName,
    p.[Rows]

INTO #T1
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.schemas AS s ON t.[schema_id] = s.[schema_id] 
WHERE 
    t.NAME NOT LIKE 'dt%' AND
    i.OBJECT_ID > 255 AND   
    i.index_id <= 1
	AND s.name = 'ODS'
GROUP BY 
    s.name,t.NAME, i.object_id, i.index_id, i.name, p.[Rows]
ORDER BY 
    object_name(i.object_id) 

--- SCHEMA MIG
SELECT t.NAME AS TableName,
	s.name as SchemaName,
    i.name as indexName,
    p.[Rows]

INTO #T2
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.schemas AS s ON t.[schema_id] = s.[schema_id] 
WHERE 
    t.NAME NOT LIKE 'dt%' AND
    i.OBJECT_ID > 255 AND   
    i.index_id <= 1
	AND s.name = 'MIG'
GROUP BY 
    s.name,t.NAME, i.object_id, i.index_id, i.name, p.[Rows]
ORDER BY 
    object_name(i.object_id) 


--- COMPARAISON

Select ods.TableName, ods.Rows,mig.Rows,case when ods.Rows = mig.Rows then 'OK' else 'DIFF' end as state 
FROM #T1 ods INNER JOIN #T2 mig  ON ods.TableName = mig.TableName 
order by 4,ods.Rows-mig.Rows desc

select 'DROP TABLE ODS.['+ods.TableName+']' 
FROM #T1 ods INNER JOIN #T2 mig  ON ods.TableName = mig.TableName 
Where ods.Rows=mig.Rows

DROP TABLE #T1
DROP TABLE #T2
