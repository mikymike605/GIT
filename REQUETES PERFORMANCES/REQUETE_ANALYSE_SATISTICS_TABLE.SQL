/*
/************ VERIFICATION NOMBRE RESTAU PAR DATE  ************/
SELECT year(CommercialDate), month (CommercialDate),day (CommercialDate), count (distinct(RestaurantUniqueID))
  FROM [AdminSQL].[dbo].[TICKET_UNIFIE]
  --where CommercialDate < '20190301'
  --where InvoiceID='1908739000545448076'
   --where CommercialDate < '20190301'
  group by  year(CommercialDate), month (CommercialDate),day (CommercialDate)
  order by 1,2,3
  
  /************ VERIFICATION NOMBRE RESTAU PAR DATE TABLE CIBLE ************/
SELECT  CommercialDate, count (distinct(RestaurantUniqueID)), count(*)
  --year(CommercialDate), month (CommercialDate),day (CommercialDate),
  FROM [SID_PRD].[ODS].[TICKET_UNIFIE]
  where RestaurantUniqueID like '8004%'
  and CommercialDate = '20190301'
  --where InvoiceID='1908739000545448076'
   --where CommercialDate < '20190301'
  group by  CommercialDate--year(CommercialDate), month (CommercialDate),day (CommercialDate)
  --order by 1

  /************ VERIFICATION NOMBRE RESTAU PAR DATE TABLE SOURCE ************/
SELECT  CommercialDate, count (distinct(RestaurantUniqueID)), count(*)
  --year(CommercialDate), month (CommercialDate),day (CommercialDate),
  FROM [SID_PRD].[ODS].[TICKET_UNIFIE_TEMP]
  where RestaurantUniqueID like '8004%'
  and CommercialDate = '20190301'
  --where InvoiceID='1908739000545448076'
   --where CommercialDate < '20190301'
  group by  CommercialDate--year(CommercialDate), month (CommercialDate),day (CommercialDate)
  --order by 1
 */ 

/************ DELETE RESTAU PAR DATE ************/
  --DELETE FROM [AdminSQL].[dbo].[TICKET_UNIFIE]
  --where CommercialDate between '20190221' and '20190225'

/************ INSERT INTO TABLE CURSOR************/
DECLARE @restau varchar(250)

DECLARE Rest_Cursor CURSOR FOR  

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT RestaurantUniqueID
  FROM SDBKQ067.AdminSQL.[dbo].[SHP_BK_SHAREPOINT_RESTAURANT]
     where FLAG_ACTIVE =1 and StatutValue like 'A.%'
	 and RestaurantUniqueID like '800407%'
  ORDER BY BK  
OPEN Rest_Cursor  
FETCH NEXT FROM Rest_Cursor INTO @restau 
WHILE @@FETCH_STATUS = 0
    BEGIN 
	PRINT @restau
	FETCH  NEXT FROM Rest_Cursor INTO @restau 
--OPEN Rest_Cursor
--FETCH NEXT FROM Rest_Cursor INTO @restau 
--WHILE @@FETCH_STATUS = 0  
   --BEGIN  
   --   FETCH NEXT FROM Rest_Cursor; 

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
 where CommercialDate between '20190301' and '20190319'
and RestaurantUniqueID =@restau
order by RestaurantUniqueID

   END;  
CLOSE Rest_Cursor;  
DEALLOCATE Rest_Cursor;  
--END


