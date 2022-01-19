/*******TRUNCATE TABLE AVANT CHARGEMENT DES DONNEES**********/

EXEC KINGSIDSQLPRD.[SID_PRD].sys.sp_executesql N'TRUNCATE TABLE [ODS].[TICKET_UNIFIE_TEMP]'

/*******INSERRT DES DONNEES DANS LA TABLE TAMPON**********/

declare @deb date = cast (getdate ()-3 as date)
DECLARE @fin date = cast (getdate ()-1 as date)
DECLARE @diff int = datediff(day, @deb, @fin)
PRINT @deb
PRINT @fin
DECLARE @loop int = 0
WHILE @loop <= @diff
BEGIN

DECLARE @restau varchar(250)
DECLARE Rest_Cursor CURSOR FOR  

SELECT RestaurantUniqueID
  FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT]
     WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
	 AND RestaurantUniqueID LIKE '8004%'
  ORDER BY RestaurantUniqueID  

OPEN Rest_Cursor  
		FETCH NEXT FROM Rest_Cursor INTO @restau 

WHILE @@FETCH_STATUS = 0
    BEGIN 
	PRINT @restau
	PRINT @loop
 
INSERT INTO KINGSIDSQLPRD.SID_PRD.[ODS].[TICKET_UNIFIE_TEMP]
([RestaurantCode],[RestaurantUniqueID],[InvoiceID],[InvoiceTransactionID],[CommercialDate],[CodePLU]
,[RevenueDate],[TITT_TaxeID],[Pays_seq],[CommercialMonth],[TI_OpenDate],[TI_CloseDate],[Periode]
,[CAT_RevenueCenterID],[InvoiceNumber],[FlagDeleted],[FlagPosted],[FlagTraining],[SID_PRODUCT]
,[ParentInvoiceTransactionID],[InCombo],[Quantity],[UnitPrice],[CA_Brut_TTC],[CA_BRut_TVA]
,[CA_Brut_HT],[Burst_CA_Brut_TTC],[Burst_CA_Brut_TVA],[Burst_CA_Brut_HT],[Disc_Count],[Disc_TTC]
,[Disc_TVA],[Disc_HT],[Burst_Disc_TTC],[Burst_Disc_TVA],[Burst_Disc_HT],[BPub_Count],[Bpub_TTC]
,[Bpub_TVA],[Bpub_HT],[BRepas_Count],[BRepas_TTC],[BRepas_TVA],[BRepas_HT],[VA_TTC],[VA_TVA],[VA_HT]
,[CA_Net_TTC],[CA_Net_TVA],[CA_Net_HT],[Burst_CA_Net_TTC],[Burst_CA_Net_TVA],[Burst_CA_Net_HT]
,[Foodcost],[IsMainCombo],[TI_IsVoidReopenCheck],[TI_OrderDateTime],[TI_SendDate],[TI_PrintDate]
,[TI_KitchenDate],[TI_TotalSales],[TI_ReferenceInvoiceID],[DWH_Process],[DT_INS],[DT_MAJ],[DT_SUP]
,[SOURCE],[FLAG_DAY_CLOSING],[Description])
SELECT 
[RestaurantCode],[RestaurantUniqueID],[InvoiceID],[InvoiceTransactionID],[CommercialDate],[CodePLU]
,[RevenueDate],[TITT_TaxeID],[Pays_seq],[CommercialMonth],[TI_OpenDate],[TI_CloseDate],[Periode]
,[CAT_RevenueCenterID],[InvoiceNumber],[FlagDeleted],[FlagPosted],[FlagTraining],[SID_PRODUCT]
,[ParentInvoiceTransactionID],[InCombo],[Quantity],[UnitPrice],[CA_Brut_TTC],[CA_BRut_TVA]
,[CA_Brut_HT],[Burst_CA_Brut_TTC],[Burst_CA_Brut_TVA],[Burst_CA_Brut_HT],[Disc_Count],[Disc_TTC]
,[Disc_TVA],[Disc_HT],[Burst_Disc_TTC],[Burst_Disc_TVA],[Burst_Disc_HT],[BPub_Count],[Bpub_TTC]
,[Bpub_TVA],[Bpub_HT],[BRepas_Count],[BRepas_TTC],[BRepas_TVA],[BRepas_HT],[VA_TTC],[VA_TVA],[VA_HT]
,[CA_Net_TTC],[CA_Net_TVA],[CA_Net_HT],[Burst_CA_Net_TTC],[Burst_CA_Net_TVA],[Burst_CA_Net_HT]
,[Foodcost],[IsMainCombo],[TI_IsVoidReopenCheck],[TI_OrderDateTime],[TI_SendDate],[TI_PrintDate]
,[TI_KitchenDate],[TI_TotalSales],[TI_ReferenceInvoiceID],[DWH_Process],[DT_INS],[DT_MAJ],[DT_SUP]
,[SOURCE],[FLAG_DAY_CLOSING],[Description]
FROM KINGSIDSQLPRD.SID_PRD.ODS.[TICKET_UNIFIE] with (nolock)
WHERE CommercialDate = '2019-04-02'
AND RestaurantUniqueID =80040146
ORDER BY RestaurantUniqueID

	FETCH  NEXT FROM Rest_Cursor INTO @restau 
	END
