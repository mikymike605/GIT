SELECT  schemas.name, OBJECT_NAME(S.[OBJECT_ID]) AS [OBJECT NAME], 
         I.[NAME] AS [INDEX NAME], 
		    8 * SUM(au.used_pages) AS 'Index size (KB)',
CAST(8 * SUM(AU.used_pages) / 1024.0 AS DECIMAL(18,2)) AS 'Index size (MB)',
CAST(8 * SUM(AU.used_pages) / 1024.0/1024.0 AS DECIMAL(18,2)) AS 'Index size (GB)',
         USER_SEEKS, 
         USER_SCANS, 
         USER_LOOKUPS, 
         USER_UPDATES 
FROM     SYS.DM_DB_INDEX_USAGE_STATS AS S 
         INNER JOIN SYS.INDEXES AS I ON I.[OBJECT_ID] = S.[OBJECT_ID]  AND I.INDEX_ID = S.INDEX_ID 
		 INNER JOIN sys.objects objects ON i.[object_id] = objects.[object_id]
INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id]
    INNER JOIN sys.partitions P ON P.OBJECT_ID = I.OBJECT_ID AND P.index_id = I.index_id
    INNER JOIN sys.allocation_units AU ON AU.container_id = P.partition_id
WHERE    OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1 
--and OBJECT_NAME(S.[OBJECT_ID])='DIM_PRODUCT'
--and schemas.name='ODS'
and i.[type] IN(1,2,3,4)
and user_seeks=0
group by  USER_SEEKS, 
         USER_SCANS, 
         USER_LOOKUPS, 
         USER_UPDATES ,schemas.name, OBJECT_NAME(S.[OBJECT_ID]),I.[NAME] 
order by 6 desc

/*
user_seeks - nombre de recherches d'index
user_scans- nombre d'analyses d'index
user_lookups - nombre de recherches d'index
user_updates - nombre d'opérations d'insertion, de mise à jour ou de suppression
*/