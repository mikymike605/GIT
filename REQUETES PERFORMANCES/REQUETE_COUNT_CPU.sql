SELECT (cpu_count / hyperthread_ratio) AS PhysicalCPUs,   
cpu_count AS logicalCPUs 
FROM sys.dm_os_sys_info  


SELECT cpu_count AS [Logical CPU Count], hyperthread_ratio AS Hyperthread_Ratio,
cpu_count/hyperthread_ratio AS Physical_CPU_Count,
physical_memory_in_bytes/1024/1024 AS Physical_Memory_in_MB,
sqlserver_start_time
--,affinity_type_desc --— (affinity_type_desc is only in 2008 R2)
FROM sys.dm_os_sys_info