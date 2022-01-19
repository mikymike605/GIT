use SID_PRD
GO
select object_name(S.object_id, database_id) as 'Table Name'
, I.name as 'Index Name'
, S.index_id as 'Index ID'
,user_seeks
,user_scans
,user_lookups
from sys.dm_db_index_usage_stats S
inner join sys.indexes I on I.index_id = S.index_id
and I.object_id = S.object_id
--where user_seeks = 0 and user_scans = 0 and user_lookups = 0
--and database_id = db_id()
where I.name is not null
--and I.name like '%_IDX_%'
--and object_name(S.object_id, database_id)  like '%RESTAURANT_QUARTER%'
order by 1 


SELECT OBJECT_NAME(A.[OBJECT_ID]) AS [OBJECT NAME],
       I.[NAME] AS [INDEX NAME],
       A.leaf_insert_count,
       A.leaf_update_count,
       A.leaf_delete_count
FROM   sys.dm_db_index_operational_stats (NULL,NULL,NULL,NULL) A
       INNER JOIN sys.indexes AS I
         ON I.[OBJECT_ID] = A.[OBJECT_ID]
            AND I.INDEX_ID = A.INDEX_ID
WHERE  OBJECTPROPERTY(A.[OBJECT_ID],'IsUserTable') = 1
and I.name like '%_IDX_%'
and object_name(A.object_id, database_id)  like '%RESTAURANT_QUARTER%'



SELECT  'DROP INDEX ['+I.[NAME]+'] on ['+OBJECT_schema_NAME(S.[OBJECT_ID],database_id) +'].['+OBJECT_NAME(S.[OBJECT_ID])+']',
  OBJECT_NAME(S.[OBJECT_ID]) AS [OBJECT NAME],
         I.[NAME] AS [INDEX NAME],
         USER_SEEKS,
         USER_SCANS,
         USER_LOOKUPS,
         user_updates
		FROM     sys.dm_db_index_usage_stats AS S
         INNER JOIN sys.indexes AS I
           ON I.[OBJECT_ID] = S.[OBJECT_ID]
              AND I.INDEX_ID = S.INDEX_ID
WHERE    OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1 
--and user_seeks = 0 and user_scans = 0 and user_lookups = 0
and  I.[NAME] is not null
and I.name like '%_IDX_%'



select OBJECT_NAME(p.object_id ), i.name,p.*

from sys.dm_db_partition_stats p

join sys.indexes i on i.object_id = p.object_id and i.index_id = p.index_id
