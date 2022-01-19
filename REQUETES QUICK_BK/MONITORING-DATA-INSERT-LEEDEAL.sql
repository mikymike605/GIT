/************ENVOIE MAIL RESTAU MANQUANTS TABLE TICKET_UNIFIE_TAMPON vs TICKET_UNIFIE******************/

DECLARE @bodyMsg nvarchar(max)
DECLARE @subject nvarchar(max)
DECLARE @tableHTML nvarchar(max)
DECLARE @tableHTML1 nvarchar(max)
DECLARE @Table NVARCHAR(MAX) = N''
DECLARE @deb date = cast (getdate ()-3 as date)
DECLARE @fin date = cast (getdate ()-1 as date)
DECLARE @diff int = datediff(day, @deb, @fin)
DECLARE @loop int = 0
while @loop <= @diff
begin  

SET @subject =  'MONITORING DATA LEEDEAL'

SELECT  @Table =  @Table +'<td>' + convert (VARCHAR(30),Restaurantuniqueid,120)+ '</td>' +
'<td>' + CONVERT(VARCHAR(30),CommercialDate,120) + '</td>' +
'<td>' + CONVERT(VARCHAR(30),Count(*),120)+ '</td>' +
'</tr>'
FROM KINGSIDSQLPRD.SID_PRD.ODS.[TICKET_UNIFIE] a
where CommercialDate  = cast (dateadd(day, @loop, @deb) as date)
and RestaurantUniqueID like '80040%'
and not exists
( 
SELECT  + @Table +'<td>' + convert (VARCHAR(30),Restaurantuniqueid,120)+ '</td>' +
'<td>' + CONVERT(VARCHAR(30),CommercialDate,120) + '</td>' +
'<td>' + CONVERT(VARCHAR(30),Count(*),120)+ '</td>' +
'</tr>'
FROM KINGSIDSQLPRD.SID_PRD.ODS.[TICKET_UNIFIE_temp] b
  where CommercialDate = cast (dateadd(day, @loop, @deb) as date)
  and a.RestaurantUniqueID=b.RestaurantUniqueID 
and RestaurantUniqueID like '80040%'
group by RestaurantUniqueID,CommercialDate
)
group by  a.RestaurantUniqueID,CommercialDate
--order by 1

--SET @subject =  'MONITORING DATA LEEDEAL'
DECLARE @rowcount int 
SET @rowcount=(
SELECT
Count(*)
FROM KINGSIDSQLPRD.SID_PRD.ODS.[TICKET_UNIFIE] a
where CommercialDate  = cast (dateadd(day, @loop, @deb) as date)
and RestaurantUniqueID like '80040%'
and not exists
( 
SELECT
Count(*)
FROM KINGSIDSQLPRD.SID_PRD.ODS.[TICKET_UNIFIE_temp] b
  where CommercialDate = cast (dateadd(day, @loop, @deb) as date)
  and a.RestaurantUniqueID=b.RestaurantUniqueID 
and RestaurantUniqueID like '80040%'
group by RestaurantUniqueID,CommercialDate
))
print @rowcount 

SET @tableHTML = 
N'<H><b>Bonjour,<BR></BR></H></b>' + 
N'<H><b>Veuillez trouver ci dessous le tableau des restaurants manquants du '+CONVERT(VARCHAR(30), (cast (dateadd(day, @loop, @deb) as date)), 103)+' dans la table TICKET_UNIFIE_TEMP apr&#232s chargements des donn&#233es.</b><BR></BR></H>' + 
N'<table border="1" cellpadding="2" cellspacing="2" style="color:Black;font-family:arial,calibri,italic;text-align:center;" >' +
N'<tr style ="color:Black;font-size: 16px;font-weight: normal;background: lightsteelblue;">
<td>RestaurantUniqueID</td>
<td>CommercialDate</td>
<td>Count</td></tr>' 
 + @Table + 
N'</table>' 

SET @tableHTML =+ @tableHTML + 
 

            N'<H><BR></BR></H>' +

            N'<H><b>Merci d''analyser et r&#233soudre le probl&#232me d''int&#233grations LEADEAL.</b><BR></BR></H>' +

            N'<H><b>Cordialement,</b><BR></BR></H>' +

            N'<H><b>Mikael H.</b></i></H>' ;


IF @rowcount > 0
BEGIN
  EXEC msdb.dbo.sp_send_dbmail
@profile_name= 'EnvoiMail',
@recipients= 'mikael.hamchaoui@bkqservices.com',
@subject = @subject,
@body = @tableHTML,
@body_format = 'HTML' ;
--EXEC msdb.dbo.sp_send_dbmail
----@from_address='fichiers@quick.fr',
--@recipients= 'mikael.hamchaoui@bkqservices.com',
--@subject = @strsubject,
--@body = @tableHTML,
--@body_format = 'HTML',
--@profile_name='EnvoiMail'
 
 
END --IF
else
SET @tableHTML1 = '<H><BODY <font size ="4" color="#000000"> Bonjour,<BR></BR></H></font>
<BODY <font size = "4"color="#000000"<H>Il n''y a pas de manquant LEADEAL pour le '+CONVERT(VARCHAR(30), (cast (dateadd(day, @loop, @deb) as date)), 103)+'.<BR></BR></H></tr></font>
<H><BODY <font size ="4"color="#000000"> Cordialement.</H>
<H><BODY <font size ="4" color="#000000"> Mikael H. </H></font>' 
begin
EXEC msdb.dbo.sp_send_dbmail
--@from_address='fichiers@quick.fr',
@recipients= 'mikael.hamchaoui@bkqservices.com',
@subject = @subject,
@body =@tableHTML1,
@body_format = 'HTML',
@profile_name='EnvoiMail'
 

End
--End

--drop table #SQL_Log_Errors
 





SET @loop = @loop +1

END 
go