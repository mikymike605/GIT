
/*******INSERRT DES DONNEES DANS LA TABLE TAMPON**********/

DECLARE @deb date = cast (getdate ()-3 as date)
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
	 AND RestaurantUniqueID LIKE '80040%'
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
WHERE CommercialDate = cast (dateadd(day, @loop, @deb) as date)
AND RestaurantUniqueID =@restau
ORDER BY RestaurantUniqueID

	FETCH  NEXT FROM Rest_Cursor INTO @restau 
	END
CLOSE Rest_Cursor;  
DEALLOCATE Rest_Cursor; 

SET @loop = @loop +1

END

