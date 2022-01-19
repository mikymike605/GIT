/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @Collection_Set_Uid nvarchar(128)
DECLARE @datedeb datetime = DATEADD(MINUTE,- 15, getutcdate())

CREATE TABLE #result (
Counter_subgroup_id varchar(50),
series_name varchar(50),
interval_id int,
interval_end_time datetime,
counter_name varchar(128),
avg_formatted_value float,
max_formatted_value float,
min_formatted_value float,
multi_instance_avg_formatted_value bigint)

SELECT @Collection_Set_Uid=[collection_set_uid]
FROM [msdb].[dbo].[syscollector_collection_sets]
where name='Server Activity'

INSERT INTO #result exec mdw.snapshots.rpt_generic_perfmon 'aubfrcognossql' ,@datedeb,60,'ServerActivity',@Collection_Set_Uid

select *,series_name, interval_end_time, avg_formatted_value
from #result
--WHERE Counter_subgroup_id ='cpuUsage'
--AND counter_name='% Processor Time'

DROP TABLE #result
