
SELECT *--COUNT (distinct TABLE_NAMe)
from INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA ='MIG'

SELECT c.table_name,
'
CREATE CLUSTERED INDEX [pk_'+c.TABLE_NAME+'] ON  [ODS].['+c.TABLE_NAME+'] ('+C.col+') 
on SID_PRD_ODS_DATA_NEW

DROP INDEX pk_'+c.TABLE_NAME+' on [ODS].['+c.TABLE_NAME+'] WITH ( ONLINE = ON )

' 
AS TOT
FROM 
(
select table_schema,table_name, min (COLUMN_NAME) as col
from INFORMATION_SCHEMA.COLUMNS 
where ORDINAL_POSITION='1'
AND TABLE_SCHEMA ='ODS'
--and TABLE_NAME like '%TEST%'
--and DATA_TYPE='int'
group by table_name,table_schema
)
as c

-- The following two queries return information about 
-- which objects belongs to which filegroup
SELECT OBJECT_NAME(i.[object_id]) AS [ObjectName]
    ,i.[index_id] AS [IndexID]
    ,i.[name] AS [IndexName]
    ,i.[type_desc] AS [IndexType]
    ,i.[data_space_id] AS [DatabaseSpaceID]
    ,f.[name] AS [FileGroup]
    ,d.[physical_name] AS [DatabaseFileName]
FROM [sys].[indexes] i
INNER JOIN [sys].[filegroups] f
    ON f.[data_space_id] = i.[data_space_id]
INNER JOIN [sys].[database_files] d
    ON f.[data_space_id] = d.[data_space_id]
INNER JOIN [sys].[data_spaces] s
    ON f.[data_space_id] = s.[data_space_id]
WHERE OBJECTPROPERTY(i.[object_id], 'IsUserTable') = 1
and f.[name]='PRIMARY'
ORDER BY OBJECT_NAME(i.[object_id])
    ,f.[name]
    ,i.[data_space_id]
GO

