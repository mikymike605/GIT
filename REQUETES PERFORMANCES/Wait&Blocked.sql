SELECT * FROM sys.sysprocesses where spid >50 and waittime >0 and blocked >0 and hostname like 'AUBFRM%'
SELECT * FROM sys.sysprocesses where spid >50 and waittime >0 and blocked >0 --and hostname like 'AUBFRM%'
Exec sp_who2
exec sp_WhoIsActive @get_locks = 1 ;
--KILL 113
--DBCC inputbuffer(159)

select percent_complete,datediff(mi,start_time,getdate())as Temps_ecoule,text   
from sys.dm_exec_requests cross apply sys.dm_exec_sql_text (sql_handle) 
--where command like '%CREATE%' 


select  'print '''+ f.name+'''; USE '+'[EVVSMBAQUICKVILFR_1]'+' DBCC SHRINKFILE (N''' + f.name+''',0) ;',
    f.type_desc as [Type]
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
            --where f.type_desc not in ('LOG')
order by 7 desc 
option (recompile)


--SELECT * FROM Sys.sysprocesses where spid='91'

--SELECT * FROM sys.databases 

--FETCH API_CURSOR000000000000005A


--print 'QuickMDCube_FR_Data1'; USE QuickMDCube_FR DBCC SHRINKFILE (N'QuickMDCube_FR_Data1',0) ;



--SELECT CAST( 
--        ( 
--          SELECT CAST (cntr_value AS BIGINT) 
--          FROM sys.dm_os_performance_counters  
--          WHERE counter_name = 'Buffer cache hit ratio' 
--        )* 100.00 
--        / 
--        ( 
--          SELECT CAST (cntr_value AS BIGINT) 
--          FROM sys.dm_os_performance_counters  
--          WHERE counter_name = 'Buffer cache hit ratio base' 
--        ) AS NUMERIC(6,3) 
--      )