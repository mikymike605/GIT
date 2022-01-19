USE [msdb]
GO

/****** Object:  Job [ADM - CHECK_LAST_BACKUP]    Script Date: 6/25/2018 4:09:05 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 6/25/2018 4:09:05 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ADM - CHECK_LAST_BACKUP', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'QUICK\hamcham', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ADM - CHECK_LAST_BACKUP]    Script Date: 6/25/2018 4:09:05 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ADM - CHECK_LAST_BACKUP', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC AdminSQL.[dbo].[MONITOR_TBackupDB]', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'SCHEDULE_DAILY_5H00', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170711, 
		@active_end_date=99991231, 
		@active_start_time=50000, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [ADM - MONITOR POWERBI]    Script Date: 6/25/2018 4:09:05 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 6/25/2018 4:09:05 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ADM - MONITOR POWERBI', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Rapport PowerBI', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'QUICK\hamcham', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ADM - MONITOR POWERBI]    Script Date: 6/25/2018 4:09:05 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ADM - MONITOR POWERBI', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'INSERT INTO  [AUBFRTESTSQL02].[ADMINMONITOR].[DBO].[Monitor_Number_DB]
(
 [Servername]
      ,[MajorVersion]
      ,[SQLBuild]
      ,[DatabaseName]
      ,[CreateDateTime]
      ,[CompatibilityLevel]
      ,[CollationName]
      ,[RecoveryModel]
      ,[LastBackUpTime]
      ,[DatabaseSize]
      ,[DatabaseType]
      ,[DB_Name]
      ,[DB_Type]
      ,[SizeInMB]
      ,[Timestamp]
)
SELECT [Servername]
      ,[MajorVersion]
      ,[SQLBuild]
      ,[DatabaseName]
      ,[CreateDateTime]
      ,[CompatibilityLevel]
      ,[CollationName]
      ,[RecoveryModel]
      ,[LastBackUpTime]
      ,[DatabaseSize]
      ,[DatabaseType]
      ,[DB_Name]
      ,[DB_Type]
      ,[SizeInMB]
      ,[Timestamp]
  FROM [AUBFRTESTSQL02].[ADMINMONITOR].[dbo].[Monitor_Powerbi2]
  WHERE Servername = @@SERVERNAME

  
DELETE [AUBFRTESTSQL02].[ADMINMONITOR].[dbo].[Monitor_Number_DB]   where [Timestamp] < DATEADD(hour, -6, GETDATE()) and Servername = @@SERVERNAME

DELETE  FROM  AUBFRTESTSQL02.[AdminMonitor].dbo.[Monitor_Powerbi2]
WHERE Servername=@@servername
 
DELETE  FROM  AUBFRTESTSQL02.[AdminMonitor].dbo.[Monitor_SpaceDisk]
WHERE Servername=@@servername



CREATE TABLE #tmpDATA(
	[Servername] [varchar](250) NULL,
	[MajorVersion] [varchar](250) NULL,
	[SQLBuild] [varchar](250) NULL,
	[DatabaseName] [varchar](250) NULL,
	[CreateDateTime] [datetime] NULL,
	[CompatibilityLevel] [int] NULL,
	[CollationName] [varchar](250) NULL,
	[RecoveryModel] [varchar](50) NULL,
	[LastBackUpTime] [datetime] NULL,
	[DatabaseSize] [decimal](18, 2) NULL,
	[DatabaseType] [varchar](50) NULL,
	[DB_Name] [varchar](250) NULL,
	[DB_Type] [varchar](250) NULL,
	[SizeInMB] [decimal](18, 2) NULL,
	[Timestamp] [datetime] NULL
) ON [PRIMARY]


INSERT INTO #tmpDATA([Servername]
      ,[MajorVersion]
      ,[SQLBuild]
      ,[DatabaseName]
      ,[CreateDateTime]
      ,[CompatibilityLevel]
      ,[CollationName]
      ,[RecoveryModel]
      ,[LastBackUpTime]
      ,[DatabaseSize]
      ,[DatabaseType])
      --,[DB_Name]
      --,[DB_Type]
      --,[SizeInMB]
      --,[Timestamp])

SELECT  @@servername as Servername,
 CASE 
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY (''productversion'')) like ''8%'' THEN ''Microsoft SQL Server 2000''
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY (''productversion'')) like ''9%'' THEN ''Microsoft SQL Server 2005''
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY (''productversion'')) like ''10.0%'' THEN ''Microsoft SQL Server 2008''
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY (''productversion'')) like ''10.5%'' THEN ''Microsoft SQL Server 2008 R2''
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY (''productversion'')) like ''11%'' THEN ''Microsoft SQL Server 2012''
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY (''productversion'')) like ''12%'' THEN ''Microsoft SQL Server 2014''
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY (''productversion'')) like ''13%'' THEN ''Microsoft SQL Server 2016''     
     ELSE ''unknown''
  END AS MajorVersion,
  CONVERT (varchar, SERVERPROPERTY(''ProductVersion'')) AS SQLBuild,  
--@@version SQLVersion,
sdb.NAME DatabaseName,
sdb.create_date CreateDateTime,
sdb.compatibility_level CompatibilityLevel,
sdb.collation_name CollationName,
sdb.recovery_model_desc RecoveryModel,
Max(bus.backup_finish_date) AS LastBackUpTime,
size.SizeinMB DatabaseSize,
CASE
WHEN sdb.database_id < 5 THEN ''System''
ELSE ''User''
END DatabaseType
FROM sys.databases sdb
LEFT OUTER JOIN msdb.dbo.backupset bus
ON bus.database_name = sdb.NAME
INNER JOIN (SELECT [DatabaseName] = Db_name(database_id),
[Type] = CASE
WHEN type_desc = ''ROWS'' THEN ''Data File(s)''
WHEN type_desc = ''LOG'' THEN ''Log File(s)''
ELSE type_desc
END,
[SizeinMB] = Cast(( ( Sum(size) ) / 1024.0 ) * 8 AS
DECIMAL(18, 2))
FROM sys.master_files
--GROUP BY database_id
GROUP BY  Db_name(database_id), type_desc) size
ON sdb.NAME = size.DatabaseName
AND size.Type IS NULL
	--where sdb.NAME not in (''msdb'',''master'',''model'')
GROUP BY sdb.NAME,
sdb.create_date,
sdb.compatibility_level,
sdb.collation_name,
sdb.recovery_model_desc,
size.SizeinMB,
sdb.database_id


UNION ALL

SELECT  @@servername as Servername,
 CASE 
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY (''productversion'')) like ''8%'' THEN ''Microsoft SQL Server 2000''
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY (''productversion'')) like ''9%'' THEN ''Microsoft SQL Server 2005''
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY (''productversion'')) like ''10.0%'' THEN ''Microsoft SQL Server 2008''
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY (''productversion'')) like ''10.5%'' THEN ''Microsoft SQL Server 2008 R2''
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY (''productversion'')) like ''11%'' THEN ''Microsoft SQL Server 2012''
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY (''productversion'')) like ''12%'' THEN ''Microsoft SQL Server 2014''
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY (''productversion'')) like ''13%'' THEN ''Microsoft SQL Server 2016''     
     ELSE ''unknown''
  END AS MajorVersion,
  CONVERT (varchar, SERVERPROPERTY(''ProductVersion'')) AS SQLBuild,  
--@@version SQLVersion,
sdb.NAME DatabaseName,
sdb.create_date CreateDateTime,
sdb.compatibility_level CompatibilityLevel,
sdb.collation_name CollationName,
sdb.recovery_model_desc RecoveryModel,
Max(bus.backup_finish_date) AS LastBackUpTime,
size.SizeinMB DatabaseSize,
CASE
WHEN sdb.database_id < 5 THEN ''System''
ELSE ''User''
END DatabaseType
FROM sys.databases sdb
LEFT OUTER JOIN msdb.dbo.backupset bus
ON bus.database_name = sdb.NAME
INNER JOIN (SELECT [DatabaseName] = Db_name(database_id),
null  as [Type] ,
[SizeinMB] = Cast(( ( Sum(size) ) / 1024.0 ) * 8 AS
DECIMAL(18, 2))
FROM sys.master_files
--GROUP BY database_id
GROUP BY  Db_name(database_id) ) size
ON sdb.NAME = size.DatabaseName
AND size.Type IS NULL
	--where sdb.NAME not in (''msdb'',''master'',''model'')
GROUP BY sdb.NAME,
sdb.create_date,
sdb.compatibility_level,
sdb.collation_name,
sdb.recovery_model_desc,
size.SizeinMB,
sdb.database_id

--SELECT * FROM #tmpDATA


---------------------Requete 2


SELECT [DatabaseName] = Db_name(database_id),
[Type] = CASE
WHEN type_desc = ''ROWS'' THEN ''Data File(s)''
WHEN type_desc = ''LOG'' THEN ''Log File(s)''
ELSE type_desc
END,
[SizeinMB] = Cast(( ( Sum(size)  ) / 1024.0 ) AS DECIMAL(18, 2))* 8
,[Timestamp]= getdate()
Into #tmpDATA2
FROM sys.master_files
where name not in (''msdb'',''master'',''model'')
--GROUP BY grouping sets ( ( Db_name(database_id), type_desc ),
GROUP BY  Db_name(database_id), type_desc 
order by 1




--SELECT * FROM #tmpDATA2

INSERT AUBFRTESTSQL02.[AdminMonitor].dbo.[Monitor_Powerbi2]
(
[Servername]
      ,[MajorVersion]
      ,[SQLBuild]	
      ,[DatabaseName]
      ,[CreateDateTime]
      ,[CompatibilityLevel]
      ,[CollationName]
      ,[RecoveryModel]
      ,[LastBackUpTime]
      ,[DatabaseSize]
      ,[DatabaseType]
      ,[DB_Name]
      ,[DB_Type]
      ,[SizeInMB]
      ,[Timestamp]
)
SELECT  [Servername]
      ,[MajorVersion]
      ,convert (varchar,[SQLBuild]) [SQLBuild]
      ,A.[DatabaseName]
      ,[CreateDateTime]
      ,[CompatibilityLevel]
      ,[CollationName]
      ,[RecoveryModel]
      ,[LastBackUpTime]
      ,[DatabaseSize]
      ,[DatabaseType]
      ,b.[DatabaseName]
      ,[Type]
      ,b.[SizeinMB] 
      ,b.[Timestamp]
FROM  #tmpDATA A 
Inner join #tmpDATA2 b 
on A.DatabaseName =b.DatabaseName --and A.DatabaseSize=b.SizeinMB


DROP TABLE #tmpDATA 
DROP TABLE #tmpDATA2 
---------------------Requete 3
 EXEC sp_configure ''xp_cmdshell'', 1; RECONFIGURE


declare @svrName varchar(255)
declare @sql varchar(400)
--by default it will take the current server name, we can the set the server name as well
set @svrName =  (SELECT substring(@@servername,1,CASE  charindex(''\'',@@servername) when 0 then len(@@servername) else charindex(''\'',@@servername)-1 end ))
set @sql = ''C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -c "Get-WmiObject -ComputerName '' + QUOTENAME(@svrName,'''''''') + '' -Class Win32_Volume -Filter ''''DriveType = 3'''' | select name,capacity,freespace | foreach{$_.name+''''|''''+$_.capacity/1048576+''''%''''+$_.freespace/1048576+''''*''''}"''

print @sql
--creating a temporary table
CREATE TABLE #output
(line varchar(255))
--inserting disk name, total space and free space value in to temporary table
insert #output
EXEC xp_cmdshell @sql
INSERT INTO AUBFRTESTSQL02.[AdminMonitor].[dbo].[Monitor_SpaceDisk]
( [Servername]
      ,[DriveName]
      ,[Capacity(GB)]
      ,[FreeSpace(GB)]
      ,[Timestamp])
select  @@servername, rtrim(ltrim(SUBSTRING(line,1,CHARINDEX(''|'',line) -1))) as drivename
   ,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX(''|'',line)+1,
   (CHARINDEX(''%'',line) -1)-CHARINDEX(''|'',line)) )) as Float)/1024,0) as ''capacity(GB)''
   ,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX(''%'',line)+1,
   (CHARINDEX(''*'',line) -1)-CHARINDEX(''%'',line)) )) as Float) /1024 ,0)as ''freespace(GB)''
,Timestamp = getdate()
from #output
where line like ''[A-Z][:]%''
order by drivename
--script to drop the temporary table
drop table #output


----SELECT * FROM  [AdminMonitor].dbo.[Monitor_Powerbi2]
----SELECT * FROM  [AdminMonitor].dbo.[Monitor_SpaceDisk]
----DELETE FROM   [AdminMonitor].dbo.[Monitor_Powerbi2]where servername = ''VILFRMDBRIDGE''
----DELETE FROM  [AdminMonitor].dbo.[Monitor_SpaceDisk] where servername = ''VILFRMDBRIDGE''
----TRUNCATE TABLE [AdminMonitor].dbo.[Monitor_Powerbi2]
----TRUNCATE TABLE [AdminMonitor].dbo.[Monitor_SpaceDisk]

----DECLARE @servername varchar(250)
----DECLARE product_cursor CURSOR FOR SELECT name FROM [AdminMonitor].[dbo].[MonitorServer]
----OPEN product_cursor  
----FETCH NEXT FROM product_cursor INTO @servername  
----IF @@FETCH_STATUS <> 0   PRINT ''         <<None>>''       
----WHILE @@FETCH_STATUS = 0  
----    BEGIN  
----		EXEC [AdminMonitor].[dbo].[MONITOR_POWERBI]  ''VILFRMDBRIDGE''
----        FETCH NEXT FROM product_cursor INTO @servername  
----	END  
----CLOSE product_cursor  
----DEALLOCATE product_cursor  
----GO





--SELECT [Servername]
--      ,[MajorVersion]
--      ,convert (varchar,[SQLBuild])
--      ,A.[DatabaseName]
--      ,[CreateDateTime]
--      ,[CompatibilityLevel]
--      ,[CollationName]
--      ,[RecoveryModel]
--      ,[LastBackUpTime]
--      --,[DatabaseSize]
--      ,[DatabaseType]
--      ,b.[DatabaseName]
--      ,[Type]
--      ,b.[SizeinMB]
--FROM  #tmpDATA A 
--Inner join #tmpDATA2 b 
--on A.DatabaseName =b.DatabaseName and A.DatabaseSize=b.SizeinMB
--drop table #tmpDATA
--drop table #tmpDATA2


--DELETE  FROM  AUBFRTESTSQL02.[AdminMonitor].dbo.[Monitor_Power_bi]
--DELETE  FROM  AUBFRTESTSQL02.[AdminMonitor].dbo.[Monitor_SpaceDisk]

--SELECT * FROM AUBFRTESTSQL02.[AdminMonitor].dbo.[Monitor_Power_bi]
--SELECT * FROM AUBFRTESTSQL02.[AdminMonitor].dbo.[Monitor_SpaceDisk]



', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'ADM-Monitor PowerBY 07H00', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20171212, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

