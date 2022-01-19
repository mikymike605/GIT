select 
 distinct j.name as 'JobName',
 --run_date,
 --run_time,
 msdb.dbo.agent_datetime(run_date, run_time) as 'RunDateTime',
 durationHHMMSS = STUFF(STUFF(REPLACE(STR(h.run_duration,7,0),
        ' ','0'),4,0,':'),7,0,':'),
    [start_date] = CONVERT(DATETIME, RTRIM(run_date) + ' '
        + STUFF(STUFF(REPLACE(STR(RTRIM(h.run_time),6,0),
        ' ','0'),3,0,':'),6,0,':'))
From msdb.dbo.sysjobs j 
INNER JOIN msdb.dbo.sysjobhistory h 
 ON j.job_id = h.job_id 
where j.enabled = 1  --Only Enabled Jobs
and j.name='Sauvegarde full des bases de donnees'
order by JobName, RunDateTime desc