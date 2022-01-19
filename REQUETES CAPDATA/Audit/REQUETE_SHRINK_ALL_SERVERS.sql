USE [AdminSQL]
GO

/****** Object:  StoredProcedure [dbo].[usp_ShrinkSpaceFile]    Script Date: 10/04/2017 13:57:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Christophe Issenlor
-- Create date: Septembre 2016
-- Description:	NIVEAU D'UTILISATION DU CPU COTE SQL SERVER
------  EXEC [dbo].[usp_ShrinkSpaceFile] 

/*
LANCEMENT DU JOB SUR TOUTES LES INSTANCES POUR ALIMENTER LA TABLE [AdminMonitor].[dbo].[SHRINK_TABLE_V2]
DU SERVEUR AUBFRTESTSQL02-------------
USE msdb ;  
GO  
  
EXEC dbo.sp_start_job N'MONITOR SHRINK FREE SPACE' ;  
GO  

--TRUNCATE TABLE [AdminMonitor].[dbo].[SHRINK_TABLE_V2]
 SELECT * FROM [AdminMonitor].[dbo].[SHRINK_TABLE_V2]
  where filetype = 'LOG'
  order by SPACEFREE desc
 
--USE msdb ;  
--GO  
--EXEC dbo.sp_start_job N'MONITOR SHRINK FREE SPACE' ;  
--GO  

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT 'BACKUP LOG ['+DATABASENAME+'] TO DISK = ''nul:''WITH STATS = 10 USE ['+DATABASENAME+'] DBCC SHRINKFILE (N'''+FILNAME+''',0,TRUNCATEONLY)',*
  FROM [AdminMonitor].[dbo].[SHRINK_TABLE_V2]
where TIMESTAMP >= '20170411'
and DATABASENAME='ODS'
order by 8 desc

 */


-- =============================================
CREATE PROCEDURE [dbo].[usp_ShrinkSpaceFile]


AS
BEGIN

/*CREATION DU SERVEUR LIE AUBRFRTESTSQL02*/

/****** Object:  LinkedServer [AUBFRTESTSQL02]    Script Date: 10/04/2017 10:53:58 ******/
EXEC master.dbo.sp_dropserver @server=N'AUBFRTESTSQL02', @droplogins='droplogins'

/****** Object:  LinkedServer [AUBFRTESTSQL02]    Script Date: 10/04/2017 10:53:58 ******/
EXEC master.dbo.sp_addlinkedserver @server = N'AUBFRTESTSQL02', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'AUBFRTESTSQL02',@useself=N'False',@locallogin=NULL,@rmtuser=N'sa_sa',@rmtpassword='Capdata!123'

EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'collation compatible', @optvalue=N'false'

EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'data access', @optvalue=N'true'
 
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'dist', @optvalue=N'false'
 
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'pub', @optvalue=N'false'
 
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'rpc', @optvalue=N'false'
 
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'rpc out', @optvalue=N'false'
 
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'sub', @optvalue=N'false'
 
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'connect timeout', @optvalue=N'0'
 
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'collation name', @optvalue=null
 
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'lazy schema validation', @optvalue=N'false'
 
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'query timeout', @optvalue=N'0'
 
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'use remote collation', @optvalue=N'true'
 
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'remote proc transaction promotion', @optvalue=N'true'
 
/*DELETE TABLE_TEST */
--DROP TABLE [AdminMonitor].[dbo].[SHRINK_TABLE_V3]
DROP TABLE [AdminSQL].[dbo].[TBShrinkDB]
--SELECT * FROM  AUBFRTESTSQL02.[AdminMonitor].[dbo].[SHRINK_TABLE_V2]
 
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'rpc', @optvalue=N'true'
 
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'rpc out', @optvalue=N'true'
 

