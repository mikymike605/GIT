SELECT OBJECT_NAME(i.id) Table_name, i.name index_name, STATS_DATE(i.id, i.indid) Last_Update, i.rowmodctr
FROM sys.sysindexes i
WHERE OBJECT_NAME(i.id) like '%clients%'
ORDER BY i.rowmodctr DESC



--Seuil de maj : rowmodctr = 500 + 20% 
SELECT 
	LEFT(CAST(USER_NAME(uid)+'.'+o.name AS sysname),30) AS TableName,
	LEFT(i.name,30) AS IndexName,
	CASE WHEN INDEXPROPERTY(o.id, i.name, 'IsAutoStatistics')=1
			THEN 'AutoStatistics'
		 WHEN INDEXPROPERTY(o.id, i.name, 'IsStatistics')=1
			THEN 'Statistics'
		 ELSE
			'Index'
	END AS Type,
	STATS_DATE(o.id, i.indid) as StatsUpdated,
	rowcnt,
	rowmodctr,
	ISNULL(CAST(rowmodctr/CAST(NULLIF(rowcnt,0) AS decimal(20,2))*100 AS int),0) AS PercentModifiedRows,
	CASE i.status & 0x1000000
		WHEN 0 THEN 'no'
		ELSE 'yes'
	END AS [Norecompute?],
	i.status
FROM dbo.sysobjects o INNER JOIN dbo.sysindexes i ON (o.id=i.id)
WHERE OBJECTPROPERTY(o.id, 'IsUserTable')=1
AND i.indid BETWEEN 0 AND 254
--AND o.name = @NomTable
ORDER BY 1 DESC



----select 'USE ['+db_name()+'] UPDATE STATISTICS [dbo].['+name+']' from sysobjects where xtype='U'

----USE [Matisse] UPDATE STATISTICS [dbo].[Annonce] -- WITH FULLSCAN