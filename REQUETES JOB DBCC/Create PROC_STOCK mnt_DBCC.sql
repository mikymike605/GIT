Web Listing 1: ServerDailyMaintenance.txt
USE [msdb]
GO
 
IF EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = 'Server Daily Maintenance')
BEGIN
   EXEC msdb.dbo.sp_delete_job
       @job_name = 'Server Daily Maintenance'
END
GO
 
/****** Object:  Job [Server Daily Maintenance]    Script Date: 06/27/2009 17:56:35 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 06/27/2009 17:56:35 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
 
END
 
DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Server Daily Maintenance',
       @enabled=1,
       @notify_level_eventlog=2,
       @notify_level_email=0,
       @notify_level_netsend=0,
       @notify_level_page=0,
       @delete_level=0,
       @description=N'',
       @category_name=N'Database Maintenance',
       @owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start DBCC CHECKDB]    Script Date: 06/27/2009 17:56:35 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start DBCC CHECKDB',
       @step_id=1,
       @cmdexec_success_code=0,
       @on_success_action=1,
       @on_success_step_id=0,
       @on_fail_action=2,
       @on_fail_step_id=0,
       @retry_attempts=0,
       @retry_interval=0,
       @os_run_priority=0, @subsystem=N'TSQL',
       @command=N'SET NOCOUNT ON
 
EXEC msdb.dbo.mnt_DBCC
   @system_only  = 0,
   @physical_only  = 0,
   @VLDB = 1,
   @days = 7
GO
 
WAITFOR DELAY ''00:00:10''
GO
 
EXEC msdb.dbo.sp_start_job
   @job_name = N''Maintenance_DBCC_CHECKDB''',
       @database_name=N'msdb',
       @flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'SDM_DailySchedule',
       @enabled=1,
       @freq_type=4,
       @freq_interval=1,
       @freq_subday_type=1,
       @freq_subday_interval=0,
       @freq_relative_interval=0,
       @freq_recurrence_factor=0,
       @active_start_date=20080927,
       @active_end_date=99991231,
       @active_start_time=93205,
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
 
Web Listing 2: mnt_DBCC.txt
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
Web Listing 3: mnt_DBCC_VLDB.txt
USE [msdb]
GO
 
IF object_id('dbo.mnt_DBCC_VLDB') IS NULL BEGIN
    EXEC('CREATE PROCEDURE dbo.mnt_DBCC_VLDB AS RETURN 0')
END
GO
 
ALTER PROCEDURE dbo.mnt_DBCC_VLDB
   @days tinyint = 7,
   @db sysname,
   @version smallint = 2008,
   @results nvarchar(MAX) OUTPUT
AS
 
SET NOCOUNT ON
SET QUOTED_IDENTIFIER ON
 
/***************************************************************************
Stored Procedure: mnt_DBCC_VLDB                              
                                        
Written by: David Paul Giroux                                             
Date: 04/2009                                                                                            
Purpose: Produces DBCC CHECKTABLE script              
Input Parameters: @days tinyint, @db sysname
Output Parameters: @results nvarchar(MAX)             
Called By: msdb.dbo.mnt_DBCC
This scproc can be called directly but is designed to be called by msdb.dbo.mnt_DBCC.
 
   Example Usage if called directly:
       DECLARE       @results nvarchar(MAX)
       EXEC msdb.dbo.mnt_DBCC_VLDB
              @days = 7,
              @db = N'AdventureWorks',
              @version = 2008,
              @results = @results OUTPUT
 
       SELECT @Results     
  
Calls: None
Data Modifications: Updates SQL Server Agent Job: Maintenance_DBCC_CHECKDB
Uses: WITH ALL_ERRORMSGS, NO_INFOMSGS;
 
The sproc calculates the size of each table and then spreads the weight into
a number of groups based on @days.  This allows for an even daily load (close as possible)
A different group is returned each day.
 
This script knows on any given day which set of tables to execute because of the following statement:
WHERE  VLDB_Group = DATEDIFF(dd, N'01-01-2009', GETDATE()) % @days
                                                      
***************************************************************************/
 
DECLARE       @cmd nvarchar(700)
DECLARE @crlf nchar(2)
 
SET    @crlf = NCHAR(13) + NCHAR(10)
 
-- All tables
DECLARE @Pool TABLE (
   [Name] sysname,
   ObjectID int primary key,
   ReservedPC bigint
   )
 
