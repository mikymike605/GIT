  DECLARE @body varchar (max) 
  set @body =	N'<H><b>Bonjour</b><BR></BR></H>' +
	N'<H><b>Veuillez trouver ci-joint les rapports de monitoring quotidien </b> <BR></BR></H>' +
	N'		<H><i>JobCountByStartDate = Nombres de Jobs par jour <BR></BR></H>' +
	N'		<H><i>SchedulesCountFailedByMonth = Nombres de Jobs echoues par mois <BR></BR></H>' +
	N'		<H><i>SchedulesCountOKByMonth = Nombres de Jobs ok par mois <BR></BR></H>' +
	N'<table border="0" cellspacing="1" cellpadding="1">'+
	N'<H><b>Cordialement,<BR></BR></H>' +
	N'<H>Mikael H.</b></H>' ;

	select spid, blocked, waittype, waittime, lastwaittype, dbid, uid, cpu, physical_io, memusage, login_time,last_batch, hostname, program_name, nt_domain, nt_username, loginame from master..sysprocesses where blocked <> 0 and waittime > 60000 or spid in (select blocked from master..sysprocesses)
IF @@ROWCouNT>= 1
BEGIN
  exec msdb.dbo.sp_send_dbmail
    @recipients=N'Mikael.HAMCHAOUI@bkqservices.com',
    @body= @body, 
    @subject = 'Process Blocked',
    @body_format = 'HTML',
    @profile_name ='EnvoiMail',
	@query= 'select spid, blocked, waittype, waittime, lastwaittype, dbid, uid, cpu, physical_io, memusage, login_time,last_batch, hostname, program_name, nt_domain, nt_username, loginame from master..sysprocesses where blocked <> 0 and waittime > 60000 or spid in (select blocked from master..sysprocesses)'

	END


	select spid, blocked, waittype, waittime, lastwaittype, dbid, uid, cpu, physical_io, memusage, login_time, 
last_batch, hostname, program_name, nt_domain, nt_username, loginame 
from master..sysprocesses where blocked <> 0 and waittime > 60000 or spid in (select blocked from master..sysprocesses)
IF @@ROWCouNT>= 1


BEGIN
EXEC msdb.dbo.sp_send_dbmail
@profile_name= 'EnvoiMail',
@recipients= 'mikael.hamchaoui@bkqservices.com',
@subject= 'TEST',
@query= 'DECLARE @tableHTML  NVARCHAR(MAX) ;  
  declare @deb date = cast (getdate ()-3 as date)
declare @fin date = cast (getdate ()-1 as date)
declare @diff int = datediff(day, @deb, @fin)
PRINT @deb
PRINT @fin
declare @loop int = 0
while @loop <= @diff
begin  

SELECT   distinct(RestaurantUniqueID)RestaurantUniqueID,CommercialDate, count(*)count
FROM SID_PRD.ODS.[TICKET_UNIFIE] a
 where CommercialDate = cast (dateadd(day, @loop, @deb) as date)
and RestaurantUniqueID like ''80040%''
and not exists
( 
SELECT  distinct(RestaurantUniqueID)RestaurantUniqueID,CommercialDate, count(*)count
FROM SID_PRD.ODS.[TICKET_UNIFIE_temp] b
  where CommercialDate = cast (dateadd(day, @loop, @deb) as date)and a.RestaurantUniqueID=b.RestaurantUniqueID 
and RestaurantUniqueID like ''80040%''
group by RestaurantUniqueID,CommercialDate
)
group by  a.RestaurantUniqueID,CommercialDate
--order by 1

SET @loop = @loop +1

end'
END 