/*
declare @deb date = cast (getdate ()-20 as date)
declare @fin date = cast (getdate ()-13 as date)
declare @diff int = datediff(day, @deb, @fin)
--PRINT @deb
--PRINT @fin
declare @loop int = 0

while @loop <= @diff
begin

--SELECT CommercialDate, count (distinct(RestaurantUniqueID)), count(*)
-- FROM [AdminSQL].[dbo].[TICKET_UNIFIE]
--where CommercialDate = dateadd(day, @loop, @deb)
--and RestaurantUniqueID=''
--   group by  CommercialDate--year(CommercialDate), month (CommercialDate),day (CommercialDate)
--  order by 1


DECLARE @restau varchar(250)
DECLARE Rest_Cursor CURSOR FOR  

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT distinct (bk)
  FROM AdminSQL.[dbo].[SHP_BK_SHAREPOINT_RESTAURANT]
  WHERE RestaurantUniqueID = '80040010' 
  ORDER BY BK  

OPEN Rest_Cursor  
		FETCH NEXT FROM Rest_Cursor INTO @restau 

WHILE @@FETCH_STATUS = 0
    BEGIN 
	PRINT @restau
	PRINT @loop
	FETCH  NEXT FROM Rest_Cursor INTO @restau 
  /************ DELETE RESTAU PAR DATE ************/
   DELETE FROM [AdminSQL].[dbo].[TICKET_UNIFIE] where CommercialDate =dateadd(day, @loop, @deb) and RestaurantCode=@restau 
  Having count(*) >1
  GROUP BY RestaurantCode
  --Having count(*) >1
--SELECT CommercialDate, count (distinct(RestaurantUniqueID)), count(*)
--FROM [AdminSQL].[dbo].[TICKET_UNIFIE]
--   where  CommercialDate = dateadd(day, @loop, @deb)
--   and RestaurantCode=@restau 
--   group by  CommercialDate--year(CommercialDate), month (CommercialDate),day (CommercialDate)
--   order by 1

      END;  
CLOSE Rest_Cursor;  
DEALLOCATE Rest_Cursor; 

SET @loop = @loop +1

end

/************ SELECT TABLE STATISTICS************/
SET STATISTICS IO, TIME ON

SELECT  RestaurantCode, RestaurantUniqueID, InvoiceID, 
InvoiceTransactionID, CommercialDate, TI_OpenDate, 
TI_CloseDate, CAT_RevenueCenterID, InvoiceNumber, 
FlagDeleted, FlagPosted, CodePLU, Description, 
TITT_TaxeID, ParentInvoiceTransactionID, InCombo,  
IsMainCombo, Quantity, UnitPrice, CA_Brut_TTC, 
CA_BRut_TVA, CA_Brut_HT, Burst_CA_Brut_TTC, 
Burst_CA_Brut_TVA, Burst_CA_Brut_HT, Disc_Count, 
Disc_TTC, Disc_TVA, Disc_HT, Burst_Disc_TTC, 
Burst_Disc_TVA, Burst_Disc_HT, BPub_Count, 
Bpub_TTC, Bpub_TVA, Bpub_HT, BRepas_Count, 
BRepas_TTC, BRepas_TVA, BRepas_HT, 
VA_TTC, VA_TVA, VA_HT, CA_Net_TTC, CA_Net_TVA, 
CA_Net_HT, Burst_CA_Net_TTC, Burst_CA_Net_TVA, 
Burst_CA_Net_HT, Foodcost, TI_ReferenceInvoiceID
     FROM dbo.[TICKET_UNIFIE]
where commercialdate = '20190301'
and RestaurantUniqueID = '80040711'

SET STATISTICS IO, TIME OFF


/************ CREATION INDEX 1 COMMERCIALDATE ************/
/*
USE [AdminSQL]
GO
CREATE NONCLUSTERED INDEX  [IX_CommercialDate_Include] ON [dbo].[TICKET_UNIFIE]
 ([CommercialDate])
INCLUDE ([RestaurantCode],[RestaurantUniqueID],[InvoiceID],
[InvoiceTransactionID],[CodePLU],[TITT_TaxeID],[TI_OpenDate],[TI_CloseDate],
[CAT_RevenueCenterID],[InvoiceNumber],[FlagDeleted],[FlagPosted],
[ParentInvoiceTransactionID],[InCombo],[Quantity],[UnitPrice],
[CA_Brut_TTC],[CA_BRut_TVA],[CA_Brut_HT],[Burst_CA_Brut_TTC],
[Burst_CA_Brut_TVA],[Burst_CA_Brut_HT],[Disc_Count],[Disc_TTC],
[Disc_TVA],[Disc_HT],[Burst_Disc_TTC],[Burst_Disc_TVA],[Burst_Disc_HT],
[BPub_Count],[Bpub_TTC],[Bpub_TVA],[Bpub_HT],[BRepas_Count],[BRepas_TTC],
[BRepas_TVA],[BRepas_HT],[VA_TTC],[VA_TVA],[VA_HT],[CA_Net_TTC],[CA_Net_TVA],
[CA_Net_HT],[Burst_CA_Net_TTC],[Burst_CA_Net_TVA],[Burst_CA_Net_HT],[Foodcost],
[IsMainCombo],[TI_ReferenceInvoiceID],[Description])
GO
*/


/************ CREATION INDEX 2 RESTAURANTUNIQUEID_COMMERCIALDATE ************/

/*
CREATE NONCLUSTERED INDEX [IX_RESTAURANTCODEUNIQUEID_COMMERCIALDATE_INCLUDE] ON [dbo].[TICKET_UNIFIE]
(
	[RestaurantUniqueID] ASC,
	[CommercialDate] ASC
)INCLUDE ([RestaurantCode],[InvoiceID],
[InvoiceTransactionID],[CodePLU],[TITT_TaxeID],[TI_OpenDate],[TI_CloseDate],
[CAT_RevenueCenterID],[InvoiceNumber],[FlagDeleted],[FlagPosted],
[ParentInvoiceTransactionID],[InCombo],[Quantity],[UnitPrice],
[CA_Brut_TTC],[CA_BRut_TVA],[CA_Brut_HT],[Burst_CA_Brut_TTC],
[Burst_CA_Brut_TVA],[Burst_CA_Brut_HT],[Disc_Count],[Disc_TTC],
[Disc_TVA],[Disc_HT],[Burst_Disc_TTC],[Burst_Disc_TVA],[Burst_Disc_HT],
[BPub_Count],[Bpub_TTC],[Bpub_TVA],[Bpub_HT],[BRepas_Count],[BRepas_TTC],
[BRepas_TVA],[BRepas_HT],[VA_TTC],[VA_TVA],[VA_HT],[CA_Net_TTC],[CA_Net_TVA],
[CA_Net_HT],[Burst_CA_Net_TTC],[Burst_CA_Net_TVA],[Burst_CA_Net_HT],[Foodcost],
[IsMainCombo],[TI_ReferenceInvoiceID],[Description])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

*/




/*
 ------------------------------------------Sans l'index ----------------------------------------------------------------------

 SET STATISTICS IO, TIME ON

SELECT RestaurantCode, RestaurantUniqueID, InvoiceID, 
InvoiceTransactionID, CommercialDate, TI_OpenDate, 
TI_CloseDate, CAT_RevenueCenterID, InvoiceNumber, 
FlagDeleted, FlagPosted, CodePLU, Description, 
TITT_TaxeID, ParentInvoiceTransactionID, InCombo,  
IsMainCombo, Quantity, UnitPrice, CA_Brut_TTC, 
CA_BRut_TVA, CA_Brut_HT, Burst_CA_Brut_TTC, 
Burst_CA_Brut_TVA, Burst_CA_Brut_HT, Disc_Count, 
Disc_TTC, Disc_TVA, Disc_HT, Burst_Disc_TTC, 
Burst_Disc_TVA, Burst_Disc_HT, BPub_Count, 
Bpub_TTC, Bpub_TVA, Bpub_HT, BRepas_Count, 
BRepas_TTC, BRepas_TVA, BRepas_HT, 
VA_TTC, VA_TVA, VA_HT, CA_Net_TTC, CA_Net_TVA, 
CA_Net_HT, Burst_CA_Net_TTC, Burst_CA_Net_TVA, 
Burst_CA_Net_HT, Foodcost, TI_ReferenceInvoiceID
FROM [SID_PRD].[ODS].[TICKET_UNIFIE]
  where CommercialDate='2019-01-15'

SET STATISTICS IO, TIME OFF


 /*SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

(143213 row(s) affected)
Table 'TICKET_UNIFIE'. Scan count 5, logical reads 629680, physical reads 1295, read-ahead reads 503, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

(1 row(s) affected)

 SQL Server Execution Times:
   CPU time = 1968 ms,  elapsed time = 4552 ms.
*/
 ------------------------------------------Avec l'index ----------------------------------------------------------------------

