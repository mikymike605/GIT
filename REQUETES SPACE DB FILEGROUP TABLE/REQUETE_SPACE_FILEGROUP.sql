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
	FROM sys.tables sysTab
	INNER JOIN sys.indexes ind WITH (NOLOCK) 
		ON sysTab.OBJECT_ID = ind.OBJECT_ID and ind.Index_ID<=1
	INNER JOIN sys.partitions parti WITH (NOLOCK)
		ON ind.OBJECT_ID = parti.OBJECT_ID AND ind.index_id = parti.index_id
	INNER JOIN sys.allocation_units alloUni WITH (NOLOCK)
		ON parti.partition_id = alloUni.container_id
	WHERE sysTab.is_ms_shipped = 0
	AND ind.OBJECT_ID > 255
	AND parti.rows>0
	--AND SCHEMA_NAME(sysTab.SCHEMA_ID) = 'MIG'
	GROUP BY sysTab.SCHEMA_ID
	ORDER BY TotalSpaceKB DESC
