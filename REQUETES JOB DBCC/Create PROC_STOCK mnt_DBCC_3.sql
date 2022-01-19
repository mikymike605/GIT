USE [msdb]
GO
 
IF object_id('dbo.mnt_DBCC') IS NULL BEGIN
    EXEC('CREATE PROCEDURE dbo.mnt_DBCC AS RETURN 0')
END
GO
 
ALTER PROCEDURE dbo.mnt_DBCC
   @system_only bit = 0,   -- 0 for all, 1 for master & msdb only
   @physical_only bit = 0, -- 0 for all, 1 for physical only
   @VLDB bit = 0,                 -- option to break out DBCC CHECKTABLE over time; 0 for no, 1 for yes
   @days tinyint = 7              -- If @VLDB = 1, then @days is the number of days to spread load
AS
 
SET NOCOUNT ON
SET QUOTED_IDENTIFIER ON
 
/***************************************************************************
Stored Procedure: mnt_DBCC                            
                                        
Written by: David Paul Giroux                                             
Date: 9/26/2008                                                                                              
Purpose: Creates Maintenance_DBCC_CHECKDB SQL Server Agent Job                                        
Input Parameters: @system_only bit, @physical_only bit, @VLDB bit, @days tinyint
Output Parameters: None   
Usage Example: EXEC dbo.mnt_DBCC 0, 0, 1, 1           
Called By: SQL Server Agent Job: Server Daily Maintenance
Calls: msdb.dbo.mnt_DBCC_VLDB,
   sp_add_category, sp_add_job, sp_add_jobstep,
   sp_update_jobstep, sp_delete_jobstep
 
If @VLDB = 1, @physical_only is ignored
@days is only used with @VLDB and is otherwise ignored
@days determines the number of days to spread the load for DBCC CHECKTABLE
Uses: WITH ALL_ERRORMSGS, NO_INFOMSGS;
                                                      
***************************************************************************/
 
DECLARE       @version smallint                        -- SQL Server Version
 
IF CONVERT(sysname, SERVERPROPERTY(N'ProductVersion')) LIKE N'10%'
BEGIN
   SET @version  = 2008
END
ELSE IF CONVERT(sysname, SERVERPROPERTY(N'ProductVersion')) LIKE N'9%'
BEGIN
   SET @version = 2005
END
ELSE BEGIN
   SELECT N'This version is only for SQL Server 2005 or 2008'
   RETURN
END
 
IF @system_only NOT IN (0, 1)
BEGIN
   EXEC xp_logevent 77775, N'Illegal value for @system_only.  Choices are 0 or 1', ERROR
   RETURN
END
 
IF @physical_only NOT IN (0, 1)
BEGIN
   EXEC xp_logevent 77775, N'Illegal value for @physical_only.  Choices are 0 or 1', ERROR
   RETURN
END
 
BEGIN TRANSACTION
DECLARE       @ReturnCode int
SET    @ReturnCode = 0
 
 -- Add Job Category if not exist
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WITH (NOLOCK) WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
   EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END
 
-- Create empty job if not exist
IF NOT EXISTS (SELECT [name] FROM msdb.dbo.sysjobs WITH (NOLOCK) WHERE [name] = N'Maintenance_DBCC_CHECKDB')
BEGIN
   DECLARE @jobId BINARY(16)
   EXEC @ReturnCode =  msdb.dbo.sp_add_job
              @job_name=N'Maintenance_DBCC_CHECKDB',
              @enabled=1,
              @notify_level_eventlog=0,
              @notify_level_email=0,
              @notify_level_netsend=0,
              @notify_level_page=0,
              @delete_level=0,
              @description=N'Dynamic Database DBCC Job - updated daily.',
              @category_name=N'Database Maintenance',
              @owner_login_name=N'sa', @job_id = @jobId OUTPUT
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
   EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END
 
DECLARE       @script       nvarchar(MAX)              -- DBCC CHECKDB command
DECLARE @error nvarchar(1000)                   -- Static error command
DECLARE       @StepName sysname                        -- Step Name
DECLARE       @StepNameE sysname                       -- Step Name for Error Checking
DECLARE       @counter tinyint                         -- a counter equal to number of databases to check
DECLARE       @DBName sysname                                 -- database to be checked
DECLARE       @stepID tinyint                                 -- StepID
DECLARE       @DBNameID tinyint                        -- Identity value of db to check
DECLARE       @crlf nchar(2)                                  -- Carriage return line feed
 
SET    @stepID = 1
SET    @DBNameID = 1
SET    @crlf = NCHAR(13) + NCHAR(10)            -- Carriage return line feed
 
-- Table to hold database names to be checked
DECLARE       @Databases TABLE (
   DBNameID tinyint IDENTITY(1,1) primary key,
   DBName sysname
   )
 
-- Get all online user database names
-- Few exclusions
IF @system_only = 0
BEGIN
   INSERT    @Databases (DBName)
   SELECT    [name] FROM   master.sys.databases WITH (NOLOCK)
   WHERE     [state] = 0
   AND       is_in_standby = 0
   AND       [name] <> N'TempDB'
 
END
ELSE BEGIN
   INSERT    @Databases (DBName)
   SELECT    N'master' UNION ALL
   SELECT    N'msdb'
END
 
SET    @counter = SCOPE_IDENTITY()
 
