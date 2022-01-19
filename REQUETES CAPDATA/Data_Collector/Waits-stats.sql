USE [MDW]
GO

/****** Object:  StoredProcedure [snapshots].[rpt_wait_stats2]    Script Date: 15/09/2016 09:37:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [snapshots].[rpt_wait_stats2]
    @ServerName sysname,
    @EndTime datetime = NULL,
    @WindowSize int,
    @CategoryName nvarchar(20) = NULL, 
    @WaitType nvarchar(45) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Clean string params (on drillthrough, RS may pass in empty string instead of NULL)
    IF @CategoryName = '' SET @CategoryName = NULL
    IF @WaitType = '' SET @WaitType = NULL

    -- Divide our time window up into 40 evenly-sized time intervals, and find the last collection_time within each of these intervals
    CREATE TABLE #intervals (
        interval_time_id        int, 
        interval_start_time     datetimeoffset(7),
        interval_end_time       datetimeoffset(7),
        interval_id             int, 
        first_collection_time   datetimeoffset(7), 
        last_collection_time    datetimeoffset(7), 
        first_snapshot_id       int,
        last_snapshot_id        int, 
        source_id               int,
        snapshot_id             int, 
        collection_time         datetimeoffset(7), 
        collection_time_id      int
    )
    -- GUID 49268954-... is Server Activity
    INSERT INTO #intervals
    EXEC [snapshots].[rpt_interval_collection_times] 
        @ServerName, @EndTime, @WindowSize, 'snapshots.os_wait_stats', '49268954-4FD4-4EB6-AA04-CD59D9BB5714', 40, 0

    -- Get the earliest and latest snapshot_id values that contain data for the selected time interval. 
    -- This will allow a more efficient query plan. 
    DECLARE @start_snapshot_id int;
    DECLARE @end_snapshot_id int;
    SELECT @start_snapshot_id = MIN (first_snapshot_id)
    FROM #intervals
    SELECT @end_snapshot_id = MAX (last_snapshot_id)
    FROM #intervals
    
    -- Get the wait stats for these collection times
	SELECT 
		coll.interval_time_id, coll.interval_id, 
		last_collection_time AS collection_time, 
		coll.interval_start_time, 
		coll.interval_end_time, 
		coll.last_snapshot_id, 
		wt.category_name, ws.wait_type, ws.waiting_tasks_count, 
        ISNULL (ws.signal_wait_time_ms, 0) AS signal_wait_time_ms, 
        ISNULL (ws.wait_time_ms, 0) - ISNULL (ws.signal_wait_time_ms, 0) AS wait_time_ms, 
        wait_time_ms AS raw_wait_time_ms, 
        ISNULL (ws.wait_time_ms, 0) AS wait_time_ms_cumulative 
    INTO #wait_stats
    FROM snapshots.os_wait_stats AS ws
    INNER JOIN #intervals AS coll ON coll.last_snapshot_id = ws.snapshot_id AND coll.last_collection_time = ws.collection_time 
    INNER JOIN core.wait_types_categorized AS wt ON wt.wait_type = ws.wait_type
    WHERE wt.category_name = ISNULL (@CategoryName, wt.category_name)
        AND wt.wait_type = ISNULL (@WaitType, wt.wait_type)
        AND wt.ignore != 1
		AND wt.wait_type NOT IN (
        'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK',
        'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE',
        'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH',
        'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE',
        'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'BROKER_EVENTHANDLER',
        'TRACEWRITE', 'FT_IFTSHC_MUTEX', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        'BROKER_RECEIVE_WAITFOR', 'ONDEMAND_TASK_QUEUE', 'DBMIRROR_EVENTS_QUEUE',
        'DBMIRRORING_CMD', 'BROKER_TRANSMITTER', 'SQLTRACE_WAIT_ENTRIES',
        'SLEEP_BPOOL_FLUSH', 'SQLTRACE_LOCK','DIRTY_PAGE_POLL','HADR_FILESTREAM_IOMGR_IOCOMPLETION')
    

    -- Get wait times by waittype for each interval (plus CPU time, modeled as a waittype)
    ---- First get resource wait stats for this interval. We must convert all datetimeoffset values 
    ---- to UTC datetime values before returning to Reporting Services
    SELECT 
        CONVERT (datetime, SWITCHOFFSET (CAST (w1.collection_time AS datetimeoffset(7)), '+00:00')) AS collection_time, 
        CONVERT (datetime, SWITCHOFFSET (CAST (w1.interval_start_time AS datetimeoffset(7)), '+00:00')) AS interval_start, 
        CONVERT (datetime, SWITCHOFFSET (CAST (w2.interval_start_time AS datetimeoffset(7)), '+00:00')) AS interval_end, 
        w2.category_name, w2.wait_type, 
        -- All wait stats will be reset to zero by a service cycle, which will cause 
        -- (snapshot2waittime-snapshot1waittime) calculations to produce an incorrect 
        -- negative wait time for the interval.  Detect this and avoid calculating 
        -- negative wait time/wait count/signal time deltas. 
        CASE 
            WHEN (w2.waiting_tasks_count - w1.waiting_tasks_count) < 0 THEN w2.waiting_tasks_count 
            ELSE (w2.waiting_tasks_count - w1.waiting_tasks_count) 
        END AS waiting_tasks_count_delta, 
        CASE 
            WHEN (w2.raw_wait_time_ms - w1.raw_wait_time_ms) < 0 THEN w2.wait_time_ms
            ELSE (w2.wait_time_ms - w1.wait_time_ms)
        END AS resource_wait_time_delta, -- / CAST (DATEDIFF (second, w1.collection_time, w2.collection_time) AS decimal) 
        CASE 
            WHEN (w2.signal_wait_time_ms - w1.signal_wait_time_ms) < 0 THEN w2.signal_wait_time_ms 
            ELSE (w2.signal_wait_time_ms - w1.signal_wait_time_ms) 
        END AS resource_signal_time_delta, -- / CAST (DATEDIFF (second, w1.collection_time, w2.collection_time) AS decimal) 
        DATEDIFF (second, w1.collection_time, w2.collection_time) AS interval_sec, 
        w2.wait_time_ms_cumulative
    -- Self-join - w1 represents wait stats at the beginning of the sample interval, while w2 
    -- shows the wait stats at the end of the interval. 
    FROM #wait_stats AS w1 
    INNER JOIN #wait_stats AS w2 ON w1.wait_type = w2.wait_type AND w1.interval_id = w2.interval_id-1 

    UNION ALL 

    ---- Treat the sum of all signal waits as CPU "wait time"
    SELECT 
        MAX (CONVERT (datetime, SWITCHOFFSET (CAST (w1.collection_time AS datetimeoffset(7)), '+00:00'))) AS collection_time, 
        MIN (CONVERT (datetime, SWITCHOFFSET (CAST (w1.interval_start_time AS datetimeoffset(7)), '+00:00'))) AS interval_start, 
        MAX (CONVERT (datetime, SWITCHOFFSET (CAST (w2.interval_start_time AS datetimeoffset(7)), '+00:00'))) AS interval_end, 
        'CPU' AS category_name, 
        'CPU (Signal Wait)' AS wait_type, 
        0 AS waiting_tasks_count_delta, 
        -- Handle wait stats resets, as in the previous query
        SUM (
            CASE 
                WHEN (w2.signal_wait_time_ms - w1.signal_wait_time_ms) < 0 THEN w2.signal_wait_time_ms
                ELSE (w2.signal_wait_time_ms - w1.signal_wait_time_ms) 
            END -- / CAST (DATEDIFF (second, w1.collection_time, w2.collection_time) AS decimal)
        ) AS resource_wait_time_delta, 
        0 AS resource_signal_time_delta, 
        DATEDIFF (second, w1.collection_time, w2.collection_time) AS interval_sec, 
        NULL AS wait_time_ms_cumulative
    FROM #wait_stats AS w1
    INNER JOIN #wait_stats AS w2 ON w1.wait_type = w2.wait_type AND w1.interval_id = w2.interval_id-1
    -- Only return CPU stats if we were told to return the 'CPU' category or all categories
    WHERE (@CategoryName IS NULL OR @CategoryName = 'CPU')
    GROUP BY 
        w1.interval_start_time, w2.interval_start_time, w1.interval_end_time, w2.interval_end_time, w1.collection_time, w2.collection_time

    UNION ALL 

    -- Get actual used CPU time from perfmon data (average across the whole snapshot_time_id interval, 
    -- and use this average for each sample time in this interval).  Note that the "% Processor Time" 
    -- counter in the "Process" object can exceed 100% (for example, it can range from 0-800% on an 
    -- 8 CPU server). 
    SELECT
        CONVERT (datetime, SWITCHOFFSET (CAST (w1.collection_time AS datetimeoffset(7)), '+00:00')) AS collection_time, 
        CONVERT (datetime, SWITCHOFFSET (CAST (w1.interval_start_time AS datetimeoffset(7)), '+00:00')) AS interval_start, 
        CONVERT (datetime, SWITCHOFFSET (CAST (w2.interval_start_time AS datetimeoffset(7)), '+00:00')) AS interval_end, 
        'CPU' AS category_name, 
        'CPU (Consumed)' AS wait_type, 
        0 AS waiting_tasks_count_delta, 
        -- Get sqlservr %CPU usage for the perfmon sample that immediately precedes each wait stats sample.  
        -- Multiply by 10 to convert "% CPU" to "ms CPU/sec". This works because (for example) on an 8 proc 
        -- server, Process(...)\% Processor Time ranges from 0 to 800, not 0 to 100.  Multiply again by 
        -- the duration of interval in seconds to get the total ms of CPU time used in the interval. 
        DATEDIFF (second, w1.collection_time, w2.collection_time) * 10 * ( 
            SELECT TOP 1 formatted_value
            FROM snapshots.performance_counters AS pc
            INNER JOIN core.snapshots s ON pc.snapshot_id = s.snapshot_id
            WHERE pc.performance_object_name = 'Process' AND pc.performance_counter_name = '% Processor Time' 
                AND pc.performance_instance_name = '$(TARGETPROCESS)'
                AND pc.collection_time <= w2.collection_time
                AND s.instance_name = @ServerName AND s.collection_set_uid = '49268954-4FD4-4EB6-AA04-CD59D9BB5714' -- Server Activity CS
                AND s.snapshot_id BETWEEN @start_snapshot_id AND @end_snapshot_id 
            ORDER BY pc.collection_time DESC
        ) AS resource_wait_time_delta, 
        0 AS resource_signal_time_delta, 
        DATEDIFF (second, w1.collection_time, w2.collection_time) AS interval_sec, 
        NULL AS wait_time_ms_cumulative
    FROM #wait_stats AS w1
    INNER JOIN #wait_stats AS w2 ON w1.wait_type = w2.wait_type AND w1.interval_id = w2.interval_id-1
    -- Only return CPU stats if we weren't passed in a specific wait category
    WHERE (@CategoryName IS NULL OR @CategoryName = 'CPU')
    GROUP BY 
        w1.interval_start_time, w2.interval_start_time, w1.interval_end_time, w2.interval_end_time, w1.collection_time, w2.collection_time

    ORDER BY category_name, collection_time, wait_type
    -- These trace flags are necessary for a good plan, due to the join on ascending core.snapshot PK
    OPTION (QUERYTRACEON 2389, QUERYTRACEON 2390);
    
END

GO

