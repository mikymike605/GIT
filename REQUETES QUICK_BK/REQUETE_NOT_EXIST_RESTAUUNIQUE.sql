/************ENVOIE MAIL RESTAU MANQUANTS TABLE TICKET_UNIFIE_TAMPON vs TICKET_UNIFIE******************/

DECLARE @bodyMsg nvarchar(max)
DECLARE @subject nvarchar(max)
DECLARE @tableHTML nvarchar(max)
DECLARE @Table NVARCHAR(MAX) = N''
DECLARE @Table1 NVARCHAR(MAX) 
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




SET @tableHTML = 
N'<H><b>Bonjour,<BR></Ba.R></H></b>' + 
N'<H><b>Veuillez trouver ci dessous le tableau des restaurants manquants du <FONT COLOR="red" >'+cast (cast (dateadd(day, @loop, @deb) as date) as varchar)+' </FONT> dans la table TICKET_UNIFIE_TEMP apr&#232s chargements des donn&#233es.</b><BR></BR></H>' + 
N'<table border="5" cellpadding="5" cellspacing="5" style="color:Black;font-family:arial,calibri,italic;text-align:center;" >' +
N'<tr style ="color:Black;font-size: 16px;font-weight: normal;background: lightsteelblue;">
<td>RestaurantUniqueID</td>
<td>CommercialDate</td>
<td>Count</td></tr>' 
 + @Table +
N'</table>'


SET @tableHTML =  +@tableHTML +

 

            N'<H><BR></BR></H>' +

            N'<H><b>Merci d''analyser et r&#233soudre le probl&#232me d''int&#233grations LEEDEAL.</b><BR></BR></H>' +

            N'<H><b>Cordialement,</b><BR></BR></H>' +

            N'<H><b>Mikael H.</b></i></H>' ;



EXEC msdb.dbo.sp_send_dbmail
@profile_name= 'EnvoiMail',
@recipients= 'mikael.hamchaoui@bkqservices.com',
@subject = @subject,
@body = @tableHTML,
@body_format = 'HTML'
 ;


SET @loop = @loop +1

END 