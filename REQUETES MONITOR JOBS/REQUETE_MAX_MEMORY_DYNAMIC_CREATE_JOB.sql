/*
-------http://alexandrerousseau.fr/index.php/2017/06/01/gerer-dynamiquement-la-memoire-au-demarrage-de-sql-server/
Il faut maintenant définir une règle pour calculer la bonne valeur à mettre en place pour le min et max mémoire. Suivant l’article cité plus haut, nous pouvons calculer suivant un pourcentage ou une valeur fixe.
Pourcentage
*/

select
 (total_physical_memory_kb/1024) - ((total_physical_memory_kb/1024)*0.1)
as max_memory_mb from sys.dm_os_sys_memory

/*Il faut maintenant définir une règle pour calculer la bonne valeur à mettre en place pour le min et max mémoire. Suivant l’article cité plus haut, nous pouvons calculer suivant un pourcentage ou une valeur fixe.
Valeur Fixe
*/
select
CASE
WHEN (total_physical_memory_kb/1024) <= 4096 THEN (total_physical_memory_kb/1024) - 1024
WHEN (total_physical_memory_kb/1024) <= 8192 THEN (total_physical_memory_kb/1024) - 2048
ELSE (total_physical_memory_kb/1024) - 4096
END
as max_memory_mb from sys.dm_os_sys_memory

/*Et la procédure complète pour modifier les paramètres du min et max dynamiquement :
Pourcentage
*/
EXEC sys.sp_configure N'show advanced options', N'1' RECONFIGURE WITH OVERRIDE
GO
Declare @MaxMemory INT
set @MaxMemory = (select
 (total_physical_memory_kb/1024) - ((total_physical_memory_kb/1024)*0.1)
as max_memory_mb from sys.dm_os_sys_memory)
EXEC sys.sp_configure N'min server memory (MB)', @MaxMemory
EXEC sys.sp_configure N'max server memory (MB)', @MaxMemory
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'show advanced options', N'0' RECONFIGURE WITH OVERRIDE
GO

/*Et la procédure complète pour modifier les paramètres du min et max dynamiquement :
Valeur Fixe
*/
EXEC sys.sp_configure N'show advanced options', N'1' RECONFIGURE WITH OVERRIDE
GO
Declare @MaxMemory INT
set @MaxMemory = (select
CASE
WHEN (total_physical_memory_kb/1024) <= 4096 THEN (total_physical_memory_kb/1024) - 1024
WHEN (total_physical_memory_kb/1024) <= 8192 THEN (total_physical_memory_kb/1024) - 2048
ELSE (total_physical_memory_kb/1024) - 4096
END
as max_memory_mb from sys.dm_os_sys_memory)
EXEC sys.sp_configure N'min server memory (MB)', @MaxMemory
EXEC sys.sp_configure N'max server memory (MB)', @MaxMemory
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'show advanced options', N'0' RECONFIGURE WITH OVERRIDE
GO

/*Et la procédure complète pour modifier les paramètres du min et max dynamiquement :
Création du JOB en T-SQL: 
*/
USE [msdb]
GO

/****** Object:  Job [Admin - Set up Max Memory]  *******/

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Admin - Set up Max Memory', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Set up the max memory following best practices and server memory.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Configure Max Memory]    Script Date: 29/05/2017 12:37:10 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Configure Max Memory', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sys.sp_configure N''show advanced options'', N''1''  RECONFIGURE WITH OVERRIDE
GO
Declare @MaxMemory INT 
set @MaxMemory = (select
					CASE   
						WHEN (total_physical_memory_kb/1024) <= 4096 THEN (total_physical_memory_kb/1024) - 1024
						WHEN (total_physical_memory_kb/1024) <= 8192 THEN (total_physical_memory_kb/1024) - 2048
						ELSE (total_physical_memory_kb/1024) - 4096   
					END  
					as max_memory from sys.dm_os_sys_memory)
EXEC sys.sp_configure N''min server memory (MB)'', @MaxMemory
EXEC sys.sp_configure N''max server memory (MB)'', @MaxMemory
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N''show advanced options'', N''0''  RECONFIGURE WITH OVERRIDE
GO

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'At startup of SQL Agent', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170509, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'6b873d31-3cfd-4691-94c2-808f777178a5'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO
