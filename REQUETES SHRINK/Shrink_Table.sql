--select * 
    SELECT --distinct (ServerName)
  'print '''+ FILNAME+'''; USE '+[DATABASENAME]+' DBCC SHRINKFILE (N''' + FILNAME+''',0) ;'
  ,servername
  ,DATABASENAME
  ,FILNAME
  ,FILETYPE 
  --, left (FILESIZE,5)as totto
  ,FILESIZE
  ,SPACEFREE_GB
  ,cast (SPACEFREE_GB/left (FILESIZE,5)*100 as decimal(16,2)) as [%POURCENTAGE_LIBRE]
  , TIMESTAMP
FROM [AdminMonitor].[dbo].[SHRINK_TABLE_V2]  
where timestamp >= DATEADD(hour, -22, GETDATE())  
and DATABASENAME not in ('master', 'model', 'msdb')
--and SPACEFREE_GB >0
--and ServerName  in ('AUBFRCOGNOSSQL')
--and FILESIZE <> '0.%'
order by 7 DESC

SELECT *
FROM AdminMonitor..[MonitorTBUnUsedTable]
where timestamp >=  DATEADD(hour, -22, GETDATE())  
--and Servername='vilfrmdbridge'
--and type <>'LOG'
order by 8 desc

select  'print '''+ f.name+'''; USE [dname] DBCC SHRINKFILE (N''' + f.name+''',0) ;',
    f.type_desc as [Type]
	--, d.name as [DbName] 
    , f.name as [FileName]
    ,fg.name as [FileGroup]
    ,f.physical_name as [Path]
    ,f.size / 128.0 as [CurrentSizeMB]
    ,f.size / 128.0 - convert(int,fileproperty(f.name,'SpaceUsed')) /
        128.0 as [FreeSpaceMb]
from 
    sys.database_files f with (nolock) left outer join 
    sys.filegroups fg with (nolock) on
    f.data_space_id = fg.data_space_id
	--inner join sys.databases d on d.database_id=f.file_id
order by 7 desc 
option (recompile)

SELECT  * FROM  sys.database_files

SELECT * FROM sys.database_principals


----select * 
--    SELECT  count (distinct servername)
--FROM [AdminMonitor].[dbo].[SHRINK_TABLE_V2]  
--where timestamp >= DATEADD(hour, -5, GETDATE())  

   SELECT --distinct (filname)
  'print '''+ FILNAME+'''; USE '+[DATABASENAME]+' DBCC SHRINKFILE (N''' + FILNAME+''',0) ;'
  ,servername
  ,DATABASENAME
  ,FILNAME
  ,FILETYPE 
  --, left (FILESIZE,5)as totto
  ,FILESIZE
  ,SPACEFREE_GB
  ,cast (SPACEFREE_GB/left (FILESIZE,5)*100 as decimal(16,2)) as [%POURCENTAGE_LIBRE]
  , TIMESTAMP
  FROM [AdminMonitor].[dbo].[SHRINK_TABLE_V2]  
  where timestamp >= DATEADD(MINUTE, -5, GETDATE())  
  --and databasename = 'DWh_COM'
--and FILETYPE='DATA'
 --and filesize like '%GB'
   --and FILNAME like 'FI_ODS_OLTP_IX01'
  and SPACEFREE_GB >1
  and  ServerName like 'KINGSIDSQLPRD'
  --and cast (SPACEFREE_GB/left (FILESIZE,5)*100 as decimal(16,2)) >30
  order by 7 desc


