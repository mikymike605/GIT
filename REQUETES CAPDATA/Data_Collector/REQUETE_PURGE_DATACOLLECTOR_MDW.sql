use MDW
-- Which instances are currently in MDW
SELECT distinct instance_name
FROM core.snapshots
WHERE instance_name = 'KINGSIDSQLPRD'
-- WHERE instance_name like '%<instance_name>' 
-- This is optional. I have over 300 instances, so this makes it easier to find.
SELECT s.snapshot_id, s.snapshot_time, s.instance_name, s.collection_set_uid
FROM core.snapshots s
WHERE s.instance_name = 'KINGSIDSQLPRD'
order by 2 desc
SELECT s.snapshot_id, s.snapshot_time, s.instance_name, s.collection_set_uid
FROM core.snapshots s
WHERE GETUTCDATE() >= DATEADD(DAY, 0, s.snapshot_time)
AND s.instance_name = 'KINGSIDSQLPRD'
order by 2 desc

use MDW

EXECUTE core.sp_purge_data @retention_days = 0, @instance_name = 'KINGSIDSQLPRD'