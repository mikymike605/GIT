USE [AdminSQL]
GO
-- SELECT * FROM [dbo].[SQLErrorLog]

DROP TABLE [dbo].[SQLErrorLog]

CREATE TABLE [dbo].[SQLErrorLog]
(  
   [ServerName]  [SYSNAME],
   [LogDate]     [DATETIME]      NULL,
   [ProcessInfo] [VARCHAR](50)   NULL,
   [Text]        [VARCHAR](2000) NULL,
   [Count]       [INT]           NULL
) 
/*
Listing 1========Create the exclusion table:
*/

USE [AdminSQL]
GO
-- SELECT * FROM [dbo].[SQLErrorLog_Exclude]
DROP TABLE [dbo].[SQLErrorLog_Exclude]
CREATE TABLE [dbo].[SQLErrorLog_Exclude]
(
   [Text]       [VARCHAR](200) NOT NULL,
   [ServerName] [SYSNAME] NULL,
   [StartHour]  [SMALLINT] NULL,
   [EndHour]    [SMALLINT] NULL
) 

GO

/*
Listing 2
Populate the exclusion table to avoid warnings about 
‘expected’ log entries. You may want to check out 
this script for some ideas. Tailor to your needs
*/
-- Populate exclusion table (lines from the SQL error log we do not want to show up in the error log warning mail)

USE [AdminSQL]
GO
TRUNCATE TABLE [SQLErrorLog_exclude] 
;

/*
  Columns and order:
  1) Error Text 
  2) Server name 
  3) Start hour 
  4) End hour
Examples:
    -Exclude all occurrences of 'error text' on any server, any time
INSERT INTO [SQLErrorLog_exclude] 
      SELECT '%error text%', null, null, null 
    -Exclude all occurrences of 'AppDomain xx created', where 'xx' is any number, on any server, any time
INSERT INTO [SQLErrorLog_exclude] 
      SELECT '%AppDomain % created%', null, null, null 
   - Only exclude an error if it occurs on ServerA
INSERT INTO [SQLErrorLog_exclude] 
     SELECT '%error text%', 'ServerA', null, null 
   - Only exclude an error if it occurs on ServerA between 7PM and 9PM
INSERT INTO [SQLErrorLog_exclude] 
     SELECT '%error text%', 'ServerA', 19, 21
*/

USE [AdminSQL]
TRUNCATE TABLE [SQLErrorLog_exclude] 

-- Columns and order:
-- 1) Error Text 2) Server name 3) Start hour 4) End hour

INSERT INTO [SQLErrorLog_exclude] 
          SELECT '%(c)%',                                                        null, null, null 