-- Delete all current steps
EXEC msdb.dbo.sp_delete_jobstep
   @job_name = N'Maintenance_DBCC_CHECKDB',
   @step_id = 0
 
-- Add new steps
WHILE  @DBNameID <= @counter
BEGIN
   -- Grab first record
   SELECT    @DBName = DBName,
              @StepName = N'DBCC CHECKDB ' + DBName,
              @StepNameE = N'Error Checker ' + DBName
   FROM      @Databases
   WHERE     DBNameID = @DBNameID
 
SELECT @error =
N'IF DB_ID(''' + @DBName + N''') IS NULL
BEGIN
   RETURN
END
 
DECLARE @runstatus int
 
SELECT TOP 1 @runstatus =  run_status
FROM   msdb.dbo.sysjobhistory
WHERE  job_id = CONVERT(uniqueidentifier, $' + N'(ESCAPE_NONE(JOBID)))
AND step_id = CONVERT(int, $' + N'(ESCAPE_NONE(STEPID))) -1  
ORDER BY instance_id DESC
 
IF @runstatus = 0
BEGIN
   DECLARE @msg nvarchar(250)
   DECLARE @crlf nchar(2)
   SET @crlf = NCHAR(13) + NCHAR(10)
 
   SELECT    @msg = @crlf +
       ''Please create a Bug; notify ________ via e-mail only.'' + @crlf +
       ''Job: '' + sj.name + '' had an issue at Step: '' + 
        CAST(step_id as varchar(2)) + ''.'' + @crlf +
       ''Step Name: '' + ss.step_name
   FROM      msdb.dbo.sysjobs sj WITH (NOLOCK)
   JOIN      msdb.dbo.sysjobsteps ss WITH (NOLOCK)
   ON sj.job_id = ss.job_id
   WHERE     sj.job_id = CONVERT(uniqueidentifier, $' + N'(ESCAPE_NONE(JOBID))) 
   AND ss.step_id = CONVERT(int, $' + N'(ESCAPE_NONE(STEPID))) -1
 
   EXEC xp_logevent 77776, @msg, ERROR
END'
 
   IF @VLDB = 1
   BEGIN
       EXEC msdb.dbo.mnt_DBCC_VLDB
              @days = @days,
             @db = @DBName,
              @version = @version,
              @results = @script OUTPUT
 
       SELECT @script = N'IF DB_ID(''' + @DBName + N''') IS NULL' + @crlf +
                                  N'BEGIN' + @crlf +
                                  N'     RETURN' + @crlf +
                                  N'END' + @crlf + @crlf +
                                  N'SET NOCOUNT ON' + @crlf + @crlf +
                                  @script
   END
   ELSE BEGIN
       -- Build command
       IF     @physical_only = 1
       BEGIN
              SELECT @script = N'IF DB_ID(''' + @DBName + N''') IS NULL' + @crlf +
                                         N'BEGIN' + @crlf +
                                         N'     RETURN' + @crlf +
                                         N'END' + @crlf + @crlf +
                                         N'SET NOCOUNT ON' + @crlf + @crlf +
                                         N'DBCC CHECKDB ([' + @DBName + N']) WITH PHYSICAL_ONLY, ALL_ERRORMSGS, NO_INFOMSGS;'
       END
       ELSE BEGIN
              SELECT @script = N'IF DB_ID(''' + @DBName + N''') IS NULL' + @crlf +
                                         N'BEGIN' + @crlf +
                                          N'     RETURN' + @crlf +
                                         N'END' + @crlf + @crlf +
                                         N'SET NOCOUNT ON' + @crlf + @crlf +
                                         N'DBCC CHECKDB ([' + @DBName + N']) WITH ALL_ERRORMSGS, NO_INFOMSGS;'
       END
   END
  
   -- Add worker step
   EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
              @job_name = N'Maintenance_DBCC_CHECKDB',
              @step_id = @stepID,               /*******/
              @step_name = @StepName,           /*******/
              @subsystem = N'TSQL',
              @command = @script,               /*******/
              @cmdexec_success_code = 0,
              @on_success_action = 3,
              @on_success_step_id = 0,
              @on_fail_action = 3,
              @on_fail_step_id = 0,
              @database_name = @DBName,
              @retry_attempts = 0,
              @retry_interval = 0,
              @os_run_priority = 0,
              @flags = 0
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
 
   SET @stepID = @stepID + 1
 
   -- Checks whether prior step succeeded.
   EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
       @job_name = N'Maintenance_DBCC_CHECKDB',
       @step_id= @stepID,
       @step_name= @StepNameE,
       @cmdexec_success_code=0,
       @on_success_action=3,
       @on_success_step_id=0,
       @on_fail_action=3,
       @on_fail_step_id=0,
       @retry_attempts=0,
       @retry_interval=0,
       @os_run_priority=0,
       @subsystem=N'TSQL',
       @command= @error,
       @database_name=N'msdb',
       @flags=0
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
 
   SET @stepID = @stepID + 1
   SET @DBNameID = @DBNameID + 1
END
 
-- Update last job step to quit
SET @stepID = @stepID - 1
 
EXEC @ReturnCode = msdb.dbo.sp_update_jobstep
       @job_name = N'Maintenance_DBCC_CHECKDB',
       @step_id = @stepID,               /*******/
       @on_success_action = 1,           -- Quit With Success
       @on_fail_action = 2               -- Quit With Failure
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
 
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
   IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO