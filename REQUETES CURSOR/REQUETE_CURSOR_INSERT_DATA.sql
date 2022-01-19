 IF OBJECT_ID('tempdb..#cal') IS NOT NULL 
        DROP TABLE tempdb..#cal
		
DECLARE @deb date = getdate()-20
DECLARE  @fin date = getdate()-17 ;


with calendrier as 
(   select @deb date
    union all
    select DATEADD(day, 1, date)
    from calendrier
    where DATEADD(day, 1, date) <= @fin )

select date into #cal from calendrier
option(maxrecursion 0)
print @deb
print @fin
DECLARE @date varchar(250)
DECLARE Date_Cursor CURSOR FOR  
select * from #cal
OPEN Date_Cursor  
	FETCH NEXT FROM Date_Cursor INTO @date 
WHILE @@FETCH_STATUS = 0
    BEGIN 
	PRINT '***************'+@date+'***************'
	--PRINT @loop
	FETCH  NEXT FROM Date_Cursor INTO @date 
	END;  

	
DECLARE @restau varchar(250)
DECLARE Rest_Cursor CURSOR FOR  

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT distinct (bk)
  FROM SDBKQ067.AdminSQL.[dbo].[SHP_BK_SHAREPOINT_RESTAURANT]
  WHERE RestaurantUniqueID like '8004%' 
  ORDER BY BK  

OPEN Rest_Cursor  
		FETCH NEXT FROM Rest_Cursor INTO @restau 

WHILE @@FETCH_STATUS = 0
    BEGIN 
	--PRINT @restau
	FETCH  NEXT FROM Rest_Cursor INTO @restau 
------  /************ DELETE RESTAU PAR DATE ************/
------   --TRUNCATE TABLE [AdminSQL].[dbo].[TICKET_UNIFIE] --where CommercialDate > @deb and RestaurantCode=@restau 
------ --GROUP BY RestaurantCode
------ -- Having count(*) >1
------SELECT CommercialDate, RestaurantCode, count(*)
------ FROM [AdminSQL].[dbo].[TICKET_UNIFIE]
------  where CommercialDate > @date
------  and RestaurantCode = @restau
------  group by  CommercialDate,RestaurantCode
------  --HAving count(*) > 1
------  -- @date(CommercialDate), month (CommercialDate),day (CommercialDate)
------  --order by 1
  
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
 where CommercialDate = @date
and restaurantcode = @restau
order by restaurantcode

  PRINT '***************'+@date+'***************'
  PRINT @restau
      END;  
CLOSE Rest_Cursor;  
DEALLOCATE Rest_Cursor; 
     --END;  
	 --FETCH  NEXT FROM Date_Cursor INTO @date 
	 --END

CLOSE Date_Cursor;  
DEALLOCATE Date_Cursor; 

drop table #cal