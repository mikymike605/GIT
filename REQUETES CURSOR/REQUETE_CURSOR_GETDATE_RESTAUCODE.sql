declare @deb date = cast (getdate ()-19 as date)
declare @fin date = cast (getdate ()-15 as date)
declare @diff int = datediff(day, @deb, @fin)
PRINT @deb
PRINT @fin
declare @loop int = 0

while @loop <= @diff
begin
--SELECT CommercialDate, count (distinct(RestaurantUniqueID)), count(*)
--  FROM [AdminSQL].[dbo].[TICKET_UNIFIE]
--where CommercialDate = dateadd(day, @loop, @deb)
----and RestaurantUniqueID=''
--   group by  CommercialDate--year(CommercialDate), month (CommercialDate),day (CommercialDate)

--    order by 1


SET @loop = @loop +1

end

DECLARE @restau varchar(250)
DECLARE Rest_Cursor CURSOR FOR  

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT bk
  FROM AdminSQL.[dbo].[SHP_BK_SHAREPOINT_RESTAURANT]
     where FLAG_ACTIVE =1 and StatutValue like 'A.%'
	 and RestaurantUniqueID like '8004071%'
  ORDER BY BK  

OPEN Rest_Cursor  
		FETCH NEXT FROM Rest_Cursor INTO @restau 

WHILE @@FETCH_STATUS = 0
    BEGIN 
	PRINT @restau
	PRINT @loop
	FETCH  NEXT FROM Rest_Cursor INTO @restau 
  /************ DELETE RESTAU PAR DATE ************/
   --SELECT * FROM [AdminSQL].[dbo].[TICKET_UNIFIE]  where  CommercialDate = dateadd(day, @loop, @deb) --and RestaurantCode=@restau 
   --TRUNCATE TABLE [AdminSQL].[dbo].[TICKET_UNIFIE]
   --and RestaurantCode=@restau 
 /*
INSERT INTO SDBKQ067.AdminSQL.[dbo].[TICKET_UNIFIE]
([RestaurantCode],[RestaurantUniqueID],[InvoiceID]
,[InvoiceTransactionID],[CommercialDate],[CodePLU]
,[RevenueDate],[TITT_TaxeID],[Pays_seq],[CommercialMonth]
,[TI_OpenDate],[TI_CloseDate],[Periode],[CAT_RevenueCenterID]
,[InvoiceNumber],[FlagDeleted],[FlagPosted],[FlagTraining]
,[SID_PRODUCT],[ParentInvoiceTransactionID],[InCombo]
,[Quantity],[UnitPrice],[CA_Brut_TTC],[CA_BRut_TVA],[CA_Brut_HT]
,[Burst_CA_Brut_TTC],[Burst_CA_Brut_TVA],[Burst_CA_Brut_HT],[Disc_Count]
,[Disc_TTC],[Disc_TVA],[Disc_HT],[Burst_Disc_TTC],[Burst_Disc_TVA]
,[Burst_Disc_HT],[BPub_Count],[Bpub_TTC],[Bpub_TVA],[Bpub_HT],[BRepas_Count]
,[BRepas_TTC],[BRepas_TVA],[BRepas_HT],[VA_TTC],[VA_TVA],[VA_HT]
,[CA_Net_TTC],[CA_Net_TVA],[CA_Net_HT],[Burst_CA_Net_TTC],[Burst_CA_Net_TVA]
,[Burst_CA_Net_HT],[Foodcost],[IsMainCombo],[TI_IsVoidReopenCheck]
,[TI_OrderDateTime],[TI_SendDate],[TI_PrintDate],[TI_KitchenDate]
,[TI_TotalSales],[TI_ReferenceInvoiceID],[DWH_Process],[DT_INS]
,[DT_MAJ],[DT_SUP],[SOURCE],[FLAG_DAY_CLOSING],[Description])
SELECT 
[RestaurantCode],[RestaurantUniqueID],[InvoiceID]
,[InvoiceTransactionID],[CommercialDate],[CodePLU]
,[RevenueDate],[TITT_TaxeID],[Pays_seq],[CommercialMonth]
,[TI_OpenDate],[TI_CloseDate],[Periode],[CAT_RevenueCenterID]
,[InvoiceNumber],[FlagDeleted],[FlagPosted],[FlagTraining]
,[SID_PRODUCT],[ParentInvoiceTransactionID],[InCombo]
,[Quantity],[UnitPrice],[CA_Brut_TTC],[CA_BRut_TVA],[CA_Brut_HT]
,[Burst_CA_Brut_TTC],[Burst_CA_Brut_TVA],[Burst_CA_Brut_HT],[Disc_Count]
,[Disc_TTC],[Disc_TVA],[Disc_HT],[Burst_Disc_TTC],[Burst_Disc_TVA]
,[Burst_Disc_HT],[BPub_Count],[Bpub_TTC],[Bpub_TVA],[Bpub_HT],[BRepas_Count]
,[BRepas_TTC],[BRepas_TVA],[BRepas_HT],[VA_TTC],[VA_TVA],[VA_HT]
,[CA_Net_TTC],[CA_Net_TVA],[CA_Net_HT],[Burst_CA_Net_TTC],[Burst_CA_Net_TVA]
,[Burst_CA_Net_HT],[Foodcost],[IsMainCombo],[TI_IsVoidReopenCheck]
,[TI_OrderDateTime],[TI_SendDate],[TI_PrintDate],[TI_KitchenDate]
,[TI_TotalSales],[TI_ReferenceInvoiceID],[DWH_Process],[DT_INS]
,[DT_MAJ],[DT_SUP],[SOURCE],[FLAG_DAY_CLOSING],[Description]
FROM SID_PRD.ODS.[TICKET_UNIFIE]
--where commercialdate  between '20190221' and '20190224'
 where CommercialDate = cast (dateadd(day, @loop, @deb) as date)
and RestaurantUniqueID =@restau
order by RestaurantUniqueID
*/
--SELECT CommercialDate, RestaurantCode,RestaurantUniqueID, count(*)cont
-- FROM SDBKQ067.[AdminSQL].[dbo].[TICKET_UNIFIE]
----  where  CommercialDate = cast (dateadd(day, @loop, @deb) as date)
----and RestaurantCode=@restau   
--group by  CommercialDate,RestaurantCode,RestaurantUniqueID--year(CommercialDate), month (CommercialDate),day (CommercialDate)
--   Having count(*) >1
--  order by 1

      END;  
CLOSE Rest_Cursor;  
DEALLOCATE Rest_Cursor; 

--SET @loop = @loop +1

--end


