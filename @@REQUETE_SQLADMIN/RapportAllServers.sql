/****** Script for SelectTopNRows command from SSMS  ******/
SELECT  Servername
FROM [AdminMonitor].[dbo].[MonitorTBserver] b
	where  not exists
( 
SELECT m.Servername, m.metric_name, m.timestamp
	FROM [AdminMonitor].[dbo].[MONITOR] M
	--INNER JOIN [AdminMonitor].[dbo].[MonitorTBserver] TB 
	--on m.Servername=TB.Servername
	where m.category like 'AVAILABILTY'
	and m.timestamp >= DATEADD (minute , -1 , GETDATE() )
and b.Servername=m.servername
)