CLOSE Rest_Cursor;  
DEALLOCATE Rest_Cursor; 

SET @loop = @loop +1

END


/************ENVOIE MAIL COUNT RESTAU TABLE TICKET_UNIFIE_TAMPON vs TICKET_UNIFIE******************/
DECLARE @bodyMsg nvarchar(max)
DECLARE @subject nvarchar(max)
DECLARE @tableHTML nvarchar(max)
DECLARE @Table NVARCHAR(MAX) = N''
--DECLARE @deb date = cast (getdate ()-3 as date)
--DECLARE @fin date = cast (getdate ()-1 as date)


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
UNION ALL
SELECT 'PROD'[Table],
       CommercialDate,
       count (distinct RestaurantUniqueID) Compte_Restau,
       Count(*) Compte
FROM SID_PRD.ODS.[TICKET_UNIFIE]  with (nolock)
where CommercialDate between @deb and @fin
and RestaurantUniqueID like '8004%'
group by  CommercialDate
) t
order by CommercialDate



SET @tableHTML = 
N'<H><b>Bonjour,<BR></BR></H></b>' + 
N'<H><b>Veuillez trouver ci dessous le tableau des &#233carts du '+cast (cast (getdate() as date) as varchar)+'  entre la table TICKET_UNIFIE_TEMP et TICKET_UNIFIE après chargement.</b><BR></BR></H>' + 
N'<table border="1" cellpadding="2" cellspacing="2" style="color:Black;font-family:arial,calibri,italic;text-align:center;" >' +
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





/************ENVOIE MAIL RESTAU MANQUANTS TABLE TICKET_UNIFIE_TAMPON vs TICKET_UNIFIE******************/

DECLARE @bodyMsg1 nvarchar(max)
DECLARE @subject1 nvarchar(max)
DECLARE @tableHTML1 nvarchar(max)
DECLARE @Table1 NVARCHAR(MAX) = N''
DECLARE @deb1 date = cast (getdate ()-3 as date)
DECLARE @fin1 date = cast (getdate ()-1 as date)
DECLARE @diff1 int = datediff(day, @deb1, @fin1)
DECLARE @loop1 int = 0
while @loop1 <= @diff1
begin  

SET @subject1 =  'MONITORING DATA LEEDEAL'

SELECT  @Table1 =  @Table1 +'<td>' + convert (VARCHAR(30),Restaurantuniqueid,120)+ '</td>' +
'<td>' + CONVERT(VARCHAR(30),CommercialDate,120) + '</td>' +
'<td>' + CONVERT(VARCHAR(30),Count(*),120)+ '</td>' +
'</tr>'
FROM KINGSIDSQLPRD.SID_PRD.ODS.[TICKET_UNIFIE] a
where CommercialDate  = cast (dateadd(day, @loop1, @deb1) as date)
and RestaurantUniqueID like '80040%'
and not exists
( 
SELECT  + @Table1 +'<td>' + convert (VARCHAR(30),Restaurantuniqueid,120)+ '</td>' +
'<td>' + CONVERT(VARCHAR(30),CommercialDate,120) + '</td>' +
'<td>' + CONVERT(VARCHAR(30),Count(*),120)+ '</td>' +
'</tr>'
FROM KINGSIDSQLPRD.SID_PRD.ODS.[TICKET_UNIFIE_temp] b
  where CommercialDate = cast (dateadd(day, @loop1, @deb1) as date)
  and a.RestaurantUniqueID=b.RestaurantUniqueID 
and RestaurantUniqueID like '80040%'
group by RestaurantUniqueID,CommercialDate
)
group by  a.RestaurantUniqueID,CommercialDate
--order by 1



SET @tableHTML1 = 
N'<H><b>Bonjour,<BR></BR></H></b>' + 
N'<H><b>Veuillez trouver ci dessous le tableau des restaurants manquants du '+cast (cast (dateadd(day, @loop1, @deb1) as date) as varchar)+' dans la table TICKET_UNIFIE_TEMP apr&#232s chargements des donn&#233es.</b><BR></BR></H>' + 
N'<table border="1" cellpadding="2" cellspacing="2" style="color:Black;font-family:arial,calibri,italic;text-align:center;" >' +
N'<tr style ="color:Black;font-size: 16px;font-weight: normal;background: lightsteelblue;">
<td>RestaurantUniqueID</td>
<td>CommercialDate</td>
<td>Count</td></tr>' 
 + @Table1 + 
N'</table>' 

SET @tableHTML1 =+ @tableHTML1 + 
 

            N'<H><BR></BR></H>' +

            N'<H><b>Merci d''analyser et r&#233soudre le probl&#232me d''int&#233grations LEEDEAL.</b><BR></BR></H>' +

            N'<H><b>Cordialement,</b><BR></BR></H>' +

            N'<H><b>Mikael H.</b></i></H>' ;



EXEC msdb.dbo.sp_send_dbmail
@profile_name= 'EnvoiMail',
@recipients= 'mikael.hamchaoui@bkqservices.com',
@subject = @subject1,
@body = @tableHTML1,
@body_format = 'HTML' ;


SET @loop1 = @loop1 +1

END 




