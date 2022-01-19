SELECT --distinct (filname)
  'print '''+ FILNAME+'''; USE '+[DATABASENAME]+' DBCC SHRINKFILE (N''' + FILNAME+''',0) ;'
  ,servername
  ,DATABASENAME
  ,FILNAME
  ,FILETYPE 
  --, left (FILESIZE,5)as totto
  ,FILESIZE
  ,SPACEFREE_GB
  ,cast (SPACEFREE_GB/left (FILESIZE,5)*100 as decimal(16,2)) as [%Pourcentage_Libre]
  , TIMESTAMP
  FROM [AdminMonitor].[dbo].[SHRINK_TABLE_V2]  
  where timestamp >= DATEADD(hour, -18, GETDATE())  
  --and databasename = 'DWh_COM'
  --and FILETYPE='DATA'
 and filesize like '%GB'
   --and FILNAME like 'FI_ODS_OLTP_IX01'
  and SPACEFREE_GB >2
  and cast (SPACEFREE_GB/left (FILESIZE,5)*100 as decimal(16,2)) >30
  --order by 5, 8 desc
  order by 6 desc 