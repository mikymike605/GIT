USE [msdb]
GO

/****** Object:  Job [@-ADM - BACKUP T_LOG ---> NULL]    Script Date: 03/05/2019 15:57:20 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 03/05/2019 15:57:20 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ADM - BACKUP & SHRINK T_LOG ---> NULL', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Backup TLOG pour libere l''espace', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [BACKUP T_LOG]    Script Date: 03/05/2019 15:57:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'BACKUP T_LOG', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @CMD varchar(max)
SET @CMD  = ''--- backup to NULL '' + CHAR(13)
select @CMD=@CMD+''BACKUP LOG [''+name+''] TO  DISK = N''''NULL'''' WITH NOFORMAT, INIT,  NAME = N''''Sauvegarde destinée à libérer les TLOG'''', SKIP, NOREWIND, NOUNLOAD,  STATS = 10;''+CHAR(13) 
from sys.databases where state_desc = ''ONLINE'' and recovery_model_desc <> ''SIMPLE''
print(@CMD)
exec(@CMD)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SHRINK_LOG]    Script Date: 03/05/2019 15:57:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SHRINK_LOG', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @CMD2 varchar(max)
SET @CMD2  = ''--- Shrink log '' + CHAR(13)
select @CMD2=@CMD2+''USE ''+d.name+'' DBCC SHRINKFILE (''+m.name+'',0,TRUNCATEONLY);''+CHAR(13) 
--SELECT d.name,m.name 
from sys.master_files m inner join sys.databases d on m.database_id=d.database_id where type_desc=''log'' and m.database_id >4
print(@CMD2)
exec(@CMD2)
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'BACKUP T_LOG  TOUTE LES HEURES', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160713, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'174f36cb-2ae7-46f1-9bd3-1c6a792ae7f7'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


