USE [AdminSQL]
GO

/****** Object:  Table [dbo].[SQL_ErrorLog]    Script Date: 10/04/2018 11:50:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[SQL_ErrorLog](
	[TEXT] [varchar](8000) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



/****** Object:  StoredProcedure [dbo].[SQL_ErrorLog_Alert]    Script Date: 10/04/2018 11:40:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SQL_ErrorLog_Alert]
@Minutes [int] = NULL  
AS
BEGIN
SET NOCOUNT ON;
DECLARE @ERRORMSG varchar(8000)
DECLARE @SNO INT
DECLARE @Mins INT
DECLARE @SQLVERSION VARCHAR(4)
IF @Minutes IS NULL  -- If the optional parameter is not passed, @Mins value is set to 6
 SET @Mins = 6
ELSE
 SET @Mins = @Minutes
  /* Fetches the numeric part of SQL Version */
 SELECT @SQLVERSION = RTRIM(LTRIM(SUBSTRING(@@VERSION,22,5))) 

IF @SQLVERSION = '2000'  
 /* Checks the version of SQL Server and executes 
 the code depending on it since the output of the 
 sp_readerrorlog varies between SQL 2000 and the next versions */
 BEGIN
  
 /*Temporary table to store the output from execution of sp_readerrorlog */
  
 CREATE Table #ErrorLog2000 
 (ErrorLog varchar(4000),ContinuationRow Int) 
 INSERT INTO  #ErrorLog2000  -- Stores the output of sp_readerrorlog
 EXEC sp_readerrorlog
 /* The code below deletes the rows in the error log which are mostly 
 the SQL startup messages written into the error log */
  
 DELETE FROM #ErrorLog2000 
 WHERE (LEFT(LTRIM(ErrorLog),4) NOT LIKE DATEPART(YYYY,GETDATE()) 
    AND ContinuationRow = 0) 
 OR (ErrorLog LIKE '%Intel X86%')
 OR (ErrorLog LIKE '%Copyright %')
 OR (ErrorLog LIKE '%Microsoft %')
 OR (ErrorLog LIKE '%All rights reserved.%')
 OR (ErrorLog LIKE '%Server Process ID is %')
 OR (ErrorLog LIKE '%Logging SQL Server messages in file %')
 OR (ErrorLog LIKE '%Errorlog has been reinitialized%')
 OR (ErrorLog LIKE '%Starting up database %')
 OR (ErrorLog LIKE '%SQL Server Listening %')
 OR (ErrorLog LIKE '%SQL Server is ready %')
 OR (ErrorLog LIKE '%Clearing tempdb %')
 OR (ErrorLog LIKE '%Recovery %')
 OR (ErrorLog LIKE '%to execute extended stored procedure %')
 OR (ErrorLog LIKE '%Analysis of database %')
 OR (ErrorLog LIKE '%Edition%')
 OR LEN(ErrorLog) < 25 
 OR (CAST(LEFT(LTRIM(ErrorLog),23) AS DATETIME) 
  < CAST(DATEADD(MI,-@Mins,GETDATE()) AS VARCHAR(23)))

  /* Once the SQL Server startup and other information prior to 
  @Mins is deleted from the temporary table, the below code starts 
  concatenating the remaining rows in the temporary table 
  and stores into single variable */
  
 SELECT @ERRORMSG = COALESCE(@ERRORMSG + CHAR(13) , '')  
   + ErrorLog FROM #ErrorLog2000
  
 DROP TABLE #ErrorLog2000 
 END
ELSE
 BEGIN
 CREATE TABLE #ErrorLog2005 
 (LogDate DATETIME, ProcessInfo VARCHAR(50) ,[Text] VARCHAR(4000))
 INSERT INTO #ErrorLog2005 
 EXEC sp_readerrorlog
 DELETE FROM #ErrorLog2005 
 WHERE LogDate < CAST(DATEADD(MI,-@Mins,GETDATE()) AS VARCHAR(23))
 OR ([Text] LIKE '%Intel X86%')
 OR ([Text] LIKE '%Copyright%')
 OR ([Text] LIKE '%All rights reserved.%')
 OR ([Text] LIKE '%Server Process ID is %')
 OR ([Text] LIKE '%Logging SQL Server messages in file %')
 OR ([Text] LIKE '%Errorlog has been reinitialized%')
 OR ([Text] LIKE '%This instance of SQL Server has been using a process ID %')
 OR ([Text] LIKE '%Starting up database %')
 OR ([Text] LIKE '%SQL Server Listening %')
 OR ([Text] LIKE '%SQL Server is ready %')
 OR ([Text] LIKE '%Clearing tempdb %')
 OR ([Text] LIKE '%to execute extended stored procedure %')
 OR ([Text] LIKE '%Analysis of database %')
 OR ProcessInfo = 'Backup' -- Deletes backup information
 SELECT  @ERRORMSG = COALESCE(@ERRORMSG + CHAR(13) , '') 
   + CAST(LogDate AS VARCHAR(23)) + '  ' 
   + [Text] FROM #ErrorLog2005
  
 DROP TABLE #ErrorLog2005
 END