UNION ALL SELECT '%Microsoft SQL Server%',                                       null, null, null
UNION ALL SELECT '%A self-generated certificate was successfully loaded %',      null, null, null
UNION ALL SELECT '%All rights reserved%',                                        null, null, null
UNION ALL SELECT '%Authentication mode is MIXED%',                               null, null, null
UNION ALL SELECT '%backed up%',                                                  null, null, null 
UNION ALL SELECT '%changed from 0 to 0%',                                        null, null, null
UNION ALL SELECT '%Clearing tempdb database%',                                   null, null, null
UNION ALL SELECT '%Configuration option ''show advanced options'' changed%',     null, null, null
UNION ALL SELECT '%Database mirroring has been enabled on this instance%',       null, null, null
UNION ALL SELECT '%Dedicated admin connection support was established%',         null, null, null
UNION ALL SELECT '%Error: 14420%',                                               null, null, null
UNION ALL SELECT '%Error: 14421%',                                               null, null, null
UNION ALL SELECT '%Error: 18456%',                                               null, null, null
UNION ALL SELECT '%FILESTREAM: effective level = 0, configured level = 0%',      null, null, null  
UNION ALL SELECT '%found 0 errors and repaired 0 errors%',                       null, null, null 
UNION ALL SELECT '%I/O is frozen on database%',                                  null, null, null
UNION ALL SELECT '%I/O was resumed on database%',                                null, null, null
UNION ALL SELECT '%informational message%',                                      null, null, null 
UNION ALL SELECT '%Log was restored%',                                           null, null, null
UNION ALL SELECT '%Logging SQL Server messages in file%',                        null, null, null
UNION ALL SELECT '%provider is ready to accept connection%',                     null, null, null
UNION ALL SELECT '%Registry startup parameters%',                                null, null, null
UNION ALL SELECT '%Service Broker manager has started%',                         null, null, null
UNION ALL SELECT '%Server is listening on%',                                     null, null, null
UNION ALL SELECT '%Server process ID is%',                                       null, null, null
UNION ALL SELECT '%Starting up database%',                                       null, null, null
UNION ALL SELECT '%System Manufacturer: ''VMware, Inc.''%',                      null, null, null
UNION ALL SELECT '%The Database Mirroring protocol transport is now listening%', null, null, null
UNION ALL SELECT '%The error log has been reinitialized%',                       null, null, null
UNION ALL SELECT '%The Service Broker protocol transport is disabled%',          null, null, null
UNION ALL SELECT '%Using locked pages for buffer pool%',                         null, null, null   
UNION ALL SELECT '%Error 778263, severity 16, state 1 was raised%',              null, null, null
UNION ALL SELECT '%Failure to calculate super-latch promotion threshold%',       null, null, null
UNION ALL SELECT '%Using ''dbghelp.dll'' version ''4.0.5''%',                    null, null, null
UNION ALL SELECT '%SQL Trace ID 1 was started by login ''sa''%',                 null, null, null
UNION ALL SELECT '%BACKUP DATABASE successfully processed%',                     null, null, null
UNION ALL SELECT '%BACKUP DATABASE WITH DIFFERENTIAL successfully processed%',   null, null, null
UNION ALL SELECT '%Command Line Startup Parameters: -s%',                        null, null, null
UNION ALL SELECT '%Using conventional memory%',                                  null, null, null
UNION ALL SELECT '%CLR version v4.0.30319 loaded%',                              null, null, null
UNION ALL SELECT '%Resource governor reconfiguration%',                          null, null, null
UNION ALL SELECT '%Software Usage Metrics is enabled%',                          null, null, null
UNION ALL SELECT '%A new instance of the full-text filter daemon host process%', null, null, null
UNION ALL SELECT '%Common language runtime (CLR) functionality initialized%',    null, null, null
UNION ALL SELECT '%dbname:rtc: RtcNightlyMaint executed%',                      'SQL-01', null, null
UNION ALL SELECT '%Authentication mode is WINDOWS-ONLY%',                       'SQL-02', 5, 7
;
/*
Listing 3
Create the main stored procedure 
to read the error logs:
*/
USE [AdminSQL]
GO

ALTER PROCEDURE [dbo].[Retrieve_LinkedServer_ErrorLog]
    @Server_Name SYSNAME  = @@SERVERNAME
  , @Start_Time  DATETIME = NULL
  , @End_Time    DATETIME = NULL
AS

/*  Procedure to retrieve SQL error log entries from a linked server for central monitoring purposes.
    This procedure is run from a central monitor server.

    Parameters: 
      @Server_Name: name of a linked server as data source
      @Start_Time : date/time of first Error Log record to be retrieved. Default = current date/time - 1 day
      @End_Time   : date/time of last Error Log record to be retrieved.  Default = current date/time 
       
    Steps:
      1) Create table in tempdb on linked server to hold records or truncate table if it already exists.
      2) Execute XP_READERRORLOG on linked server with a start and end date. The current log file and 6 previous versions are scanned,
         in order not to miss records in case of a new log file / new log files. 
      3) Copy the records to a holding table on the monitor server, while doing some aggregation
         (in case of records with identical 'text', the oldest date/time and SPID value are retained).
*/

IF @Start_Time IS NULL 
  SELECT @Start_Time = GETDATE()-1
IF @End_Time   IS NULL 
  SELECT @End_Time   = GETDATE()
  
