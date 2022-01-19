/************ENVOIE MAIL COUNT RESTAU TABLE TICKET_UNIFIE_TAMPON vs TICKET_UNIFIE******************/
DECLARE @bodyMsg nvarchar(max)
DECLARE @subject nvarchar(max)
DECLARE @tableHTML nvarchar(max)
DECLARE @Table NVARCHAR(MAX) = N''
DECLARE @deb date = cast (getdate ()-3 as date)
DECLARE @fin date = cast (getdate ()-1 as date)

--DELETE FROM SID_PRD.ODS.[TICKET_UNIFIE_TEMP] where RestaurantUniqueID='80040001' and CommercialDate='20190327'
SET @subject = 'MONITORING COUNT RESTAU LEEDEAL'

SELECT @Table =  @Table +'<td>' +[Table]+ '</td>'+
'<td>' + CONVERT(VARCHAR(30),CommercialDate,120) + '</td>' +
'<td>' + convert (VARCHAR(30),Compte_Restau,120)+ '</td>' +
'<td>' + CONVERT(VARCHAR(30),Compte,120)+ '</td>' +
'</tr>'
FROM (
select'TEMP' [Table],
       CommercialDate,
       count (distinct RestaurantUniqueID) Compte_Restau,
       Count(*) Compte
from SID_PRD.ODS.[TICKET_UNIFIE_TEMP] with (nolock)
--where CommercialDate = dateadd(day, @loop, @deb)
--where RestaurantUniqueID='80040920'
group by  CommercialDate--,t.RestaurantUniqueID,s.RestaurantUniqueID--year(CommercialDate), month (CommercialDate),day (CommercialDate)
--order by CommercialDate
 UNION 
SELECT 'PROD'[Table],
       CommercialDate,
       count (distinct RestaurantUniqueID) Compte_Restau,
       Count(*) Compte
FROM SID_PRD.ODS.[TICKET_UNIFIE]  with (nolock)
where CommercialDate between @deb and @fin
and RestaurantUniqueID like '80040%'
group by  CommercialDate
) t

order by CommercialDate,[Table]


SET @tableHTML = 
N'<H><b>Bonjour,<BR></BR></H></b>' + 
N'<H><b>Veuillez trouver ci dessous le tableau des &#233carts du <FONT COLOR="red" >'+cast (cast (getdate() as date) as varchar)+'  </FONT> entre la table TICKET_UNIFIE_TEMP et TICKET_UNIFIE après chargement.</b><BR></BR></H>' + 
N'<table border="5" cellpadding="5" cellspacing="5" style="color:Black;font-family:arial,calibri,italic;text-align:center;" >' +
N'<tr style ="color:Black;font-size: 16px;font-weight: normal;background: lightsteelblue;">
<td>Server</td>
<td>CommercialDate</td>
<td>RestaurantUniqueID</td>
<td>Count</td></tr>' 
+ @Table + 
N'</table>' 

--print @tableHTML

SET @tableHTML =+ @tableHTML + 



            N'<H><BR></BR></H>' +

            N'<H><b>Merci d''analyser et r&#233soudre le probl&#232me d''int&#233grations LEEDEAL.</b><BR></BR></H>' +

            N'<H><b>Cordialement,</b><BR></BR></H>' +

            N'<H><b>Mikael H.</b></i></H>' ;


--PRINT @table
EXEC msdb.dbo.sp_send_dbmail
@profile_name= 'EnvoiMail',
@recipients= 'mikael.hamchaoui@bkqservices.com',
@subject = @subject,
@body = @tableHTML,
@body_format = 'HTML' ;