IF @ERRORMSG IS NOT NULL 
  -- There is some data in SQL error log that needs to be stored
 BEGIN
  IF  EXISTS (SELECT * FROM dbo.sysobjects 
    WHERE  id = OBJECT_ID(N'[dbo].[SQL_ErrorLog]') 
    AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
   
   INSERT INTO [dbo].[SQL_ErrorLog]
   SELECT @ERRORMSG
   
  ELSE
   
  BEGIN
   
  CREATE TABLE [dbo].[SQL_ErrorLog](
   [TEXT] [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
   ) ON [PRIMARY]
  INSERT INTO [dbo].[SQL_ErrorLog]
  SELECT @ERRORMSG
   
  END
 END
ELSE  -- No error messages have been in the last @Mins minutes
 Print 'No Error Messages'
END

GO

/****** Object:  StoredProcedure [dbo].[SQL_ErrorLog_Alert_Notify]    Script Date: 10/04/2018 11:40:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SQL_ErrorLog_Alert_Notify]
@LKDSVRNAME VARCHAR(128) = NULL
AS
BEGIN
SET NOCOUNT ON;
DECLARE @SUBJECT  VARCHAR(8000)
DECLARE @MSGBODY  VARCHAR(8000)
 IF @LKDSVRNAME IS NOT NULL  
    /* A linked server name is passed, so alert will be for the linked server.*/
  
 BEGIN
   
  CREATE TABLE #ERRTBL ([TEXT] VARCHAR(8000)) 
  /* Temporary table to poll the linked server 
  and store the error data to be used in the cursor, in the next step */
 
  INSERT INTO #ERRTBL
  EXEC('SELECT [Text] FROM ' + @LKDSVRNAME + '.Adminsql.DBO.SQL_ErrorLog')
  
  SET @SUBJECT = @LKDSVRNAME + ' SQL-SERVER ERROR LOG SUMMARY'
  DECLARE CURSOR1 CURSOR
  FOR SELECT [TEXT] FROM #ERRTBL
  
  OPEN CURSOR1
  FETCH NEXT FROM CURSOR1
  INTO @MSGBODY
  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'EnvoiMAIL', -- Modify the profile name
    @recipients = 'mikael.hamchaoui@bkqservices.com',-- Modify the email
    @body = @MSGBODY, 
    @subject = @SUBJECT ; 
  FETCH NEXT FROM CURSOR1
  INTO @MSGBODY
  END 
  CLOSE CURSOR1
  DEALLOCATE CURSOR1 
  EXEC ('DELETE FROM ' + @LKDSVRNAME + '.Adminsql.DBO.SQL_ErrorLog') 
     
     -- Modify the database name
     
  DROP TABLE #ERRTBL
   
 END
  ELSE  
  /* A linked server name is not passed, 
  so alert will be for the local server. */
   
 BEGIN
    
  SET @SUBJECT = @@SERVERNAME + ' SQL-SERVER ERROR LOG SUMMARY'
  DECLARE CURSOR1 CURSOR
  FOR SELECT [TEXT] FROM Adminsql.DBO.SQL_ErrorLog
  OPEN CURSOR1
  FETCH NEXT FROM CURSOR1
  INTO @MSGBODY
  WHILE @@FETCH_STATUS = 0
  BEGIN  
    EXEC msdb.dbo.sp_send_dbmail
     @profile_name = 'EnvoiMAIL', -- Modify the profile name
    @recipients = 'mikael.hamchaoui@bkqservices.com',-- Modify the email
    @body = @MSGBODY, 
    @subject = @SUBJECT ; 
 
  FETCH NEXT FROM CURSOR1
  INTO @MSGBODY
  END 
  CLOSE CURSOR1
  DEALLOCATE CURSOR1   
  DELETE FROM Adminsql.DBO.SQL_ErrorLog   -- Modify the database name
 END
END
GO

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [TEXT]
  FROM [AdminSQL].[dbo].[SQL_ErrorLog]

  USE [msdb]
GO

EXEC msdb.dbo.sp_add_alert @name=N'Severity 016', 
  @message_id=0, 
  @severity=16, 
  @enabled=1, 
  @delay_between_responses=60, 
  @include_event_description_in=1, 
  @job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 016', @operator_name=N'Operator1', @notification_method = 1
GO

