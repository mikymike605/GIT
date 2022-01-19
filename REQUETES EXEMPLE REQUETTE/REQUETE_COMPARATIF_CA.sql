DECLARE @debut_date		datetime
DECLARE @fin_date		datetime


SELECT @debut_date = getdate()-2
SELECT @fin_date = getdate()-1 


CREATE TABLE #Coherance_donnees_MDBridge
(	CommercialDate_0	Date,
	RestaurantCode_0	int,
	CA_NET_TTC_0		money
)

CREATE TABLE #Coherance_donnees_CDV_TAXE
(	CommercialDate_1	Date,
	RestaurantCode_1	int,
	CA_NET_TTC_1		money
)

CREATE TABLE #Coherance_donnees_ODS_TICKET
(	CommercialDate_2		Date,
	RestaurantCode_2		int,
	CA_NET_TTC_2			money,
	CA_NET_TTC_Training_2	money
)

CREATE TABLE #Coherance_donnees_F_PRODUCT
(	CommercialDate_3		Date,
	RestaurantCode_3		int,
	CA_NET_TTC_3			money
)

CREATE TABLE #Coherance_donnees_F_RESTAURANT
(	CommercialDate_4				Date,
	RestaurantCode_4			int,
	CA_NET_TTC_4		money
)


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------MDBridge-----------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO #Coherance_donnees_MDBridge
SELECT CAST(FISCALDATE AS DATE) AS [DATE]
,restaurantcode 
, SUM (TOTAL)
FROM VILFRMDBRIDGE.QUICKMDCUBE_FR.DBO.MDINVOICE
  WHERE FISCALDATE BETWEEN @debut_date and @fin_date
  GROUP BY FISCALDATE, restaurantcode

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------CA_Rest_Jour_CDV_Taxe-----------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT #Coherance_donnees_CDV_TAXE
SELECT CAST(CommercialDate AS DATE) AS [DATE]
	 , Id_Restaurant - 20040000+1000 as RestaurantCode
	 , SUM(CA_NET_TTC) AS [CA_NET_TTC]
FROM [ODS].[dbo].[CA_Rest_Jour_CDV_Taxe] with (nolock)
WHERE Id_Restaurant LIKE '20040%'
AND CommercialDate BETWEEN @debut_date and @fin_date
GROUP BY CommercialDate, Id_Restaurant
  

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------ODS_TICKET-----------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT #Coherance_donnees_ODS_TICKET
SELECT CAST(CommercialDate AS DATE) AS [DATE]
	 , RestaurantUniqueID - 20040000+1000 as RestaurantCode
	 , SUM(CASE WHEN (FlagDeleted = 1 OR FlagPosted = 0 OR FlagTraining = 1)THEN 0 ELSE CA_Net_TTC END) AS [CA NET TTC]
	 , SUM(CASE WHEN (FlagDeleted = 1 OR FlagPosted = 0 OR FlagTraining = 1)THEN CA_Net_TTC ELSE 0 END) AS [CA NET TTC Training]
FROM ODS.dbo.ODS_Ticket_Unifie Ticket with (nolock)
WHERE CommercialDate between @debut_date and @fin_date
and RestaurantUniqueID  LIKE '20040%'
GROUP BY RestaurantUniqueID, CommercialDate

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------F_RESTAURANT-----------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT #Coherance_donnees_F_RESTAURANT
SELECT SID_DATE AS [DATE]
	  ,ID_UNIQUE_RESTAURANT - 20040000+1000 as RestaurantCode
	  ,SUM(TOT_NET_REVENUE_TTC) AS [CA NET TTC]
FROM [DWH_COM].[dbo].[F_RESTAURANT] with (nolock)
WHERE SID_DATE BETWEEN '20160101' and '20160131'
AND ID_UNIQUE_RESTAURANT LIKE '20040%'
--and ID_UNIQUE_RESTAURANT ='20040216'
GROUP BY SID_DATE, ID_UNIQUE_RESTAURANT


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------CREATION TABLE-----------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT a.CommercialDate_1 AS CommercialDate_1
	  ,a.RestaurantCode_1 AS RestaurantCode_1
	  ,a.CA_NET_TTC_1 AS CA_NET_CDV_TAXE
	  ,b.CommercialDate_3 AS CommercialDate_3
	  ,b.RestaurantCode_3 AS RestaurantCode_3
	  ,b.CA_NET_TTC_3 AS CA_NET_F_RESTAURANT
	  ,c.CommercialDate_4 AS CommercialDate_4
	  ,c.RestaurantCode_4 AS RestaurantCode_4
	  ,c.CA_NET_TTC_4 AS CA_NET_ODS_TICKET
	  ,d.CommercialDate_2 AS CommercialDate_2
	  ,d.RestaurantCode_2 AS RestaurantCode_2
	  ,d.CA_NET_TTC_2 AS CA_NET_F_PRODUCT 
	  ,E.CommercialDate_0 AS CommercialDate_5
	  ,E.RestaurantCode_0 AS RestaurantCode_5
	  ,E.CA_NET_TTC_0 AS CA_NET_MDBRIDGE
	  ,(a.CA_NET_TTC_1- b.CA_NET_TTC_3-c.CA_NET_TTC_4-d.CA_NET_TTC_2-e.CA_NET_TTC_0 + a.CA_NET_TTC_1+ b.CA_NET_TTC_3+c.CA_NET_TTC_4+d.CA_NET_TTC_2+e.CA_NET_TTC_0) as Total
FROM #Coherance_donnees_CDV_TAXE A
left join #Coherance_donnees_F_PRODUCT B
on A.Restaurantcode_1=B.RestaurantCode_3
left join #Coherance_donnees_F_RESTAURANT C
on A.Restaurantcode_1=C.RestaurantCode_4
left join #Coherance_donnees_ODS_TICKET D
on A.RestaurantCode_1=D.RestaurantCode_2
left join #Coherance_donnees_MDBridge E
on A.RestaurantCode_1=E.RestaurantCode_0
--where (a.CA_NET_TTC_1- b.CA_NET_TTC_3-c.CA_NET_TTC_4-d.CA_NET_TTC_2-e.CA_NET_TTC_0 + a.CA_NET_TTC_1+ b.CA_NET_TTC_3+c.CA_NET_TTC_4+d.CA_NET_TTC_2+e.CA_NET_TTC_0) >1
ORDER BY 2

DROP TABLE #Coherance_donnees_CDV_TAXE

DROP TABLE #Coherance_donnees_F_PRODUCT

DROP TABLE #Coherance_donnees_F_RESTAURANT

DROP TABLE #Coherance_donnees_ODS_TICKET

DROP TABLE #Coherance_donnees_MDBridge