EXEC [AUBFRTESTSQL02].[AdminMonitor].sys.sp_executesql N'TRUNCATE TABLE dbo.[SHRINK_TABLE_V2]'
--TRUNCATE TABLE [AdminSQL].[dbo].[TBShrinkDB]
/*CREATE TABLE ALIMENTATION*/
/****** Object:  Table [dbo].[TBShrinkDB]    Script Date: 10/04/2017 11:06:50 ******/
SET ANSI_NULLS ON
 
SET QUOTED_IDENTIFIER ON
 
SET ANSI_PADDING OFF
 
CREATE TABLE [AdminSQL].[dbo].[TBShrinkDB](
	[ServerName] [varchar](500) NULL,
	[DRIVE] [char](1) NULL,
	[DISKSPACEFREE] [varchar](50) NULL,
	[DATABASENAME] [varchar](50) NULL,
	[FILNAME] [varchar](50) NULL,
	[FILETYPE] [varchar](50) NULL,
	[FILESIZE] [varchar](50) NULL,
	[SPACEFREE] [varchar](50) NULL,
	[PHYSICAL_NAME] [varchar](500) NULL,
	[TIMESTAMP] [datetime] NULL
) ON [PRIMARY]
 
SET ANSI_PADDING OFF
 
/*ALIMENTAION TABLE TBShrinkDB */


CREATE TABLE #TMPFIXEDDRIVES ( 
  DRIVE  CHAR(1), 
  MBFREE INT) 

INSERT INTO #TMPFIXEDDRIVES 
EXEC xp_fixeddrives  

CREATE TABLE #TMPSPACEUSED ( 
  DBNAME    VARCHAR(50), 
  FILENME   VARCHAR(50), 
  SPACEUSED FLOAT) 

