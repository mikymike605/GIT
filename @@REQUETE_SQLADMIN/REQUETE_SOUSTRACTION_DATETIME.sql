--/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT  StartTime-EndTime,*
--  FROM [master].[dbo].[CommandLog]
--  where DatabaseName='SID_PRD'
--  and StartTime >= '20180618 15:00'
--  and CommandType like '%INDEX%'
--  order by StartTime

--select CONVERT(time(7),DATEADD(s, DATEDIFF(s,StartTime,EndTime),'00:00:00')) ,PartitionNumber,ObjectName,SchemaName
--,StartTime
--,EndTime,Command
--  FROM [master].[dbo].[CommandLog] 
--  where DatabaseName='sid_prd'
--  --and ObjectName='ADO_ARTICLE'
--  --and StartTime between '20180618 18:00'  and '20180630 9:00'
--  --and cast (StartTime as date) >=cast (getdate ()-2 as date)
--  and cast (StartTime as date) >=cast (getdate ()-20 as date)
--  and CommandType like '%INDEX%'
--    and ObjectName like 'MD%'
--  --and EndTime is null
--group by StartTime,EndTime,PartitionNumber,command,ObjectName,SchemaName
--having CONVERT(time(7),DATEADD(s, DATEDIFF(s,StartTime,EndTime),'00:00:00'))>'01:30:00'
--order by 3 desc 
--GO

select CONVERT(time(7),DATEADD(s, DATEDIFF(s,StartTime,EndTime),'00:00:00')) ,PartitionNumber,ObjectName,SchemaName
,StartTime
,EndTime,Command
  FROM [AdminSQL].[dbo].[CommandLog] 
  ----where DatabaseName like'AdminSQL%'
	  --where ObjectName like 'SEM_MISC_TRAN_SALES'
  where cast (StartTime as date) >=cast (getdate ()-1 as date)
  --where cast (StartTime as date) >=cast (getdate ()-10 as date)
     and Command like '%index%'
  --and ObjectName like 'Segment'
  group by StartTime,EndTime,PartitionNumber,command,ObjectName,SchemaName
--having CONVERT(time(7),DATEADD(s, DATEDIFF(s,StartTime,EndTime),'00:00:00'))>'01:10:00'
order by EndTime desc
GO

select CONVERT(time(7),DATEADD(s, DATEDIFF(s,StartTime,EndTime),'00:00:00')) ,PartitionNumber,ObjectName,SchemaName
,StartTime
,EndTime,Command
  FROM [master].[dbo].[CommandLog] 
  ----where DatabaseName like'AdminSQL%'
	  --where ObjectName like 'REB_INVOICEDETAIL'
   where cast (StartTime as date) >=cast (getdate ()-20 as date)
     and Command like '%INDEX%'
  and ObjectName like 'MD5%'
  group by StartTime,EndTime,PartitionNumber,command,ObjectName,SchemaName
having CONVERT(time(7),DATEADD(s, DATEDIFF(s,StartTime,EndTime),'00:00:00'))>'00:10:00'
order by 1 desc
GO