SET STATISTICS IO, TIME ON

SELECT RestaurantCode, RestaurantUniqueID, InvoiceID, 
InvoiceTransactionID, CommercialDate, TI_OpenDate, 
TI_CloseDate, CAT_RevenueCenterID, InvoiceNumber, 
FlagDeleted, FlagPosted, CodePLU, 
Description, TITT_TaxeID, ParentInvoiceTransactionID, 
InCombo,  IsMainCombo, Quantity, UnitPrice, 
CA_Brut_TTC, CA_BRut_TVA, CA_Brut_HT, 
Burst_CA_Brut_TTC, Burst_CA_Brut_TVA, Burst_CA_Brut_HT, 
Disc_Count, Disc_TTC, Disc_TVA, Disc_HT, 
Burst_Disc_TTC, Burst_Disc_TVA, Burst_Disc_HT, 
BPub_Count, Bpub_TTC, Bpub_TVA,
 Bpub_HT, BRepas_Count, BRepas_TTC, 
BRepas_TVA, BRepas_HT, VA_TTC, 
VA_TVA, VA_HT, CA_Net_TTC, CA_Net_TVA, 
CA_Net_HT, Burst_CA_Net_TTC, Burst_CA_Net_TVA, 
Burst_CA_Net_HT, Foodcost, TI_ReferenceInvoiceID
FROM [SID_PRD].[ODS].[TICKET_UNIFIE]
  where CommercialDate='2019-01-15'
  --and RestaurantUniqueID='20040180'

SET STATISTICS IO, TIME OFF

/*
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 4 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

(143213 row(s) affected)
Table 'TICKET_UNIFIE'. Scan count 1, logical reads 7610, physical reads 0, read-ahead reads 7583, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

(1 row(s) affected)

 SQL Server Execution Times:
   CPU time = 250 ms,  elapsed time = 4247 ms.
 */

 
/*
CREATE NONCLUSTERED INDEX [IX_TICKET_UNIFIE_COMMERCIALDATE_INCLUDE] ON [ODS].[TICKET_UNIFIE]
(
	[CommercialDate] ASC
)
INCLUDE ( 	[RestaurantCode],	[RestaurantUniqueID],	[InvoiceID],
	[InvoiceTransactionID],	[CodePLU],	[TITT_TaxeID],
	[TI_OpenDate],	[TI_CloseDate],	[CAT_RevenueCenterID],
	[InvoiceNumber],	[FlagDeleted],	[FlagPosted],
	[ParentInvoiceTransactionID],	[InCombo],	[Quantity],
	[UnitPrice],	[CA_Brut_TTC],	[CA_BRut_TVA],	[CA_Brut_HT],
	[Burst_CA_Brut_TTC],	[Burst_CA_Brut_TVA],	[Burst_CA_Brut_HT],
	[Disc_Count],	[Disc_TTC],	[Disc_TVA],
	[Disc_HT],	[Burst_Disc_TTC],	[Burst_Disc_TVA],
	[Burst_Disc_HT],	[BPub_Count],	[Bpub_TTC],
	[Bpub_TVA],	[Bpub_HT],	[BRepas_Count],
	[BRepas_TTC],	[BRepas_TVA],	[BRepas_HT],
	[VA_TTC],	[VA_TVA],	[VA_HT],
	[CA_Net_TTC],	[CA_Net_TVA],	[CA_Net_HT],
	[Burst_CA_Net_TTC],	[Burst_CA_Net_TVA],	[Burst_CA_Net_HT],
	[Foodcost],	[IsMainCombo],	[TI_ReferenceInvoiceID],
	[Description]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = ON, 
	ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)
GO
*/
/*

CREATE NONCLUSTERED INDEX [IX_DATE_ID_UNIQUE] ON [dbo].[TICKET_UNIFIE]
(
	[CommercialDate] ASC
)
INCLUDE ( 	[RestaurantUniqueID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [NonClusteredIndex-20190307-152412] ON [dbo].[TICKET_UNIFIE]
(
	[RestaurantCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO



*/
