DECLARE @exec int set @exec=998
IF @exec=999 goto process1;
goto fin1;

process1:
 DECLARE @debut_date  datetime
SET @debut_date = convert (char (8),GETDATE()-1,112)
DECLARE @Table NVARCHAR(MAX) = N''

 IF OBJECT_ID('#ErrorLog') is not null drop table #SQL_Log_Errors
--create table #SQL_Log_Errors (
--[JobName] varchar (500) ,
--[LastRunDateTime] datetime,
--[JobsStatus] varchar (50),
--[Message] varchar (500),
--[NextRunDateTime]datetime )

 
--insert into #SQL_Log_Errors
SELECT @Table=@Table+'<td>'+[JobName]+'</td>'+
'<td>' + CONVERT(VARCHAR(30),[LastRunDateTime],120) + '</td>' +
'<td>' + convert (VARCHAR(30),[LastRunStatus],120)+ '</td>' +
'<td>' + CONVERT(VARCHAR(200),[Message],120)+ '</td>' +
'<td>' + CONVERT(VARCHAR(30),NextRunDateTime,120)+ '</td>' +
'</tr>'
FROM (
SELECT [sJOB].[name] AS [JobName]
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
    , CASE [sJOBH].[run_status]
        WHEN 0 THEN 'Failed'
        WHEN 1 THEN 'Succeeded'
        WHEN 2 THEN 'Retry'
        WHEN 3 THEN 'Canceled'
        WHEN 4 THEN 'Running' -- In Progress
      END AS [LastRunStatus]
    --, STUFF(
    --        STUFF(RIGHT('000000' + CAST([sJOBH].[run_duration] AS VARCHAR(6)),  6)
    --            , 3, 0, ':')
    --        , 6, 0, ':') 
    --    AS [LastRunDuration (HH:MM:SS)]
    , [sJOBH].[message] AS [Message]
    , CASE [sJOBSCH].[NextRunDate]
        WHEN 0 THEN NULL
        ELSE CAST(
                CAST([sJOBSCH].[NextRunDate] AS CHAR(8))
                + ' ' 
                + STUFF(
                    STUFF(RIGHT('000000' + CAST([sJOBSCH].[NextRunTime] AS VARCHAR(6)),  6)
                        , 3, 0, ':')
                    , 6, 0, ':')
                AS DATETIME)
      END AS [NextRunDateTime]
FROM 
    [msdb].[dbo].[sysjobs] AS [sJOB]
    LEFT JOIN (
                SELECT
                    [job_id]
                    , MIN([next_run_date]) AS [NextRunDate]
                    , MIN([next_run_time]) AS [NextRunTime]
                FROM [msdb].[dbo].[sysjobschedules]
                GROUP BY [job_id]
            ) AS [sJOBSCH]
        ON [sJOB].[job_id] = [sJOBSCH].[job_id]
    LEFT JOIN (
                SELECT 
                    [job_id]
                    , [run_date]
                    , [run_time]
                    , [run_status]
                    , [run_duration]
                    , [message]
                    , ROW_NUMBER() OVER (
                                            PARTITION BY [job_id] 
                                            ORDER BY [run_date] DESC, [run_time] DESC
                      ) AS RowNumber
                FROM [msdb].[dbo].[sysjobhistory]
                WHERE [step_id] = 0
            ) AS [sJOBH]
        ON [sJOB].[job_id] = [sJOBH].[job_id]
        AND [sJOBH].[RowNumber] = 1

		--where [sJOB].[name] like 'FULL%'
		where convert (char (8),[sJOBH].[run_date],112) >=@debut_date
		--and [sJOB].[name] like  '%ADM%'
		and [sJOBH].[run_status] <>1
		)t
ORDER BY [JobName]

 
declare @tableHTML nvarchar(max);
set @tableHTML =
N'<H><b>Bonjour,<BR></BR></H></b>' + 
N'<H><b>Veuillez trouver ci dessous le rapport des jobs sql en erreur pour l''instance - ' + @@SERVERNAME + '</b><BR></BR></H>' +
N'<table border="1" cellpadding="2" cellspacing="2" style="color:Black;font-family:arial,calibri,italic;text-align:center;" >' +
N'<tr style ="color:Black;font-size: 16px;font-weight: normal;background: lightsteelblue;">
<td>JobName</td>
<td>LastRunDateTime</td>
<td>JobsStatus</td>
<td>Message</td>
<td>NextRunDateTime</td></tr> '+@Table+
N'</table>' ;


SET @tableHTML =+ @tableHTML + 



            N'<H><BR></BR></H>' +

            N'<H><b>Merci d''analyser et r&#233soudre les probl&#232mes</b><BR></BR></H>' +

            N'<H><b>Cordialement,</b><BR></BR></H>' +

            N'<H><b>Mikael H.</b></i></H>' ;

 print @tableHTML
 --SET @tableHTML1 =+ @tableHTML1 +
 
declare @strsubject varchar(100)
declare @oper_email nvarchar(100)
 
set @oper_email = (select email_address from msdb.dbo.sysoperators where name = 'DBA')
select @strsubject='Rapport des jobs en erreur sur l''Instance ' + @@SERVERNAME

--declare @test int = (select case when @@SERVERNAME='SLBKQ129\MSSQL_2017' then 1 else 0 end)
--print @test
--print @@servername

IF @@SERVERNAME='KINGMDSPRD\MDMPRD' goto process;
IF @@SERVERNAME<>'KINGMDSPRD\MDMPRD' goto process2;
goto fin;

process: 
--print 'test'
EXEC msdb.dbo.sp_send_dbmail
@recipients= 'svp.intranet@QUICK.FR',
@copy_recipients= 'mikael.hamchaoui@bkqservices.com',
@subject = @strsubject,
@body = @tableHTML,
@body_format = 'HTML',
@profile_name='EnvoiMail'
 
 goto fin;

 process2:
 --print 'test2'
EXEC msdb.dbo.sp_send_dbmail
--@from_address='fichiers@quick.fr',
@recipients= 'mikael.hamchaoui@bkqservices.com',
@subject = @strsubject,
@body = @tableHTML,
@body_format = 'HTML',
@profile_name='EnvoiMail'


 fin:


  fin1:
   PRINT @exec
