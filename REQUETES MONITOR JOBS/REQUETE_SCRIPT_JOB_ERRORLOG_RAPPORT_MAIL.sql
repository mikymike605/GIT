USE [msdb]
GO

/****** Object:  Job [ADM - PUSH MAIL ERRORLOG]    Script Date: 10/04/2018 15:16:07 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10/04/2018 15:16:07 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ADM - PUSH MAIL ERRORLOG', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'ENVOIE RAPPORT ERRORLOG MAIL', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'QUICK\hamcham', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ENVOIE MAIL ERROR LOG]    Script Date: 10/04/2018 15:16:07 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ENVOIE MAIL ERROR LOG', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @Time_Start datetime;
declare @Time_End datetime;
set @Time_Start=getdate()-2;
set @Time_End=getdate();
 
 IF OBJECT_ID(''#ErrorLog'') is not null drop table #ErrorLog
create table #ErrorLog (logdate datetime
, processinfo varchar(255)
, Message varchar(max) )
 
insert #ErrorLog (logdate, processinfo, Message)
EXEC master.dbo.xp_readerrorlog 0, 1, null, null , @Time_Start, @Time_End, N''desc'';

 IF OBJECT_ID(''#ErrorLog'') is not null drop table #SQL_Log_Errors
create table #SQL_Log_Errors (
[logdate] datetime,
[Message] varchar (500) )
 
insert into #SQL_Log_Errors
select logdate, Message FROM #ErrorLog
where (Message like ''%err%''
or Message like ''%warn%''
or Message like ''%kill%''
or Message like ''%dead%''
or Message like ''%cannot%''
or Message like ''%could%''
or Message like ''%fail%''
or Message like ''%not%''
or Message like ''%stop%''
or Message like ''%terminate%''
or Message like ''%bypass%''
or Message like ''%roll%''
or Message like ''%truncate%''
or Message like ''%upgrade%''
or Message like ''%victim%''
or Message like ''%recover%''
or Message like ''%critical%''
or Message like ''%IO requests taking longer than%'')
AND Message not like ''%errorlog%''
AND Message not like ''%dbcc%''
AND Message not like ''%checkdb%''
order by logdate desc
 
drop table #ErrorLog
 
declare @cnt int
select @cnt=COUNT(1) from #SQL_Log_Errors
if (@cnt > 0)
begin
 
declare @strsubject varchar(100)
declare @oper_email nvarchar(100)
 
set @oper_email = (select email_address from msdb.dbo.sysoperators where name = ''DBA'')
select @strsubject=''There are errors in the SQL Error Log on '' + @@SERVERNAME
 
declare @tableHTML nvarchar(max);
set @tableHTML =
N''<H1>SQL Error Log Errors - '' + @@SERVERNAME + ''</H1>'' +
N''
<table border="1">'' +
N''
<tr>
<th>Log Date</th>
'' +
N''
<th>Message</th>
</tr>
'' +
CAST ( ( SELECT td = [logdate], '''',
td = [Message]
FROM #SQL_Log_Errors
FOR XML PATH(''tr''), TYPE
) AS NVARCHAR(MAX) ) +
N''</table>
'' ;
 
EXEC msdb.dbo.sp_send_dbmail
--@from_address=''fichiers@quick.fr'',
@recipients= ''mikael.hamchaoui@bkqservices.com'',
@subject = @strsubject,
@body = @tableHTML,
@body_format = ''HTML'',
@profile_name=''EnvoiMail''
 
end
 

drop table #SQL_Log_Errors
 
go', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'EVERY DAY 6H00', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180410, 
		@active_end_date=99991231, 
		@active_start_time=60000, 
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

