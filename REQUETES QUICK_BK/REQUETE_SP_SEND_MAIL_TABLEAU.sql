DECLARE @bodyMsg nvarchar(max)
DECLARE @subject nvarchar(max)
DECLARE @tableHTML nvarchar(max)
DECLARE @Table NVARCHAR(MAX) = N''
DECLARE @deb date = cast (getdate ()-3 as date)
DECLARE @fin date = cast (getdate ()-1 as date)
DECLARE @diff int = datediff(day, @deb, @fin)
DECLARE @loop int = 0
while @loop <= @diff
begin  

SET @subject = 'MONITORING DATA LEEDEAL'

SELECT  @Table =  @Table +'<td>' + convert (VARCHAR(30),Restaurantuniqueid,120)+ '</td>' +
'<td>' + CONVERT(VARCHAR(30),CommercialDate,120) + '</td>' +
'<td>' + CONVERT(VARCHAR(30),Count(*),120)+ '</td>' +
'</tr>'
FROM kingsidsqlprd.SID_PRD.ODS.[TICKET_UNIFIE] a
where CommercialDate  = cast (dateadd(day, @loop, @deb) as date)
and RestaurantUniqueID like '80040%'
and not exists
( 
SELECT  + @Table +'<td>' + convert (VARCHAR(30),Restaurantuniqueid,120)+ '</td>' +
'<td>' + CONVERT(VARCHAR(30),CommercialDate,120) + '</td>' +
'<td>' + CONVERT(VARCHAR(30),Count(*),120)+ '</td>' +
'</tr>'
FROM kingsidsqlprd.SID_PRD.ODS.[TICKET_UNIFIE_temp] b
  where CommercialDate = cast (dateadd(day, @loop, @deb) as date)
  and a.RestaurantUniqueID=b.RestaurantUniqueID 
and RestaurantUniqueID like '80040%'
group by RestaurantUniqueID,CommercialDate
)
group by  a.RestaurantUniqueID,CommercialDate
--order by 1


SET @tableHTML = 
N'<H><b>Bonjour,<BR></BR></H></b>' + 
N'<H><b>Veuillez trouver ci dessous le tableau des restaurants manquants dans la table TICKET_UNIFIE_TEMP après chargements des donn&#233es.</b><BR></BR></H>' + 
N'<table border="1" cellpadding="2" cellspacing="2" style="color:Black;font-family:arial,calibri,italic;text-align:center;" >' +
N'<tr style ="color:Black;font-size: 14px;font-weight: bold;background: #B5B5B5;">
<th>Restaurantuniqueid</th>
<th>CommercialDate</th>
<th>Count</th></tr>' 
+ @Table + 
N'</table>' 

SET @tableHTML =+ @tableHTML + 
 

            N'<H><BR></BR></H>' +

            N'<H><b>Merci d''analyser et r&#233soudre le le probl&#232me d''int&#233grations LEEDEAL.</b><BR></BR></H>' +

            N'<H><b>Cordialement,</b><BR></BR></H>' +

            N'<H><b>Mikael H.</b></i></H>' ;



EXEC msdb.dbo.sp_send_dbmail
@profile_name= 'EnvoiMail',
@recipients= 'mikael.hamchaoui@bkqservices.com',
@subject = @subject,
@body = @tableHTML,
@body_format = 'HTML' ;


SET @loop = @loop +1

END 
