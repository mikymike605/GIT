/****** Script for SelectTopNRows command from SSMS  ******/
SELECT CASE WHEN servername ='[VILFRSAPBWD\BWD]' THEN 'VILFRSAPBWD\BWD'
			WHEN Servername = '[VILFRSAPBWQ\BWQ]' THEN 'VILFRSAPBWQ\BWQ'
			WHEN Servername = '[VILFRSAPBWP\BWP]' THEN 'VILFRSAPBWP\BWP'
ELSE Servername end AS SERVERNAME
 FROM [AdminMonitor].[dbo].[Monitor_Job_History_MaintencePlan]
  where timestamp >= DATEADD(minute, -1, GETDATE())
and servername not in ('KINGAWOSQL01','KINGAWOSQL02','KINGAWOSQL03')
  order by LastRunDateTime desc

  SELECT CASE WHEN name = '[VILFRSAPBWP\BWP]'  then 'VILFRSAPBWP\BWP' 
WHEN name = '[VILFRSAPBWD\BWD]'  then 'VILFRSAPBWD\BWD' 
WHEN name = '[VILFRSAPBWQ\BWQ]'  then 'VILFRSAPBWQ\BWQ'
else  name
end as name 
FROM [AdminMonitor].[dbo].[MonitorServer]   