--exec snapshots.rpt_snapshot_times @ServerName=N'KINGSQL2014',@EndTime='2017-10-18 07:45:01',@WindowSize=240,@CollectionSetUid=N'2DC02BD6-E230-4C05-8516-4E8C0EF21F95'

--exec sp_executesql @stmt=N'SELECT TOP 1 
--    cs.name, 
--    cs.is_running, 
--    CONVERT (datetime, SWITCHOFFSET (TODATETIMEOFFSET (el.finish_time, DATENAME (TZoffset, SYSDATETIMEOFFSET())), ''+00:00'')) AS last_upload_time,
--    el.status AS upload_status
--FROM msdb.dbo.syscollector_collection_sets cs
--LEFT OUTER JOIN msdb.dbo.syscollector_execution_log el 
--    ON (el.collection_set_id = cs.collection_set_id AND el.runtime_execution_mode = 1 AND el.package_id IS NULL)
--WHERE cs.collection_set_uid = @CollectionSetUid
--ORDER BY el.finish_time DESC',@params=N'@CollectionSetUid NVarChar(max)',@CollectionSetUid=N'2DC02BD6-E230-4C05-8516-4E8C0EF21F95'

exec snapshots.rpt_query_stats @instance_name=N'KINGSQL2014',@end_time='2017-10-18 07:45:01',@time_window_size=240,@sql_handle_str=N'0x030009007f186551268adf0086a7000001000000000000000000000000000000000000000000000000000000',@statement_start_offset=244,@statement_end_offset=852


SELECT 
        REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (
            LEFT (LTRIM (stmtsql.query_text), 100)
            , CHAR(9), ' '), CHAR(10), ' '), CHAR(13), ' '), '   ', ' '), '  ', ' '), '  ', ' ') AS flat_query_text, 
        t.*, 
        master.dbo.fn_varbintohexstr (t.sql_handle) AS sql_handle_str, 
        stmtsql.*
    FROM 
    (
        SELECT 
            stat.sql_handle, stat.statement_start_offset, stat.statement_end_offset, snap.source_id, 
            SUM (stat.snapshot_execution_count) AS execution_count, 
            SUM (stat.snapshot_execution_count) / (@interval_sec / 60) AS executions_per_min, 
            SUM (stat.snapshot_worker_time / 1000) AS total_cpu, 
            SUM (stat.snapshot_worker_time / 1000) / @interval_sec AS avg_cpu_per_sec, 
            SUM (stat.snapshot_worker_time / 1000.0) / CASE SUM (stat.snapshot_execution_count) WHEN 0 THEN 1 ELSE SUM (stat.snapshot_execution_count) END AS avg_cpu_per_exec, 
            SUM (stat.snapshot_physical_reads) AS total_physical_reads, 
            SUM (stat.snapshot_physical_reads) / @interval_sec AS avg_physical_reads_per_sec, 
            SUM (stat.snapshot_physical_reads) / CASE SUM (stat.snapshot_execution_count) WHEN 0 THEN 1 ELSE SUM (stat.snapshot_execution_count) END AS avg_physical_reads_per_exec, 
            SUM (stat.snapshot_logical_writes) AS total_logical_writes, 
            SUM (stat.snapshot_logical_writes) / @interval_sec AS avg_logical_writes_per_sec, 
            SUM (stat.snapshot_logical_writes) / CASE SUM (stat.snapshot_execution_count) WHEN 0 THEN 1 ELSE SUM (stat.snapshot_execution_count) END AS avg_logical_writes_per_exec, 
            SUM (stat.snapshot_elapsed_time / 1000) AS total_elapsed_time, 
            SUM (stat.snapshot_elapsed_time / 1000) / @interval_sec AS avg_elapsed_time_per_sec, 
            SUM (stat.snapshot_elapsed_time / 1000.0) / CASE SUM (stat.snapshot_execution_count) WHEN 0 THEN 1 ELSE SUM (stat.snapshot_execution_count) END AS avg_elapsed_time_per_exec, 
            COUNT(*) AS row_count, COUNT(DISTINCT plan_number) AS plan_count
        FROM
        (
            SELECT *, DENSE_RANK() OVER (ORDER BY plan_handle, creation_time) AS plan_number
            FROM snapshots.query_stats
        ) AS stat
        INNER JOIN core.snapshots snap ON stat.snapshot_id = snap.snapshot_id
        WHERE
            snap.instance_name = @instance_name 
            AND stat.sql_handle = @sql_handle 
            AND stat.statement_start_offset = @statement_start_offset 
            AND stat.statement_end_offset = @statement_end_offset
            AND snap.snapshot_time_id BETWEEN @start_snapshot_time_id AND @end_snapshot_time_id
        GROUP BY stat.sql_handle, stat.statement_start_offset, stat.statement_end_offset, snap.source_id
    ) t
    LEFT OUTER JOIN snapshots.notable_query_text sql ON t.sql_handle = sql.sql_handle and sql.source_id = t.source_id
    OUTER APPLY snapshots.fn_get_query_text (t.source_id, t.sql_handle, t.statement_start_offset, t.statement_end_offset) AS stmtsql
    -- These trace flags are necessary for a good plan, due to the join on ascending PK w/range filter
    OPTION (QUERYTRACEON 2389, QUERYTRACEON 2390)