USE MASTER
declare
   @isql varchar(MAX),
   @dbname varchar(128),
   @logfile varchar(256)
   
   declare c1 cursor for 
   SELECT  d.name, mf.name as logfile--, physical_name AS current_file_location, size
   FROM sys.master_files mf
      inner join sys.databases d
      on mf.database_id = d.database_id
   where recovery_model_desc = 'SIMPLE'
   and d.name not in ('master','model','msdb','tempdb') 
   --and mf.type_desc = 'LOG'   
   open c1
   fetch next from c1 into @dbname, @logfile
   While @@fetch_status <> -1
      begin
      --select @isql = 'ALTER DATABASE [' + @dbname + '] SET RECOVERY SIMPLE'
      --print @isql
      ----exec(@isql)
      --select @isql='USE [' + @dbname + '] checkpoint'
      --print @isql
      ----exec(@isql)
      --select @isql='USE [' + @dbname + '] DBCC SHRINKFILE (''' + @logfile + ''', 1)'
      --print @isql
      ----exec(@isql)
	  --select  'print '''+ f.name+'''; USE '+'[ODS]'+' DBCC SHRINKFILE (N''' + f.name+''',0) ;',
	  select @isql = 'select  ''print  ['+ @dbname +']; USE  ['+ @dbname +'] DBCC SHRINKFILE (N'''''+@logfile+''''' ,0) ;''
    -- f.type_desc as [Type]
    --,f.name as [FileName]
    --,fg.name as [FileGroup]
    --,f.physical_name as [Path]
    --,f.size / 128.0 as [CurrentSizeMB]
    --,f.size / 128.0 - convert(int,fileproperty(f.name,''SpaceUsed'')) / 128.0 as [FreeSpaceMb]
	from  sys.database_files f with (nolock) left outer join 
      sys.filegroups fg with (nolock) on f.data_space_id = fg.data_space_id
      where f.type_desc not in (''LOG'')
	--order by 7 desc 
	option (recompile)'
	  print @isql      
      --exec(@isql)
      fetch next from c1 into @dbname, @logfile
      end
   close c1
   deallocate c1


--select  'print  [admin_partition]; USE  [admin_partition] DBCC SHRINKFILE (N''REB_INVOICE09'' ,0) ;',*
--    -- f.type_desc as [Type]
--    --,f.name as [FileName]
--    --,fg.name as [FileGroup]
--    --,f.physical_name as [Path]
--    --,f.size / 128.0 as [CurrentSizeMB]
--	into #Table1
--    --,f.size / 128.0 - convert(int,fileproperty(f.name,'SpaceUsed')) / 128.0 as [FreeSpaceMb]
--	from  sys.database_files f with (nolock) left outer join 
--      sys.filegroups fg with (nolock) on f.data_space_id = fg.data_space_id
--      where f.type_desc not in ('LOG')
--	--order by 7 desc 
--	option (recompile)

