select * from sys.tables t
inner join sys.partitions p on t.object_id=p.object_id
where object_name (t.object_id) = 'MD5_INVOICE'
--and partition_id='72057596027666432'


 
select * from sys.partitions
where  (partition_id)='72057594371244032'

select o.name,i.name, partition_id, partition_number,[rows],*
from sys.partitions p
inner join sys.objects o on o.object_id=p.object_id
inner join sys.indexes i on i.object_id=o.object_id and p.index_id=i.index_id
where partition_id= '72057594371244032'
--and rows >0

DECLARE @object SYSNAME = 'ods.MD5_INVOICE'
 
SELECT object_id,
    OBJECT_NAME ([sp].[object_id]) AS [Object Name],
    [sp].[index_id] AS [Index ID],
	[sp].[partition_number] AS [Partition Number],
    [sp].[partition_id] AS [Partition ID],
        [sa].[allocation_unit_id] AS [Alloc Unit ID],
    [sa].[type_desc] AS [Alloc Unit Type],
    '(' + CONVERT (VARCHAR (6),
        CONVERT (INT,
            SUBSTRING ([sa].[first_page], 6, 1) +
            SUBSTRING ([sa].[first_page], 5, 1))) +
    ':' + CONVERT (VARCHAR (20),
        CONVERT (INT,
            SUBSTRING ([sa].[first_page], 4, 1) +
            SUBSTRING ([sa].[first_page], 3, 1) +
            SUBSTRING ([sa].[first_page], 2, 1) +
            SUBSTRING ([sa].[first_page], 1, 1))) +
    ')' AS [First Page],
    '(' + CONVERT (VARCHAR (6),
        CONVERT (INT,
            SUBSTRING ([sa].[root_page], 6, 1) +
            SUBSTRING ([sa].[root_page], 5, 1))) +
    ':' + CONVERT (VARCHAR (20),
        CONVERT (INT,
            SUBSTRING ([sa].[root_page], 4, 1) +
            SUBSTRING ([sa].[root_page], 3, 1) +
            SUBSTRING ([sa].[root_page], 2, 1) +
            SUBSTRING ([sa].[root_page], 1, 1))) +
    ')' AS [Root Page],
    '(' + CONVERT (VARCHAR (6),
        CONVERT (INT,
            SUBSTRING ([sa].[first_iam_page], 6, 1) +
            SUBSTRING ([sa].[first_iam_page], 5, 1))) +
    ':' + CONVERT (VARCHAR (20),
        CONVERT (INT,
            SUBSTRING ([sa].[first_iam_page], 4, 1) +
            SUBSTRING ([sa].[first_iam_page], 3, 1) +
            SUBSTRING ([sa].[first_iam_page], 2, 1) +
            SUBSTRING ([sa].[first_iam_page], 1, 1))) +
    ')' AS [First IAM Page]
FROM
    sys.system_internals_allocation_units AS [sa],
    sys.partitions AS [sp]
WHERE
    [sa].[container_id] = [sp].[partition_id]
AND [sp].[object_id] =
(CASE WHEN (@object IS NULL)
    THEN [sp].[object_id]
    ELSE OBJECT_ID (@object)
END)
and allocation_unit_id=72057598176395264