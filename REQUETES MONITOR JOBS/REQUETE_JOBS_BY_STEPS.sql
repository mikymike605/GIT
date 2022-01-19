DECLARE @debut_date  datetime
SET @debut_date = convert (char (8),GETDATE()-1,112)

Select sJob.name As Job_Name
  ,sJob.Description
  --,sJob.Originating_Server
  ,STUFF(
            STUFF(RIGHT('000000' + CAST([sJOBH].[run_duration] AS VARCHAR(6)),  6)
                , 3, 0, ':')
            , 6, 0, ':') 
        AS [LastRunDuration (HH:MM:SS)]
  , CASE 
        WHEN [sJOBH].[run_date] IS NULL OR [sJOBH].[run_time] IS NULL THEN NULL
        ELSE CAST(
                CAST([sJOBH].[run_date] AS CHAR(8))
                + ' ' 
                + STUFF(
                    STUFF(RIGHT('000000' + CAST([sJOBH].[run_time] AS VARCHAR(6)),  6)
                        , 3, 0, ':')
                    , 6, 0, ':')
                AS DATETIME)
      END AS [LastRunDateTime]
  ,CASE [sJOBH].[run_status]
        WHEN 0 THEN 'Failed'
        WHEN 1 THEN 'Succeeded'
        WHEN 2 THEN 'Retry'
        WHEN 3 THEN 'Canceled'
        WHEN 4 THEN 'Running' -- In Progress
      END AS [LastRunStatus]
  ,sJob.start_step_id As Start_At_Step
  ,Case
     When sJob.enabled = 1
       Then 'Enabled'
     When sJob.enabled = 0
       Then 'Not Enabled'
     Else 'Unknown Status'
   End As Job_Status
  ,Replace(Replace(sCat.name,'[',''),']','') As Category
  ,sJStp.step_id As Step_No
  ,sJStp.step_name AS StepName
  ,Case sJStp.subsystem
     When 'ActiveScripting'
       Then 'ActiveX Script'
     When 'CmdExec'
       Then 'Operating system (CmdExec)'
     When 'PowerShell'
       Then 'PowerShell'
     When 'Distribution'
       Then 'Replication Distributor'
     When 'Merge'
       Then 'Replication Merge'
     When 'QueueReader'
       Then 'Replication Queue Reader'
     When 'Snapshot'
       Then 'Replication Snapshot'
     When 'LogReader'
       Then 'Replication Transaction-Log Reader'
     When 'ANALYSISCOMMAND'
       Then 'SQL Server Analysis Services Command'
     When 'ANALYSISQUERY'
       Then 'SQL Server Analysis Services Query'
     When 'SSIS'
       Then 'SQL Server Integration Services Package'
     When 'TSQL'
       Then 'Transact-SQL script (T-SQL)'
     Else sJStp.subsystem
   End As Step_Type
  ,sJStp.database_name AS Database_Name
  --,sJStp.command AS ExecutableCommand
  ,Case sJStp.on_success_action
     When 1
       Then 'Quit the job reporting success'
     When 2
       Then 'Quit the job reporting failure'
     When 3
       Then 'Go to the next step'
     When 4
       Then 'Go to Step: '
         + QuoteName(Cast(sJStp.on_success_step_id As Varchar(3)))
         + ' '
         + sOSSTP.step_name
   End As On_Success_Action
  ,sJStp.retry_attempts AS RetryAttempts
  ,sJStp.retry_interval AS RetryInterval_Minutes
  ,Case sJStp.on_fail_action
     When 1
       Then 'Quit the job reporting success'
     When 2
       Then 'Quit the job reporting failure'
     When 3
       Then 'Go to the next step'
     When 4
       Then 'Go to Step: '
         + QuoteName(Cast(sJStp.on_fail_step_id As Varchar(3)))
         + ' '
         + sOFSTP.step_name
   End As On_Failure_Action
  ,GetDate() As Date_List_Generated
From msdb.dbo.sysjobsteps As sJStp
  Inner Join msdb.dbo.sysjobs As sJob
    On sJStp.job_id = sJob.job_id
  Left Join msdb.dbo.sysjobsteps As sOSSTP
    On sJStp.job_id = sOSSTP.job_id
      And sJStp.on_success_step_id = sOSSTP.step_id
  Left Join msdb.dbo.sysjobsteps As sOFSTP
    On sJStp.job_id = sOFSTP.job_id
      And sJStp.on_fail_step_id = sOFSTP.step_id
  Inner Join msdb..syscategories sCat
    On sJob.category_id = sCat.category_id
	inner join [msdb].[dbo].sysjobhistory as sJOBH
	ON sJStp.[step_id] = [sJOBH].[step_id] and sJStp.job_id=sJOBH.job_id
	where sJob.enabled = 1
	and convert (char (8),[sJOBH].[run_date],112) >=@debut_date
	and [sJOBH].[run_status] <>1
	--and sJob.name like 'ADM%'
Order By  4 desc  ,3 desc

--SELECT count (distinct j.name) total_jobs
--,h.run_date
----,"Tbl1012"."run_time" "Col1047"
----,"Tbl1012"."run_duration" "Col1048" 
--FROM "msdb"."dbo"."sysjobhistory" h
--inner join [msdb].[dbo].[sysjobs] j on h.job_id=j.job_id
--WHERE h.step_id=(0) 
--and h.run_date>= '20180515'
--and h.[run_status] =1
--group by run_date