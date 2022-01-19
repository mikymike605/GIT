SELECT OBJECT_SCHEMA_NAME(t.object_id) AS schema_name
,t.name AS table_name
,i.index_id
,i.object_id
,i.name AS index_name
,ds.name AS filegroup_name
,p.rows
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id=i.object_id
INNER JOIN sys.filegroups ds ON i.data_space_id=ds.data_space_id
INNER JOIN sys.partitions p ON i.object_id=p.object_id AND i.index_id=p.index_id
where ds.name = 'FG_OLTP_INDEX'
ORDER BY p.rows desc


SELECT 'USE [ODS] GO DBCC SHRINKFILE (N'+A.name+',0) ',
    [TYPE] = A.TYPE_DESC
    ,[FILE_Name] = A.name
    ,[FILEGROUP_NAME] = fg.name
    ,[File_Location] = A.PHYSICAL_NAME
    ,[FILESIZE_GB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0)/1024
    ,[USEDSPACE_GB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0))/1024
    ,[FREESPACE_GB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0)/1024
    ,[FREESPACE_%] = CONVERT(DECIMAL(10,2),((A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0)/(A.SIZE/128.0))*100)
    ,[AutoGrow] = 'By ' + CASE is_percent_growth WHEN 0 THEN CAST(growth/128 AS VARCHAR(10)) + ' MB -' 
        WHEN 1 THEN CAST(growth AS VARCHAR(10)) + '% -' ELSE '' END 
        + CASE max_size WHEN 0 THEN 'DISABLED' WHEN -1 THEN ' Unrestricted' 
            ELSE ' Restricted to ' + CAST(max_size/(128*1024) AS VARCHAR(10)) + ' GB' END 
        + CASE is_percent_growth WHEN 1 THEN ' [autogrowth by percent, BAD setting!]' ELSE '' END
FROM sys.database_files A LEFT JOIN sys.filegroups fg ON A.data_space_id = fg.data_space_id 
order by 7 desc;-- A.TYPE desc, A.NAME,