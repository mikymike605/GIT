USE [msdb]
GO

/****** Object:  Job [ADM - BLOCKING TREE REPORT]    Script Date: 10/01/2019 10:25:33 ******/
EXEC msdb.dbo.sp_delete_job @job_name=N'ADM - BLOCKING TREE REPORT', @delete_unused_schedule=1
GO

/****** Object:  Job [ADM - BLOCKING TREE REPORT]    Script Date: 10/01/2019 10:25:33 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10/01/2019 10:25:33 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ADM - BLOCKING TREE REPORT', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Rapport des locks enregistrés sur l''instance', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'QUICK\hamcham', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [BLOCKING TREE REPORT]    Script Date: 10/01/2019 10:25:33 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'BLOCKING TREE REPORT', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*
Discialmer:
The sample scripts are provided AS IS without warranty of any kind. The entire risk arising out of the use or performance of the sample scripts and 
documentation remains with you. In no event I shall be liable for any damages whatsoever (including, without limitation, damages for loss of business 
profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts.
*/


SET nocount ON; 
SET concat_null_yields_null OFF 

go 

WITH blockers (spid, blocked, level, batch, lastwaittype,waittime,hostname,cmd,dbid,loginname,open_tran,login_time) 
     AS (SELECT spid, 
                blocked, 
                Cast (Replicate (''0'', 4-Len (Cast (spid AS VARCHAR))) 
                      + Cast (spid AS VARCHAR) AS VARCHAR (1000))         AS 
                LEVEL, 
                Replace (Replace (T.text, Char(10), '' ''), Char (13), '' '') AS 
                BATCH, 
                R.lastwaittype,r.waittime /1000 /60 as waittime_minutes,
                R.hostname,r.cmd,r.dbid,r.loginame,r.open_tran,r.login_time
         FROM   sys.sysprocesses R WITH (nolock) 
                CROSS apply sys.Dm_exec_sql_text(R.sql_handle) T 
         WHERE  ( blocked = 0 
                   OR blocked = spid ) 
                AND EXISTS (SELECT spid, 
                                   blocked, 
                                   Cast (Replicate (''0'', 4-Len (Cast (spid AS 
                                         VARCHAR 
                                         ))) 
                                         + Cast (spid AS VARCHAR) AS VARCHAR ( 
                                         1000)) 
                                   AS 
                                       LEVEL, 
                                   blocked, 
                                   Replace (Replace (T.text, Char(10), '' ''), 
                                   Char (13 
                                   ), 
                                   '' '') AS 
                                       BATCH, 
                                   R.lastwaittype, r.waittime /1000 /60 as waittime_minutes,
                                    R.hostname,r.cmd,r.dbid,r.loginame,r.open_tran,r.login_time
                            FROM   sys.sysprocesses R2 WITH (nolock) 
                                   CROSS apply 
                                   sys.Dm_exec_sql_text(R.sql_handle) T 
                            WHERE  R2.blocked = R.spid 
                                   AND R2.blocked <> R2.spid) 
         UNION ALL 
         SELECT R.spid, 
                R.blocked, 
                Cast (blockers.level 
                      + RIGHT (Cast ((1000 + R.spid) AS VARCHAR (100)), 4) AS 
                      VARCHAR 
                      ( 
                      1000)) AS 
                LEVEL, 
                Replace (Replace (T.text, Char(10), '' ''), Char (13), '' '') 
                AS BATCH, 
                R.lastwaittype,r.waittime /1000 /60 as waittime_minutes,
                R.hostname ,r.cmd,r.dbid,r.loginame,r.open_tran,r.login_time
         FROM   sys.sysprocesses AS R WITH (nolock) 
                CROSS apply sys.Dm_exec_sql_text(R.sql_handle) T 
                INNER JOIN blockers 
                        ON R.blocked = blockers.spid 
         WHERE  R.blocked > 0 
                AND R.blocked <> R.spid
				and r.waittime >=300000)  
SELECT N'''' +@@SERVERNAME as Instance ,
       + Replicate (N''|.......'', Len (level)/4 - 2) 
       + CASE WHEN (Len (level)/4 - 1) = 0 THEN ''HEAD - '' ELSE ''|------ '' END + 
       Cast ( 
       spid AS VARCHAR (10)) + '' '' + batch AS BLOCKING_TREE, 
       hostname, 
       lastwaittype,waittime, cmd,dbid,loginname,open_tran,login_time,
       Getdate()                           AS ''RunTime'' ,
       level
INTO #BLOCKERS
FROM   blockers WITH (nolock) 
ORDER  BY level ASC 

    --Select BLOCKING_TREE,hostname,lastwaittype,time,cmd,dbid,loginname,open_tran from   #BLOCKERS
    --order by level asc

    DECLARE @tableHTML NVARCHAR(MAX);
	--N''''H1>+@@SERVERNAME+</H1''''+
    SET @tableHTML =  N''<H1>Blocking Tree Report</H1>'' + N''<table border="1">'' + N''<tr>'' + 
   N''<th>Instance</th>'' + N''<th>Blocking_Tree</th>'' + N''<th>hostname</th>'' + N''<th>lastwaittype</th>''+ N''<th>waittime</th>''+''<th>CurrentTime</th>'' 
    + N''<th>cmd</th>'' 
    + N''<th>dbid</th>'' 
    + N''<th>loginname</th>'' 
    + N''<th>open_tran</th>'' 
    + N''<th>login_time</th>'' 
    + ''</tr>'' + CAST((
SELECT td = Instance,'''',
td = Blocking_Tree,'''',
         td =hostname,'''',
         td =lastwaittype,'''',
		 td =waittime,'''',
         td =RunTime,'''',
         td= cmd,'''',
         td= dbid,'''',
         td= loginname,'''',
         td=open_tran,'''',
         td=login_time,''''
         FROM #BLOCKERS
             order by level asc
FOR XML PATH(''tr'')
                    ,TYPE
                ) AS NVARCHAR(MAX)) + N''</table>'';   

If (select count(*) from #BLOCKERS) > 1
begin

    EXEC msdb.dbo.sp_send_dbmail @body = @tableHTML
        ,@body_format = ''HTML''
        , @recipients=''mikael.hamchaoui@bkqservices.com''
	    ,@profile_name = ''EnvoiMail''
        ,@Subject = N''Blocking Tree Report''        
end

drop table #BLOCKERS', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'EVERY 15 min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190109, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'dd29cab8-7df5-4db6-8099-cf42ae34b33a'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