-- Info for tables with XML or Fulltext Indexes
DECLARE @Others TABLE (
   ObjectID int primary key,
   ReservedPC bigint
   )
 
-- Tables with final ReservedPC amount and grouped by @days
DECLARE @Final TABLE (
   VLDB_Group tinyint,
   [name] sysname primary key,
   ReservedPC bigint
   )
  
IF @version = 2008
BEGIN
   -- User Tables, System Base Table, Indexed Views, Internal Tables
   SELECT  @cmd =
   N'USE [' + @db + N']' + @crlf +
   N'SELECT SCHEMA_NAME(o.schema_id) + N''.'' + o.name, ' + @crlf +
   N'        o.object_id, SUM(ps.reserved_page_count)' + @crlf +
   N'FROM    [' + @db + N'].sys.objects o WITH (NOLOCK)' + @crlf +
   N'JOIN    [' + @db + N'].sys.dm_db_partition_stats ps WITH (NOLOCK)' + @crlf +
   N'ON             o.object_id = ps.object_id' + @crlf +
   N'WHERE   o.[type] IN (N''U'', N''S'', N''V'', N''IT'')' + @crlf +
   N'GROUP BY  SCHEMA_NAME(o.schema_id) + N''.'' + o.name, o.object_id'
END
ELSE BEGIN
   -- User Tables, Indexed Views, Internal Tables
   SELECT  @cmd =
   N'USE [' + @db + N']' + @crlf +
   N'SELECT SCHEMA_NAME(o.schema_id) + N''.'' + o.name, ' + @crlf +
   N'        o.object_id, SUM(ps.reserved_page_count)' + @crlf +
   N'FROM    [' + @db + N'].sys.objects o WITH (NOLOCK)' + @crlf +
   N'JOIN    [' + @db + N'].sys.dm_db_partition_stats ps WITH (NOLOCK)' + @crlf +
   N'ON             o.object_id = ps.object_id' + @crlf +
   N'WHERE   o.[type] IN (N''U'', N''V'', N''IT'')' + @crlf +
   N'GROUP BY  SCHEMA_NAME(o.schema_id) + N''.'' + o.name, o.object_id'
END
 
 
INSERT INTO @Pool
EXEC (@cmd)
 
-- Check if table has XML Indexes or Fulltext Indexes which use internal tables tied to this table
-- Row counts in these internal tables don't contribute towards row count of original table. 
SELECT  @cmd =
N'USE [' + @db + N']' + @crlf +
N'SELECT      it.object_id, sum(ps.reserved_page_count)' + @crlf +
N'FROM [' + @db + N'].sys.dm_db_partition_stats ps WITH (NOLOCK)' + @crlf +
N'JOIN [' + @db + N'].sys.internal_tables it WITH (NOLOCK)' + @crlf +
N'ON          ps.object_id = it.object_id' + @crlf +
N'WHERE       it.internal_type IN (202,204)' + @crlf +
N'GROUP BY it.object_id'
 
INSERT INTO @Others
EXEC (@cmd)
 
UPDATE @Pool
SET    ReservedPC = a.ReservedPC + b.ReservedPC
FROM   @Pool a
JOIN   @Others b
ON     a.ObjectID = b.ObjectID
 
 
-- This additional table is needed because cannot filter on ROW_NUMBER function
INSERT @Final
SELECT ROW_NUMBER() OVER(ORDER BY ReservedPC DESC) % @days,
       [name],
       ReservedPC * 8
FROM   @Pool
 
 
-- Final results filtered by VLDB_Group
-- The VLDB_Group changes daily
SET    @results = N''
SELECT @results = @results + N'DBCC CHECKTABLE ([' + @db + N'.' + [name] + N']) WITH ALL_ERRORMSGS, NO_INFOMSGS;' + @crlf
FROM   @Final
WHERE  VLDB_Group = DATEDIFF(dd, N'01-01-2009', GETDATE()) % @days -- 01-01-2009 is arbitrary
 
SET    @results =
N'DBCC CHECKALLOC ([' + @db + N']) WITH ALL_ERRORMSGS, NO_INFOMSGS;' + @crlf +
N'DBCC CHECKCATALOG ([' + @db + N']) WITH NO_INFOMSGS;' + @crlf + @crlf +
@results
GO
PRINT
REPRINTS