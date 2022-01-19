select
                    --substring(N.SKDNAME,1,20) SCHEDULE,
                    substring(S.jobname,1,20) JOB,
                    -- substring(M.JOBSTATE,1,8) ETAT,
                    cast(S.STARTSTAMP-2 as datetime) START, 
                    cast(S.TERMSTAMP-2 as datetime) FIN, 
                    datediff(MINUTE,cast(S.STARTSTAMP-2 as datetime),cast(S.TERMSTAMP-2 as datetime)) Duree
					--,
                    --S.ESTRUNTIME
                    --,S.* 
                    from 
                    SMASTER S  join JSTATMAP M on S.STSTATUS = M.STSTATUS and S.JOBSTATUS = M.JOBSTATUS
                    join SNAME N on S.SKDID = N.SKDID
                    where N.SKDNAME = 'CHC-TICKETS-SEM'
					--substring(S.jobname,1,20) like 'TRC-TICKETS-%'
					and m.JOBSTATUS = 900


select * from JSTATMAP

select * from SNAME


select * from SMASTER where JOBNAME like 'TRC-TICKETS%'

select * from JMASTER where JOBNAME like 'TRC-TICKETS%'

select * from [dbo].[HISTORY]

select jobname, cast(JSTART-2 as datetime) START, 
                    cast(JTERM-2 as datetime) FIN, JRUN 
from [dbo].[HISTORY] 
where jobname like '%TRC-TICKETS%'
and JSTAT = 900

--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
--> Durées des traitements des TRC-TICKETS avant 8h
select jobname, cast(JSTART-2 as datetime) START, 
                    cast(JTERM-2 as datetime) FIN, JRUN 
from [dbo].[HISTORY] 
where jobname like '%TRC-TICKETS%'
and JSTAT = 900
and datepart(hh,cast(JSTART-2 as datetime)) < 8


--> Durées des traitements des TRC-TICKETS après 8h
select jobname, cast(JSTART-2 as datetime) START, 
                    cast(JTERM-2 as datetime) FIN, JRUN 
from [dbo].[HISTORY] 
where jobname like '%TRC-TICKETS%'
and JSTAT = 900
and datepart(hh,cast(JSTART-2 as datetime)) >= 8