INSERT INTO #TMPSPACEUSED 
EXEC( 'sp_MSforeachdb''use [?]; Select ''''?'''' DBName, Name FileNme, 
fileproperty(Name,''''SpaceUsed'''') SpaceUsed from sysfiles''') 


INSERT INTO [AdminSQL].[dbo].[TBShrinkDB]
	(ServerName,
	DRIVE,
	DISKSPACEFREE,
	DATABASENAME,
	FILNAME, 
	FILETYPE,
	FILESIZE,
	SPACEFREE,
	PHYSICAL_NAME,
	TIMESTAMP )
SELECT  @@servername, 
		C.DRIVE, 
         CASE  
           WHEN (C.MBFREE) > 1000 THEN CAST(CAST(((C.MBFREE) / 1024.0) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' GB' 
           ELSE CAST(CAST((C.MBFREE) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' MB' 
         END AS DISKSPACEFREE, 
         A.NAME AS DATABASENAME, 
         B.NAME AS FILENAME, 
         CASE B.TYPE  
           WHEN 0 THEN 'DATA' 
           ELSE TYPE_DESC 
         END AS FILETYPE, 
         CASE  
           WHEN (B.SIZE * 8 / 1024.0) > 1000 
           THEN CAST(CAST(((B.SIZE * 8 / 1024) / 1024.0) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' GB' 
           ELSE CAST(CAST((B.SIZE * 8 / 1024.0) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' MB' 
         END AS FILESIZE, 
         CAST((B.SIZE * 8 / 1024.0) - (D.SPACEUSED / 128.0) AS DECIMAL(15,2)) SPACEFREE, 
         B.PHYSICAL_NAME,
		 TIMESTAMP=GETDATE()
FROM     sys.databases A 
         JOIN sys.master_files  B 
           ON A.DATABASE_ID = B.DATABASE_ID 
         JOIN #TMPFIXEDDRIVES C 
           ON LEFT(B.PHYSICAL_NAME,1) = C.DRIVE 
         JOIN #TMPSPACEUSED D 
           ON A.NAME = D.DBNAME 
              AND B.NAME = D.FILENME 
ORDER BY DISKSPACEFREE, 
         SPACEFREE DESC 
          
DROP TABLE #TMPFIXEDDRIVES 

DROP TABLE #TMPSPACEUSED

SELECT * FROM [AdminSQL].[dbo].[TBShrinkDB]
--where PHYSICAL_NAME like '%QuickMDCube_FR_Data1%'

/* ALIMENTATION TABLE SHRINK_TABLE POUR REPORTING */
INSERT  AUBFRTESTSQL02.[AdminMonitor].[dbo].[SHRINK_TABLE_V2]
	(ServerName,
	DRIVE,
	DISKSPACEFREE,
	DATABASENAME,
	FILNAME, 
	FILETYPE,
	FILESIZE,
	SPACEFREE,
	PHYSICAL_NAME,
	[TIMESTAMP])
SELECT ServerName,
	DRIVE,
	DISKSPACEFREE,
	DATABASENAME,
	FILNAME, 
	FILETYPE,
	FILESIZE,
	SPACEFREE,
	PHYSICAL_NAME,
	TIMESTAMP
  FROM [AdminSQL].[dbo].[TBShrinkDB]



  SELECT * FROM AUBFRTESTSQL02.[AdminMonitor].[dbo].[SHRINK_TABLE_V2]

    END

--PRINT (@SQL)
--INSERT INTO AdminMonitor..SHRINK_TABLE_V2 (SERVERNAME,DBName,[TYPE],[FILENAME],[FILEGROUP_NAME],[FILE_LOCATION],[FILESIZE],[USEDSPACE_GB],[FREESPACE_GB],[FREESPACE_%],[AutoGrow]) 

--EXEC(@SQL)



GO

/*CREATION DU JOB D'UPDATE POUR REPORTING*/

----USE [msdb]
----GO

----/****** Object:  Job [MONITOR SHRINK FREE SPACE]    Script Date: 10/04/2017 14:19:16 ******/
----BEGIN TRANSACTION
----DECLARE @ReturnCode INT
----SELECT @ReturnCode = 0
----/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10/04/2017 14:19:16 ******/
----IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
----BEGIN
----EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
----IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

----END

----DECLARE @jobId BINARY(16)
----EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'MONITOR SHRINK FREE SPACE', 
----		@enabled=1, 
----		@notify_level_eventlog=0, 
----		@notify_level_email=0, 
----		@notify_level_netsend=0, 
----		@notify_level_page=0, 
----		@delete_level=0, 
----		@description=N'No description available.', 
----		@category_name=N'[Uncategorized (Local)]', 
----		@owner_login_name=N'QUICK\hamcham', @job_id = @jobId OUTPUT
----IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
----/****** Object:  Step [MONITOR FREE SHRINK SPACE]    Script Date: 10/04/2017 14:19:16 ******/
----EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'MONITOR FREE SHRINK SPACE', 
----		@step_id=1, 
----		@cmdexec_success_code=0, 
----		@on_success_action=1, 
----		@on_success_step_id=0, 
----		@on_fail_action=2, 
----		@on_fail_step_id=0, 
----		@retry_attempts=0, 
----		@retry_interval=0, 
----		@os_run_priority=0, @subsystem=N'TSQL', 
----		@command=N'EXEC [AdminSQL].[dbo].[usp_ShrinkSpaceFile]', 
----		@database_name=N'master', 
----		@flags=0
----IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
----EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
----IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
----EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'MONITOR 22H SHRINK FREE SPACE', 
----		@enabled=1, 
----		@freq_type=4, 
----		@freq_interval=1, 
----		@freq_subday_type=1, 
----		@freq_subday_interval=0, 
----		@freq_relative_interval=0, 
----		@freq_recurrence_factor=0, 
----		@active_start_date=20170410, 
----		@active_end_date=99991231, 
----		@active_start_time=220000, 
----		@active_end_time=235959
----IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
----EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
----IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
----COMMIT TRANSACTION
----GOTO EndSave
----QuitWithRollback:
----    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
----EndSave:

----GO




