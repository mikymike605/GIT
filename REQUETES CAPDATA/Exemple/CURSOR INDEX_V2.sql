DECLARE @servername varchar(250) 
DECLARE @requete varchar(5000) 
DECLARE product_cursor CURSOR FOR 


SELECT name FROM [AdminMonitor]..[Server] 

OPEN product_cursor 
FETCH FROM product_cursor INTO @SERVERNAME 

WHILE @@FETCH_STATUS = 0 
BEGIN 
set @servername = ''+@servername+''

PRINT @SERVERNAME 
set @requete = '


DECLARE @debut_date  datetime
SET @debut_date = convert (char (8),GETDATE()-1,112)


TRUNCATE TABLE ['+@SERVERNAME+'].[AdminSQL].[dbo].[TBjob]

CREATE TABLE ['+@SERVERNAME+'].[AdminSQL].[dbo].[TBjob](
	[Servername] [varchar](250) NULL,
	[JobName] [varchar](250) NULL,
	[DerniereExecution] [varchar](250) NULL,
	[Status] [varchar](250) NULL,
	[TempsDerniereExecution] [varchar](250) NULL,
	[MessageDerniereExecution] [varchar](250) NULL,
	[ProchaineExecution] [varchar](250) NULL
) ON [PRIMARY]


INSERT INTO ['+@SERVERNAME+'].[AdminSQL].[dbo].[TBjob]
(
	[Servername] ,
	[JobName] ,
	[DerniereExecution],
	[Status] ,
	[TempsDerniereExecution],
	[MessageDerniereExecution],
	[ProchaineExecution]
)
SELECT @@servername as Servername
	,[sJOB].[name] AS [JobName]
    , CASE 
        WHEN [sJOBH].[run_date] IS NULL OR [sJOBH].[run_time] IS NULL THEN NULL
        ELSE CAST(
                CAST([sJOBH].[run_date] AS CHAR(8))
                + '' '' 
                + STUFF(
                    STUFF(RIGHT(''000000'' + CAST([sJOBH].[run_time] AS VARCHAR(6)),  6)
                        , 3, 0, '':'')
                    , 6, 0, '':'')
                AS DATETIME)
      END AS [LastRunDateTime]
    , CASE [sJOBH].[run_status]
        WHEN 0 THEN ''Failed''
        WHEN 1 THEN ''Succeeded''
        WHEN 2 THEN ''Retry''
        WHEN 3 THEN ''Canceled''
        WHEN 4 THEN ''Running'' -- In Progress
      END AS [LastRunStatus]
    , STUFF(
            STUFF(RIGHT(''000000'' + CAST([sJOBH].[run_duration] AS VARCHAR(6)),  6)
                , 3, 0, '':'')
            , 6, 0, '':'') 
        AS [LastRunDuration (HH:MM:SS)]
    , [sJOBH].[message] AS [LastRunStatusMessage]
    , CASE [sJOBSCH].[NextRunDate]
        WHEN 0 THEN NULL
        ELSE CAST(
                CAST([sJOBSCH].[NextRunDate] AS CHAR(8))
                + '' '' 
                + STUFF(
                    STUFF(RIGHT(''000000'' + CAST([sJOBSCH].[NextRunTime] AS VARCHAR(6)),  6)
                        , 3, 0, '':'')
                    , 6, 0, '':'')
                AS DATETIME)
      END AS [NextRunDateTime]
FROM 
   ['+@SERVERNAME+'].[msdb].[dbo].[sysjobs] AS [sJOB]
    LEFT JOIN (
                SELECT
                    [job_id]
                    , MIN([next_run_date]) AS [NextRunDate]
                    , MIN([next_run_time]) AS [NextRunTime]
                FROM ['+@SERVERNAME+'].[msdb].[dbo].[sysjobschedules]
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
                FROM ['+@SERVERNAME+'].[msdb].[dbo].[sysjobhistory]
                WHERE [step_id] = 0
            ) AS [sJOBH]
        ON [sJOB].[job_id] = [sJOBH].[job_id]
        AND [sJOBH].[RowNumber] = 1
		where convert (char (8),[sJOBH].[run_date],112) >=@debut_date
ORDER BY [JobName]
' ; 
	  
PRINT @requete 

  --EXEC  (@requete) 
                                                                
FETCH FROM product_cursor INTO @SERVERNAME 
END 
CLOSE product_cursor 
DEALLOCATE product_cursor 
GO


