
SELECT 'print '''+ A.name+'''; USE [ODS] DBCC SHRINKFILE (N''' + A.name+''',0) ;'
FROM sys.database_files A LEFT JOIN sys.filegroups fg 
ON A.data_space_id = fg.data_space_id 

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
where a.type_desc='ROWS'
and A.name <> 'FI_ODS_OLTP_IX01'
order by 7 desc;-- A.TYPE desc, A.NAME,


--ROWS	FI_ODS_OLTP_IX01	FG_OLTP_INDEX	D:\DATA\FI_ODS_OLTP_IX01.ndf	624.1163378	482.3651757	141.7511621	22.71	By 10240 MB - Unrestricted
--SELECT ' BACKUP  DATABASE ' +name+ ' TO  DISK= N''\\aubfrcognossqlol\share_sql\'+name+'.BAK'' WITH NOFORMAT,
--NOINIT,  NAME = N'''+name+'-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10 
--GO
--'
--USE [ODS]
--GO
--DBCC SHRINKFILE (N'FI_ODS_OLTP_IX01' , 0)
--GO