DECLARE @cmd NVARCHAR(MAX) 
SELECT @cmd = '
  DECLARE @a NVARCHAR(MAX);
  SELECT @a = ''SET NOCOUNT ON;
                IF NOT EXISTS (SELECT 1 FROM tempdb.sys.objects WHERE name = ''''TempSQLErrorLog'''' AND type = ''''U'''')
                BEGIN
                  CREATE TABLE tempdb.dbo.TempSQLErrorLog (
                     [LogDate]     DATETIME,
                     [ProcessInfo] VARCHAR(50),
                     [Text]        VARCHAR(1000)  )
                END
                ELSE
                BEGIN
                  TRUNCATE TABLE tempdb.dbo.TempSQLErrorLog;
                END
                
                DECLARE @no SMALLINT
                SELECT  @no = 0
                WHILE (@no < 7)
                BEGIN
                  INSERT INTO tempdb.dbo.TempSQLErrorLog
                      EXEC master.sys.xp_readerrorlog @no, 1, NULL, NULL, '
                      + '''''' + CONVERT(VARCHAR(19),@start_time,120) + '''''' + ', '
                      + '''''' + CONVERT(VARCHAR(19),@end_time,120)   + '''''' + '
                  SELECT @no = @no + 1
                END
              ''
  EXEC [' + @server_name + '].master.dbo.sp_executesql @statement = @a    -- execute command stored in @a on linked server 
  '
  -- PRINT @cmd  -- for debug purposes
EXEC (@cmd)      -- exec the nested exec statement  

 -- Copy remote records to local holding table and add server name.
 -- For entries with identical value in Text field, only the record with lowest Logdate and Processinfo value is copied, and Count field is incremented.
SELECT   @cmd = '
  SET NOCOUNT ON;
  INSERT INTO AdminSQL.dbo.SQLErrorLog                 
      SELECT   ''' + @Server_Name + '''
           , MIN(Logdate)
           , MIN(Processinfo)
           , Text
           , COUNT(*)
    FROM [' + @Server_Name + '].tempdb.dbo.TempSQLErrorLog 
    GROUP BY [Text]
    '
  -- PRINT @cmd  -- for debug purposes
EXEC master.dbo.sp_executesql @cmd  -- execute command stored in @cmd
GO
/*Listing 4
Create the procedure to filter the error logs:
*/
USE [AdminSQL]
GO

ALTER PROCEDURE [dbo].[Cleanup_Errorlog_Holding_Table]
AS

/*** Script to clean up the SQL Errorlog holding table, based on a table containing entries to be excluded.
     The exclude table contains entries that need not be reported, so these can be deleted from the
     holding table. After this 'cleanup', all remaining entries in the holding table will be mailed as a
     notification.

     An exclusion MUST contain
     - a text string. Records in the errorlog holding table containing this text 
       (+ any other text surrounding it) will be deleted.
     - in the text column: a percentage sign as first and as last character (unless it represents the entire text of the line you want deleted).

     An exclusion MAY contain
     - a 'starthour' and 'endhour'. All entries recorded between starthour and endhour 
       and containing the specified text will be deleted.
     - a server name. All entries containing the specified text, coming from this server
       and recorded between starthour and endhour will be deleted.
     - in the text column: a percentage sign used as wildcard within a text string, for pieces of text that are variable, such as numbers or names
*/

SET NOCOUNT ON
DECLARE cleanup CURSOR FOR
SELECT   RTRIM(LTRIM([text]))
       , ServerName
       , StartHour
       , EndHour 
FROM     dbo.SQLErrorLog_Exclude

DECLARE   @text       VARCHAR(200)
        , @servername SYSNAME
        , @starthour  SMALLINT
        , @endhour    SMALLINT

OPEN cleanup
FETCH NEXT FROM cleanup INTO @text, @servername, @starthour, @endhour
WHILE @@FETCH_STATUS = 0
  BEGIN
    IF @starthour IS NULL AND @endhour IS NULL
      -- Delete all records with this text, regardless of time reported
      DELETE dbo.SQLErrorLog 
      WHERE PATINDEX(@text,[Text]) > 0 
       AND (servername = @servername 
            OR @servername IS NULL)
    ELSE IF (@starthour = @endhour) OR (@starthour IS NULL AND @endhour IS NOT NULL)
     -- Delete records on the basis of @endhour
      DELETE dbo.SQLErrorLog 
      WHERE PATINDEX(@text,[Text]) > 0 
       AND (servername = @servername 
            OR @servername IS NULL)
       AND DATEPART(hh, [LogDate]) = @endhour
    ELSE IF (@starthour IS NOT NULL 
             AND @endhour IS NULL)
     -- Delete records on the basis of @starthour
      DELETE dbo.SQLErrorLog 
      WHERE PATINDEX(@text,[Text]) > 0 
       AND (servername = @servername 
            OR @servername IS NULL)
       AND DATEPART(hh, [LogDate]) = @starthour
    ELSE IF @starthour < @endhour
    -- Delete records >= @starthour and <= @endhourur
      DELETE dbo.SQLErrorLog 
      WHERE PATINDEX(@text,[Text]) > 0 
       AND (servername = @servername 
            OR @servername IS NULL)
       AND DATEPART(hh, [LogDate]) >= @starthour
       AND DATEPART(hh, [LogDate]) <= @endhour
    ELSE IF @starthour > @endhour
    -- Delete records >= @starthour or <= @endhour
      DELETE dbo.SQLErrorLog 
      WHERE PATINDEX(@text,[Text]) > 0 
       AND (servername = @servername 
            OR @servername IS NULL)
       AND (DATEPART(hh, [LogDate]) >= @starthour 
            OR DATEPART(hh, [LogDate]) <= @endhour)
    ELSE  -- undefined condition: log error
     BEGIN
       DECLARE @proc VARCHAR(500)
       SELECT @proc = DB_NAME() + '.' + OBJECT_SCHEMA_NAME (@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
       RAISERROR ( 'Proc: %s: Undefined condition found in exclusion table, please contact DBA. Offending line: %s, %s, %u, %u', 10, 1
                   , @proc, @servername, @text, @starthour ,@endhour) WITH LOG
     END

  FETCH NEXT FROM cleanup INTO @text, @servername, @starthour, @endhour
  END

CLOSE cleanup
DEALLOCATE cleanup

GO
/*
Listing 5
Create the procedure to mail the results:
   @recipients = 'mikael.hamchaoui@bkqservices.com' ,
   @profile_name = 'EnvoiMail'
*/
USE [AdminSQL]
GO

ALTER PROC [dbo].[Mail_SQLErrorlog]
      @recipients   VARCHAR(MAX) = 'mikael.hamchaoui@bkqservices.com'
    , @profile_name SYSNAME      = 'EnvoiMail'
AS

/* Script to mail 'unusual' SQL Error Log entries, after collection in a holding table on the monitor server.
   This script should be run after retrieval of linked server error logs (procedure 'Retrieve_LinkedServer_ErrorLog') 
   and removal of trivial messages (procedure 'Cleanup_Errorlog_Holding_Table')
*/
    -- Send message if the error log holding table contains entries other than failed logins  
IF EXISTS (SELECT 1 FROM dbo.SQLErrorlog WHERE CHARINDEX('Login failed for user', [text]) = 0)
 BEGIN
  DECLARE  @subj  VARCHAR(200)
         , @xml   NVARCHAR(MAX)
         , @body  NVARCHAR(MAX)

  SELECT   @subj   = 'SQL Error Log entries'
  SET @body = '<html><body>
               <p><font size="2" face="monaco">
               (This mail was sent by the procedure ''' + DB_NAME() + '.' + OBJECT_SCHEMA_NAME (@@PROCID) + '.' + OBJECT_NAME(@@PROCID) + ''') <BR><BR>               
               The table below contains unusual SQL Log entries recorded during the past 24 hours.
               <H3>SQL Errorlog entries</H3>
               <table border="1" cellpadding="5"> 
               <p><font size="2" face="monaco">               
               <tr>
               <th> Server </th> <th> Date </th> <th> Process </th> <th> Count </th> <th> Text </th> </tr>'    
  
  SET @xml = CAST(
           (SELECT   [ServerName]                   AS 'td',''
                   , CONVERT(CHAR(30),[LogDate],21) AS 'td',''
                   , [Processinfo]                  AS 'td',''
                   , [Count]                        AS 'td',''
                   , [Text]                         AS 'td','' 
            FROM     dbo.SQLErrorlog 
            WHERE    CHARINDEX('Login failed for user', [text]) = 0     -- no regular failed login warnings
            ORDER BY [ServerName], [Count] DESC, [LogDate] DESC
            FOR XML PATH('tr'), ELEMENTS) 
            AS NVARCHAR(MAX))
  SET @body = @body + @xml +'</table></body></html>'
  EXEC msdb.dbo.sp_send_dbmail              -- Send email 
       @profile_name = @profile_name
     , @recipients   = @recipients
     , @subject      = @subj
     , @body         = @body
     , @body_format  ='HTML'
END
/*
Listing 6
You are now ready to run a first check. As a test, from a query window, issue the commands below:
*/
--USE AdminSQL
EXEC AdminSQL..Retrieve_LinkedServer_ErrorLog
/*
The message ‘Command completed successfully’ should appear. You have now captured the error log info of your monitor server.
Next, try one of your linked servers. From your monitor server, issue the same command but add a server name, e.g. ‘ServerA’:
*/
EXEC AdminSQL..Retrieve_LinkedServer_ErrorLog @@servername
/*
(If you use a Windows login and run into error 18456: ‘Login failed for user 'NT AUTHORITY\ANONYMOUS LOGON’’, you can either try to fix the related SPN and/or ‘double hop’ problem or use a SQL login with sufficient privileges on all servers to avoid any Kerberos problems).
If this is successful, the error log records of both servers have been collected on the monitor server. Now, remove the records you do not want to show up:
*/
EXEC AdminSQL..Cleanup_Errorlog_Holding_Table
/*
Finally, send the mail:
*/
EXEC AdminSQL..Mail_SQLErrorlog
   @recipients = 'mikael.hamchaoui@bkqservices.com' ,
   @profile_name = 'EnvoiMail'
/*
Unless the filter has removed all messages you should now see ‘Mail queued’.
Please note that failed logins are not included in the mail. This is because in
our company we report on these separately, in a modified format including a column for source IP address. 
If you do want failed logins included in the mail, simply remove the two occurrences of the ‘where’ statement from the code: WHERE CHARINDEX('Login failed for user', [text]) = 0
To separately report on failed logins, you can use this procedure:
*/

USE [AdminSQL]
GO

ALTER PROC [dbo].[Mail_Failed_Logins]
      @recipients   VARCHAR(MAX) = 'mikael.hamchaoui@bkqservices.com'
    , @profile_name SYSNAME      = 'EnvoiMail'
AS

/* Script to mail failed login attempts recorded in SQL Error Logs, after collection in a holding table on the monitor server.
   This script should be run after retrieval of linked server error logs (procedure 'Retrieve_LinkedServer_ErrorLog') 
   and removal of trivial messages (procedure 'Cleanup_Errorlog_Holding_Table')
   Messages other than failed login attempts are excluded; these are mailed by a separate procedure ('Mail_SQLErrorlog').
*/

IF EXISTS (SELECT 1 FROM dbo.SQLErrorlog WHERE  CHARINDEX('Login failed for user', [Text]) > 0)
BEGIN
  DECLARE  @subj  VARCHAR(200)
         , @body  NVARCHAR(MAX)
         , @xml   NVARCHAR(MAX)
         
  SELECT   @subj = 'Failed SQL logins'
  SET      @body = '<html><body>
               <p><font size="2" face="monaco">
               (This mail was sent by the procedure ''' + DB_NAME() + '.' + OBJECT_SCHEMA_NAME (@@PROCID) + '.' + OBJECT_NAME(@@PROCID) + ''') <BR><BR>                              
               The table below contains SQL failed logins recorded during the past 24 hours.
               <H3>SQL Failed Logins</H3>
               <table border="1" cellpadding="5"> 
               <p><font size="2" face="monaco">
               <tr>
               <th> Server </th> <th> Date </th> <th> Login Name </th> <th> Count </th> <th> Client Name </th> <th> Extra Info </th> </tr>'
  SELECT  @xml = CAST( 
                (SELECT   LEFT([ServerName],25)                     AS 'td',''            -- Server
                        , CONVERT(CHAR(30),[LogDate],21)            AS 'td',''            -- Date
                        , CASE 
                            WHEN CHARINDEX('''''' , [Text]) > 0 
                            THEN ''
                            ELSE LEFT(SUBSTRING([Text], CHARINDEX('''' , [Text]) + 1, CHARINDEX('''', [Text], CHARINDEX('''' , [Text]) + 1) - CHARINDEX('''' , [Text]) - 1),30)
                          END                                       AS 'td',''            -- Login Name
                        , [COUNT]                                   AS 'td',''            -- Count
                        , LEFT(SUBSTRING([Text], CHARINDEX('[CLIENT', [Text]) + 9, CHARINDEX(']', [Text]) - CHARINDEX('[CLIENT', [Text]) - 9),17)
                                                                    AS 'td',''            -- Client Name
                        , CASE 
                            WHEN CHARINDEX('''. [',[Text]) = 0
                              -- print extra info if any is found between user name (terminated by single quote, full stop and space) and CLIENT info (starting with left square bracket
                            THEN LEFT(SUBSTRING([Text], CHARINDEX('''. ',[Text]) + 3, CHARINDEX('. [',[Text]) - CHARINDEX('''. ',[Text]) - 1),100)
                              -- print the info between the user name and client IP address
                            ELSE '' 
                          END                                       AS 'td',''            -- Extra Info
                 FROM   dbo.SQLErrorlog 
                 WHERE  CHARINDEX('Login failed for user', [Text]) > 0
                 ORDER BY 1, 2, 3, 5
                 FOR XML PATH('tr'), ELEMENTS ) 
                 AS NVARCHAR(MAX))
           
  SET @body = @body + @xml +'</table></body></html>'

  EXEC msdb.dbo.sp_send_dbmail              -- Send email
       @profile_name = @profile_name
     , @recipients   = @recipients
     , @subject      = @subj
     , @body         = @body
     , @body_format  ='HTML'
END
/*
Listing 7
An example of its output : How do you make the procedures in Listing 4 
run against all your linked servers? You can either write a FOR loop, or use a wrapper procedure like this, 
which I use to run a bunch of other SP’s against the servers defined on my monitor server:
*/

USE [AdminSQL]
GO

ALTER PROC [dbo].[Check_Remote_Servers]
   @proc        SYSNAME
AS

/* Execute a stored procedure against all linked servers defined on this server.
** Params: @proc        = name of stored procedure to be executed
** Example: EXEC Check_Remote_Servers @proc = 'Retrieve_LinkedServer_ErrorLog'
** This will execute the procedure 'Retrieve_LinkedServer_ErrorLog' against all linked servers
*/

SET NOCOUNT ON
DECLARE   @server_name SYSNAME
        , @cmd         NVARCHAR(MAX) 
DECLARE   @linked_servers TABLE ([server_name] SYSNAME)
INSERT    @linked_servers
  SELECT  name 
  FROM    master.sys.servers 

SELECT   @server_name = MIN([server_name]) FROM @linked_servers
WHILE @server_name IS NOT NULL
  BEGIN
    PRINT 'Starting proc ''' + @proc + ''' on server ''' + @server_name + ''''
    SET @cmd = 'EXEC [' + @proc + '] @Server_Name = [' + @server_name + '] ' 
    EXEC sp_executesql @cmd                   
    DELETE @linked_servers WHERE [server_name] = @server_name
    SELECT  @server_name = MIN([server_name]) FROM @linked_servers
  END
  /*
Listing 8
If you have this in place, you can combine the commands in a SQL Agent job, to run each night from MonitorDB:
  -- empty holding table to allow for new content
*/
TRUNCATE TABLE SQLErrorlog

  -- Collect remote error log entries
EXEC Check_Remote_Servers
  @proc = 'Retrieve_LinkedServer_ErrorLog'

  -- remove unwanted entries from holding table
EXEC AdminSQL..Cleanup_Errorlog_Holding_Table

  -- mail error log records
EXEC AdminSQL..[Mail_SQLErrorlog]
  @recipients = 'mikael.hamchaoui@bkqservices.com'
  , @profile_name = 'EnvoiMail'

  -- mail failed logins 
EXEC AdminSQL..[Mail_Failed_Logins]
  @recipients = 'mikael.hamchaoui@bkqservices.com'
  , @profile_name = 'EnvoiMail'


