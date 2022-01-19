SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
GO

DECLARE @max_server_memory_MB int
        , @memory_node_count int
        , @node_ple_threshold int

-- Lecture de la valeur configurée pour l'option max server memory (MB)
SELECT  @max_server_memory_MB = CAST(value AS int)
FROM    sys.configurations
WHERE   name = 'max server memory (MB)'

-- Lecture du nombre de noeuds NUMA
SELECT  @memory_node_count = COUNT(*)
FROM    sys.dm_os_memory_nodes
WHERE   memory_node_id = 64 -- le noeud 64 est pour la fonctionnalité Dedicated Administrator Connection

-- Application de la règle de trois au seuil édité par Microsoft en 2006
SELECT  @node_ple_threshold = ((@max_server_memory_MB / @memory_node_count) * 300/ 8192) 

-- Affichage des valeurs obtenues
SELECT  @max_server_memory_MB AS max_server_memory_MB
        , @memory_node_count AS memory_node_count
        , @node_ple_threshold AS NUMA_node_PLE_threshold

-- Exposition de la PLE pour chaque noeud NUMA
SELECT          S.parent_node_id
                , PC.cntr_value AS node_PLE
                , PC.cntr_value / @node_ple_threshold AS min_PLE_factor
                , CASE WHEN PC.cntr_value <> @node_ple_threshold THEN 'KO' ELSE 'OK' END AS node_PLE_state
FROM            sys.dm_exec_requests AS R
INNER JOIN      sys.dm_os_schedulers AS S
                        ON R.scheduler_id = S.scheduler_id
INNER JOIN      sys.dm_os_performance_counters AS PC
                        ON PC.instance_name = REPLICATE('0', 3 - LEN(S.parent_node_id)) + CAST(S.parent_node_id AS varchar(10))
WHERE           R.command = 'LAZY WRITER' -- Il existe un processus Lazywriter par noeud NUMA
AND             PC.counter_name = 'Page life expectancy'

EXEC sp_configure @configname='recovery interval (min)';  

SELECT COUNT(*) FROM sys.dm_os_performance_counters;  --If no values from the firs query, an value of 0 here indicates a seperate issue  https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-performance-counters-transact-sql

  --plan cache Life expectancy
    SELECT sys.dm_exec_cached_plans.objtype AS [CacheType] 
    ,    COUNT_BIG(*) AS [Total Plans]
    ,    SUM(CAST(sys.dm_exec_cached_plans.size_in_bytes AS DECIMAL(18, 2))) / 1024 / 1024 AS [Total MBs]
    ,   AVG(sys.dm_exec_cached_plans.usecounts) AS [Avg Use Count]
    ,   AVG (DATEDIFF(MINUTE, PH_Time.creation_time, (GETDATE()))) AS [Avg Age in Minutes]
    FROM sys.dm_exec_cached_plans
    left join (
                Select  plan_handle
                , Min (creation_time) as creation_time --A plan can have several unique related quiries, this gets just one time per plan
                from sys.dm_exec_query_stats
                group by plan_handle
                ) as PH_Time On sys.dm_exec_cached_plans.plan_handle = PH_Time.plan_handle
    --left join sys.dm_exec_query_stats On sys.dm_exec_cached_plans.plan_handle = sys.dm_exec_query_stats.plan_handle 
    GROUP BY objtype
    ORDER BY [Total MBs] DESC
    GO

SELECT [object_name],
[counter_name],
[cntr_value] FROM sys.dm_os_performance_counters -- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-performance-counters-transact-sql
WHERE [counter_name] = 'Page life expectancy' --if multiple NUMA on a server should return multiple Nodes, 
OR [counter_name] = 'Free list stalls/sec'  -- Number of requests per second that had to wait for a free page https://docs.microsoft.com/en-us/sql/relational-databases/performance-monitor/sql-server-buffer-manager-object
OR [counter_name] = 'Lazy writes/sec' --Flushes of dirty pages before a checkpoint runs.  
OR [counter_name] = 'Buffer cache hit ratio' --percentage of pages found in the buffer cache without having to read from disk you want this ratio to be high
Order by [counter_name] DESC, [object_name];

SELECT @@SERVERNAME AS 'INSTANCE',
[object_name],
[counter_name],
CASE
WHEN [counter_name] = 'Page life expectancy'
THEN (
SELECT DATEDIFF(MI, MAX([login_time]), GETDATE())
FROM sys.dm_exec_sessions DMES
INNER JOIN sys.dm_exec_requests DMER
ON [DMES].[session_id] = [DMER].[session_id]
WHERE [command] = 'LAZY WRITER'
)
ELSE ''
END AS 'UPTIME_MIN',
[cntr_value] AS 'PLE_SECS',
[cntr_value] / 60 AS 'PLE_MINS',
[cntr_value] / 3600 AS 'PLE_HOURS',
[cntr_value] / 86400 AS 'PLE_DAYS'
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Manager%'
AND [counter_name] = 'Page life expectancy';