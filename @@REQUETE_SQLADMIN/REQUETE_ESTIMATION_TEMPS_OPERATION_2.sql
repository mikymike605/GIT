SELECT
       session_id, status
      , command
      , DB_NAME(database_id) AS DBName
      , start_time AS [Start Time]
      , estimated_completion_time / 3600000 AS [Estimated Completion Time (Hours)] 
      , total_elapsed_time / 60000 AS [Elapsed Time (Minutes)] 
      , CAST(percent_complete AS DECIMAL(5,2)) AS [Percent Complete]
FROM    sys.dm_exec_requests
WHERE   command = 'DbccFilesCompact' OR command = 'BACKUP DATABASE' OR command = 'RESTORE DATABASE' OR command = 'DbccSpaceReclaim'
OR percent_complete > 0