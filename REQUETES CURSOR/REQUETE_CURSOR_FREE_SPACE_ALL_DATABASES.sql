  DECLARE @tbname varchar(250)

DECLARE product_cursor CURSOR FOR  
	SELECT name FROM sys.sysdatabases where name not in ('master','tempdb','model','msdb','ReportServer','ReportServerTempDB')
OPEN product_cursor  
FETCH FROM product_cursor INTO @tbname 
WHILE @@FETCH_STATUS =0
    BEGIN 
	--PRINT @tbname
	FETCH FROM product_cursor INTO @tbname 
	BEGIN
DECLARE @SQL VARCHAR(max)
SET @SQL=@tbname
--'USE 
--['+@tbname+']
--select  ''print ''''''+ f.name+''''''; USE ''+''['+@tbname+']''+'' DBCC SHRINKFILE (N'''''' + f.name+'''''',0) ;''
--,@@servername
--    ,f.type_desc as [Type]
--    , f.name as [FileName]
--    ,fg.name as [FileGroup]
--    ,f.physical_name as [Path]
--    ,f.size / 128.0 as [CurrentSizeMB]
--    ,f.size /128.0 - convert(int,fileproperty(f.name,''SpaceUsed''))/128.0 as [FreeSpaceMb]
--	,[TimeStamp]=getdate()
--from 
--    sys.database_files f with (nolock) left outer join 
--      sys.filegroups fg with (nolock) on
--            f.data_space_id = fg.data_space_id
--            where f.size /128.0 - convert(int,fileproperty(f.name,''SpaceUsed''))/128.0 >1000
--            and f.type_desc not in (''LOG'')
--order by 7 desc 
--option (recompile)
----UNION ALL
--'

PRINT @sql


--CLOSE product_cursor  
--DEALLOCATE product_cursor
END
end

CLOSE product_cursor  
DEALLOCATE product_cursor
