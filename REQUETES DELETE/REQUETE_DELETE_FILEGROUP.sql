DBCC showfilestats
--DBCC SHRINKFILE ('FG_SID_DEV_2_ODS_DATE_25' , EMPTYFILE) 
ALTER DATABASE [SID_DEV] REMOVE FILE FG_SID_DEV_2_ODS_DATE_18
ALTER DATABASE [SID_DEV] REMOVE FILEGROUP FG_SID_DEV_2_ODS_DATE_18


SELECT * FROM  sys.data_spaces ds
INNER JOIN sys.indexes i
ON ds.data_space_id = i.data_space_id
WHERE ds.name = 'FG_SID_DEV_2_ODS_DATE_25'

SELECT
    au.*,
    ds.name AS [data_space_name],
    ds.type AS [data_space_type],
    p.rows,
    o.name AS [object_name]
FROM sys.allocation_units au
    INNER JOIN sys.data_spaces ds
        ON au.data_space_id = ds.data_space_id
    INNER JOIN sys.partitions p
        ON au.container_id = p.partition_id
    INNER JOIN sys.objects o
        ON p.object_id = o.object_id
WHERE au.type_desc = 'LOB_DATA'