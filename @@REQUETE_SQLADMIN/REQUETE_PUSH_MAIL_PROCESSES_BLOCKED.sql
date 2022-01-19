/*
Discialmer:
The sample scripts are provided AS IS without warranty of any kind. The entire risk arising out of the use or performance of the sample scripts and 
documentation remains with you. In no event I shall be liable for any damages whatsoever (including, without limitation, damages for loss of business 
profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts.
*/


SET nocount ON; 
SET concat_null_yields_null OFF 

go 

WITH blockers (spid, blocked, level, batch, lastwaittype,waittime,hostname,cmd,dbid,loginname,open_tran,login_time) 
     AS (SELECT spid, 
                blocked, 
                Cast (Replicate ('0', 4-Len (Cast (spid AS VARCHAR))) 
                      + Cast (spid AS VARCHAR) AS VARCHAR (1000))         AS 
                LEVEL, 
                Replace (Replace (T.text, Char(10), ' '), Char (13), ' ') AS 
                BATCH, 
                R.lastwaittype,r.waittime /1000 /60 as waittime_minutes,
                R.hostname,r.cmd,r.dbid,r.loginame,r.open_tran,r.login_time
         FROM   sys.sysprocesses R WITH (nolock) 
                CROSS apply sys.Dm_exec_sql_text(R.sql_handle) T 
         WHERE  ( blocked = 0 
                   OR blocked = spid ) 
                AND EXISTS (SELECT spid, 
                                   blocked, 
                                   Cast (Replicate ('0', 4-Len (Cast (spid AS 
                                         VARCHAR 
                                         ))) 
                                         + Cast (spid AS VARCHAR) AS VARCHAR ( 
                                         1000)) 
                                   AS 
                                       LEVEL, 
                                   blocked, 
                                   Replace (Replace (T.text, Char(10), ' '), 
                                   Char (13 
                                   ), 
                                   ' ') AS 
                                       BATCH, 
                                   R.lastwaittype, r.waittime /1000 /60 as waittime_minutes,
                                    R.hostname,r.cmd,r.dbid,r.loginame,r.open_tran,r.login_time
                            FROM   sys.sysprocesses R2 WITH (nolock) 
                                   CROSS apply 
                                   sys.Dm_exec_sql_text(R.sql_handle) T 
                            WHERE  R2.blocked = R.spid 
                                   AND R2.blocked <> R2.spid) 
         UNION ALL 
         SELECT R.spid, 
                R.blocked, 
                Cast (blockers.level 
                      + RIGHT (Cast ((1000 + R.spid) AS VARCHAR (100)), 4) AS 
                      VARCHAR 
                      ( 
                      1000)) AS 
                LEVEL, 
                Replace (Replace (T.text, Char(10), ' '), Char (13), ' ') 
                AS BATCH, 
                R.lastwaittype,r.waittime /1000 /60 as waittime_minutes,
                R.hostname ,r.cmd,r.dbid,r.loginame,r.open_tran,r.login_time
         FROM   sys.sysprocesses AS R WITH (nolock) 
                CROSS apply sys.Dm_exec_sql_text(R.sql_handle) T 
                INNER JOIN blockers 
                        ON R.blocked = blockers.spid 
         WHERE  R.blocked > 0 
                AND R.blocked <> R.spid
				and r.waittime >=300000) 
SELECT N'' +@@SERVERNAME as Instance ,
       + Replicate (N'|.......', Len (level)/4 - 2) 
       + CASE WHEN (Len (level)/4 - 1) = 0 THEN 'HEAD - ' ELSE '|------ ' END + 
       Cast ( 
       spid AS VARCHAR (10)) + ' ' + batch AS BLOCKING_TREE, 
       hostname, 
       lastwaittype,waittime, cmd,dbid,loginname,open_tran,login_time,
       Getdate()                           AS 'RunTime' ,
       level
INTO #BLOCKERS
FROM   blockers WITH (nolock) 
ORDER  BY level ASC 

    --Select BLOCKING_TREE,hostname,lastwaittype,time,cmd,dbid,loginname,open_tran from   #BLOCKERS
    --order by level asc

    DECLARE @tableHTML NVARCHAR(MAX);
	
    SET @tableHTML =  N'<H1>'+@@SERVERNAME+'</H1>' + N'<H1>Blocking Tree Report</H1>' + N'<table border="1">' + N'<tr>' + 
   N'<th>Instance</th>' + N'<th>Blocking_Tree</th>' + N'<th>hostname</th>' + N'<th>lastwaittype</th>'+ N'<th>waittime</th>'+'<th>CurrentTime</th>' 
    + N'<th>cmd</th>' 
    + N'<th>dbid</th>' 
    + N'<th>loginname</th>' 
    + N'<th>open_tran</th>' 
    + N'<th>login_time</th>' 
    + '</tr>' + CAST((
SELECT td = Instance,'',
		 td = Blocking_Tree,'',
         td =hostname,'',
         td =lastwaittype,'',
		 td =waittime,'',
         td =RunTime,'',
         td= cmd,'',
         td= dbid,'',
         td= loginname,'',
         td=open_tran,'',
         td=login_time,''
         FROM #BLOCKERS
             order by level asc
FOR XML PATH('tr')
                    ,TYPE
                ) AS NVARCHAR(MAX)) + N'</table>';   

If (select count(*) from #BLOCKERS) > 1
begin

    EXEC msdb.dbo.sp_send_dbmail @body = @tableHTML
        ,@body_format = 'HTML'
        , @recipients='mikael.hamchaoui@bkqservices.com'
	    ,@profile_name = 'EnvoiMail'
        ,@Subject = N'Blocking Tree Report '  
end

drop table #BLOCKERS