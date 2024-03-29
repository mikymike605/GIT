--DECLARE @exec int set @exec=999
--IF @exec=999 goto process1;

--goto fin;

--process1:

--print @exec


/* /**********************REQUETE TOTAL NOMNBRE RESTAU SICOM************************/ */

Declare @RestauSicom int 
set @RestauSicom =(
SELECT count (distinct BK) Compte_Restau
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT] 
WHERE FLAG_ACTIVE = 1 AND StatutValue LIKE 'A.%'
AND RestaurantUniqueID LIKE '8004%'
and SystemeVenteValue='SICOM')
/* /*****************REQUETE TOTAL NOMNBRE RESTAU REBOOT************************/ */
DEclare @RestauReboot int 
set @RestauReboot =(
SELECT count (distinct BK) Compte_Restau
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT]
WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
AND RestaurantUniqueID LIKE '8004%'
and SystemeVenteValue='Reboot')
/* /*****************REQUETE TOTAL NOMNBRE RESTAU MD5************************/ */
DEclare @RestauMD5 int 
set @RestauMD5 =(
SELECT count (distinct BKQ) Compte_Restau
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT]
WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
AND RestaurantUniqueID LIKE '2004%'
and SystemeVenteValue like 'maitre%')

/* /*****************REQUETE CALCUL DIFFERENCE NOMBRE RESTAU VS TOTAL NOMBRE RESTAU************/ */
/* /*****REQUETE TOTAL NOMNBRE RESTAU SICOM************/ */
DECLARE @deb date = cast (getdate ()-4 as date)
DECLARE @fin date = cast (getdate ()-1 as date)
--Declare @RestauSicom int 
--set @RestauSicom =(
--SELECT count (distinct BK) Compte_Restau
--FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT]
--WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
--AND RestaurantUniqueID LIKE '8004%'
--and SystemeVenteValue='SICOM')
select '**REQUETE SICOM CALCUL DIFFERENCE NOMBRE RESTAU VS TOTAL NOMBRE RESTAU**',SID_DATE
,count (distinct ID_UNIQUE_RESTAURANT)Nbr_Restau
, @RestauSicom Total_restau
, @RestauSicom-count (distinct ID_UNIQUE_RESTAURANT) as Diff
, source 
from SID_PRD.dwh.F_RESTAURANT
where ID_UNIQUE_RESTAURANT like '8004%'
and SOURCE='SEM'
and SID_DATE between @deb and @fin
group by SOURCE,SID_DATE
having sum (TOT_NET_REVENUE_HT) >0
UNION ALL
select '**REQUETE REBOOT CALCUL DIFFERENCE NOMBRE RESTAU VS TOTAL NOMBRE RESTAU**',SID_DATE
, count (distinct ID_UNIQUE_RESTAURANT)Nbr_Restau
, @RestauReboot Total_restau
, @RestauReboot-count (distinct ID_UNIQUE_RESTAURANT) as Diff
, source 
from SID_PRD.dwh.F_RESTAURANT
where ID_UNIQUE_RESTAURANT like '8004%'
and SOURCE='REB'
and SID_DATE between @deb and @fin
group by SOURCE,SID_DATE
having sum (TOT_NET_REVENUE_HT) >0
UNION ALL
select '**REQUETE MAITRED CALCUL DIFFERENCE NOMBRE RESTAU VS TOTAL NOMBRE RESTAU**',SID_DATE
,count (distinct ID_UNIQUE_RESTAURANT)Nbr_Restau
, @RestauMD5 Total_restau
, @RestauMD5-count (distinct ID_UNIQUE_RESTAURANT) as Diff
, source 
from SID_PRD.dwh.F_RESTAURANT
where ID_UNIQUE_RESTAURANT like '2004%'
and SOURCE ='MD5'
and SID_DATE between @deb and @fin 
group by SOURCE,SID_DATE
having sum (TOT_NET_REVENUE_HT) >0 
order by 2 desc

--fin1:


/* /*******************SICOM******************************/ */
/* /*******************REQUETE NOT EXISTE SHAREPOINT vs F_RESTAUT******************************/ */
/* /*******************SICOM******************************/ */

--DECLARE @deb date = cast (getdate ()-4 as date)
--DECLARE @fin date = cast (getdate ()-1 as date)

--Declare @RestauSicom int 

set @RestauSicom =(
SELECT count (distinct BK) Compte_Restau
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT] 
WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
AND RestaurantUniqueID LIKE '8004%'
and SystemeVenteValue='SICOM')

--SELECT distinct BK,NomDuRestaurant,'**SICOM NOT EXISTE SHAREPOINT vs F_RESTAUT**',@deb
--FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT] a
--WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
--AND RestaurantUniqueID LIKE '8004%'
--and SystemeVenteValue='SICOM'
--and not exists 
--(
--select distinct BK
--from SID_PRD.dwh.F_RESTAURANT b
--where ID_UNIQUE_RESTAURANT like '8004%'
--and SOURCE='SEM'
--and a.RestaurantUniqueID=b.ID_UNIQUE_RESTAURANT
--and SID_DATE>=cast (getdate()-1 as date))
--group by BK,source,NomDuRestaurant
--order by 1


/* /*******************REQUETE NOT EXISTE TICKET_UNIFIE vs F_RESTAUT******************************/ */
 IF OBJECT_ID('tempdb..#cal') IS NOT NULL 
        DROP TABLE tempdb..#cal
		;
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
	--PRINT '***************'+@date+'***************'
	--PRINT @loop
	
/*******REQUETE NOT EXISTE SHAREPOINT vs F_RESTAUT******************/
SELECT distinct BK,FR,NomDuRestaurant,@date,'**SICOM NOT EXISTE SHAREPOINT vs F_RESTAUT**'
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT] a
WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
AND RestaurantUniqueID LIKE '8004%'
and SystemeVenteValue='SICOM'
and not exists 
(select distinct BK
from SID_PRD.dwh.F_RESTAURANT b
where ID_UNIQUE_RESTAURANT like '8004%'
and SOURCE='SEM'
and a.RestaurantUniqueID=b.ID_UNIQUE_RESTAURANT
and SID_DATE =@date--,'20190407','20190408')
)group by BK,FR,source,NomDuRestaurant
order by 1
	FETCH  NEXT FROM Date_Cursor INTO @date 
	END;  
	
CLOSE Date_Cursor;  
DEALLOCATE Date_Cursor; 

--drop table #cal
-- /*******REQUETE COMPARABLE TICKET_UNIFIE vs F_RESTAUT******************/ 
--DECLARE @deb date = cast (getdate ()-11 as date)
--DECLARE @fin date = cast (getdate ()-1 as date)
--Declare @RestauSicom int 
set @RestauSicom =(
SELECT count (distinct BK) Compte_Restau
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT]
WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
AND RestaurantUniqueID LIKE '8004%'
and SystemeVenteValue='SICOM')

select 'TICKET_UNIFIE','**SICOM COMPARABLE TICKET_UNIFIE vs F_RESTAUT**',count (distinct RestaurantUniqueID)Nbr_Restau,CommercialDate
, @RestauSicom Total_restau
, @RestauSicom-count (distinct RestaurantUniqueID) as Diff 
,source
from SID_PRD.ODS.TICKET_UNIFIE 
where RestaurantUniqueID like '8004%'
and SOURCE='SEM'
and CommercialDate >=cast (getdate()-4 as date)
group by CommercialDate,source 
having @RestauSicom-count (distinct RestaurantUniqueID) >0
union all
select 'F_RESTAURANT','**SICOM COMPARABLE TICKET_UNIFIE vs F_RESTAUT**',count  (distinct ID_UNIQUE_RESTAURANT)Nbr_Restau,SID_DATE
, @RestauSicom Total_restau
, @RestauSicom-count (distinct ID_UNIQUE_RESTAURANT) as Diff
, source 
from SID_PRD.dwh.F_RESTAURANT
where ID_UNIQUE_RESTAURANT like '8004%'
and SOURCE='SEM'
and SID_DATE >=cast (getdate()-4 as date)
group by SOURCE,SID_DATE
having @RestauSicom-count (distinct ID_UNIQUE_RESTAURANT)>0
order by 4,2
GO
/* /*******************REBOOT******************************/ */
/* /*******************REQUETE NOT EXISTE SHAREPOINT vs F_RESTAUT******************************/ */
/* /*******************REBOOT******************************/ */
/* /*****************REQUETE TOTAL NOMNBRE RESTAU REBOOT************************/ */
DECLARE @deb date = cast (getdate ()-4 as date)
DECLARE @fin date = cast (getdate ()-1 as date)
DEclare @RestauReboot int 

set @RestauReboot =(
SELECT count (distinct BK) Compte_Restau
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT]
WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
AND RestaurantUniqueID LIKE '8004%'
and SystemeVenteValue='Reboot')

--SELECT distinct BK,NomDuRestaurant,'**REBOOT NOT EXISTE SHAREPOINT vs F_RESTAUT**',@deb
--FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT] a
--WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
--AND RestaurantUniqueID LIKE '8004%'
--and SystemeVenteValue='REBOOT'
--and not exists 
--(
--select distinct BK
--from SID_PRD.dwh.F_RESTAURANT b
--where ID_UNIQUE_RESTAURANT like '8004%'
--and SOURCE='REB'
--and a.RestaurantUniqueID=b.ID_UNIQUE_RESTAURANT
--and SID_DATE>=cast (getdate()-4 as date))
--group by BK,source,NomDuRestaurant
--order by 1

/* /*******************REQUETE NOT EXISTE TICKET_UNIFIE vs F_RESTAUT******************************/ */
IF OBJECT_ID('tempdb..#cal1') IS NOT NULL 
        DROP TABLE tempdb..#cal1
;
with calendrier as 
(   select @deb date
    union all
    select DATEADD(day, 1, date)
    from calendrier
    where DATEADD(day, 1, date) <= @fin )

select date into  tempdb..#cal1 from calendrier
option(maxrecursion 0)
print @deb
print @fin
DECLARE @date varchar(250)
DECLARE Date_Cursor CURSOR FOR  
select * from #cal1

OPEN Date_Cursor  
	FETCH NEXT FROM Date_Cursor INTO @date 
WHILE @@FETCH_STATUS = 0
    BEGIN 
	--PRINT '***************'+@date+'***************'
	--PRINT @loop
	
/*******REQUETE NOT EXISTE SHAREPOINT vs F_RESTAUT******************/
SELECT distinct BK,FR,NomDuRestaurant,@date,'**REBOOT NOT EXISTE SHAREPOINT vs F_RESTAUT**',@deb
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT] a
WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
AND RestaurantUniqueID LIKE '8004%'
and SystemeVenteValue='REBOOT'
and not exists 
(select distinct BK
from SID_PRD.dwh.F_RESTAURANT b
where ID_UNIQUE_RESTAURANT like '8004%'
and SOURCE='REB'
and a.RestaurantUniqueID=b.ID_UNIQUE_RESTAURANT
and SID_DATE =@date--,'20190407','20190408')
)group by BK,FR,source,NomDuRestaurant
order by 1
	FETCH  NEXT FROM Date_Cursor INTO @date 
	END;  
	
CLOSE Date_Cursor;  
DEALLOCATE Date_Cursor; 

--drop table #cal
-- /*******REQUETE COMPARABLE TICKET_UNIFIE vs F_RESTAUT******************/ 
--DECLARE @deb date = cast (getdate ()-11 as date)
--DECLARE @fin date = cast (getdate ()-1 as date)
--Declare @RestauSicom int 
set @RestauReboot =(
SELECT count (distinct BK) Compte_Restau
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT]
WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
AND RestaurantUniqueID LIKE '8004%'
and SystemeVenteValue='REBOOT')

select 'TICKET_UNIFIE','**REBOOT COMPARABLE TICKET_UNIFIE vs F_RESTAUT**',count (distinct RestaurantUniqueID)Nbr_Restau,CommercialDate
, @RestauReboot Total_restau
, @RestauReboot-count (distinct RestaurantUniqueID) as Diff 
,source
from SID_PRD.ODS.TICKET_UNIFIE 
where RestaurantUniqueID like '8004%'
and SOURCE='REB'
and CommercialDate >=cast (getdate()-4 as date)
group by CommercialDate,source 
having @RestauReboot-count (distinct RestaurantUniqueID) >0
union all
select 'F_RESTAURANT','**REBOOT COMPARABLE TICKET_UNIFIE vs F_RESTAUT**',count (distinct ID_UNIQUE_RESTAURANT)Nbr_Restau,SID_DATE
, @RestauReboot Total_restau
, @RestauReboot-count (distinct ID_UNIQUE_RESTAURANT) as Diff
, source 
from SID_PRD.dwh.F_RESTAURANT
where ID_UNIQUE_RESTAURANT like '8004%'
and SOURCE='REB'
and SID_DATE >=cast (getdate()-4 as date)
group by SOURCE,SID_DATE
having @RestauReboot-count (distinct ID_UNIQUE_RESTAURANT)>0
order by 4,2
GO
/* /*******************MAITRE'D******************************/ */
/* /*******************REQUETE NOT EXISTE SHAREPOINT vs F_RESTAUT******************************/ */
/* /*******************MAITRE'D******************************/ */
/* /*****************REQUETE TOTAL NOMNBRE RESTAU MD5************************/ */
DECLARE @deb date = cast (getdate ()-4 as date)
DECLARE @fin date = cast (getdate ()-1 as date)

DEclare @RestauMD5 int 

set @RestauMD5 =(
SELECT count (distinct BKQ) Compte_Restau
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT]
WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
AND RestaurantUniqueID LIKE '2004%'
and SystemeVenteValue like 'maitre%')

--SELECT distinct RestaurantUniqueID,NomDuRestaurant,'**MAITRED NOT EXISTE SHAREPOINT vs F_RESTAUT**',@deb
--FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT] a
--WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
--AND RestaurantUniqueID LIKE '2004%'and RestaurantUniqueID <>'20040746'
--and SystemeVenteValue like 'Maitre%'
--and not exists 
--(select distinct RestaurantUniqueID
--from SID_PRD.dwh.F_RESTAURANT b
--where ID_UNIQUE_RESTAURANT like '2004%'and RestaurantUniqueID <>'20040746'
--and SOURCE='MD5'
--and a.RestaurantUniqueID=b.ID_UNIQUE_RESTAURANT
--and SID_DATE >=cast (getdate()-4 as date))
--group by RestaurantUniqueID,source,NomDuRestaurant
--order by 1

/* /*******************REQUETE NOT EXISTE TICKET_UNIFIE vs F_RESTAUT******************************/ */
 IF OBJECT_ID('tempdb..#cal2') IS NOT NULL 
        DROP TABLE tempdb..#cal2
		;
with calendrier as 
(   select @deb date
    union all
    select DATEADD(day, 1, date)
    from calendrier
    where DATEADD(day, 1, date) <= @fin )

select date into  tempdb..#cal2 from calendrier
option(maxrecursion 0)
print @deb
print @fin
DECLARE @date varchar(250)
DECLARE Date_Cursor CURSOR FOR  
select * from #cal2

OPEN Date_Cursor  
	FETCH NEXT FROM Date_Cursor INTO @date 
WHILE @@FETCH_STATUS = 0
    BEGIN 
	--PRINT '***************'+@date+'***************'
	--PRINT @loop
	
/*******REQUETE NOT EXISTE SHAREPOINT vs F_RESTAUT******************/
SELECT distinct RestaurantUniqueID,NomDuRestaurant,@date,'**MAITRED NOT EXISTE SHAREPOINT vs F_RESTAUT**'
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT] a
WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
AND RestaurantUniqueID LIKE '2004%'and RestaurantUniqueID <>'20040746'
and SystemeVenteValue like 'Maitre%'
and not exists 
(select distinct RestaurantUniqueID
from SID_PRD.dwh.F_RESTAURANT b
where ID_UNIQUE_RESTAURANT like '2004%'and RestaurantUniqueID <>'20040746'
and SOURCE='MD5'
and a.RestaurantUniqueID=b.ID_UNIQUE_RESTAURANT
and SID_DATE  =@date--,'20190407','20190408')
)group by RestaurantUniqueID,source,NomDuRestaurant
order by 1
	FETCH  NEXT FROM Date_Cursor INTO @date 
	END;  
	
CLOSE Date_Cursor;  
DEALLOCATE Date_Cursor; 

--drop table #cal

-- /*******REQUETE COMPARABLE TICKET_UNIFIE vs F_RESTAUT******************/ 
--DECLARE @deb date = cast (getdate ()-4 as date)
--DECLARE @fin date = cast (getdate ()-1 as date)
--Declare @@RestauMD5 int 
set @RestauMD5 =(
SELECT count (distinct RestaurantUniqueID) Compte_Restau
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT]
WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
AND RestaurantUniqueID LIKE '2004%' and RestaurantUniqueID <>'20040746'
and SystemeVenteValue like 'Maitre%')

select 'TICKET_UNIFIE','**MAITRED COMPARABLE TICKET_UNIFIE vs F_RESTAUT**',count (distinct RestaurantUniqueID)Nbr_Restau,CommercialDate
, @RestauMD5 Total_restau
, @RestauMD5-count (distinct RestaurantUniqueID) as Diff 
,source
from SID_PRD.ODS.TICKET_UNIFIE 
where RestaurantUniqueID like '2004%'and RestaurantUniqueID <>'20040746'
and SOURCE='MD5'
and CommercialDate  >=cast (getdate()-4 as date)
group by CommercialDate,source 
having @RestauMD5-count (distinct RestaurantUniqueID) >0
union all
select 'F_RESTAURANT','**MAITRED COMPARABLE TICKET_UNIFIE vs F_RESTAUT**',count (distinct ID_UNIQUE_RESTAURANT)Nbr_Restau,SID_DATE
, @RestauMD5 Total_restau
, @RestauMD5-count (distinct ID_UNIQUE_RESTAURANT) as Diff
, source 
from SID_PRD.dwh.F_RESTAURANT
where ID_UNIQUE_RESTAURANT like '2004%'and ID_UNIQUE_RESTAURANT <>'20040746'
and SOURCE='MD5'
and SID_DATE  >=cast (getdate()-4 as date)
group by SOURCE,SID_DATE
having @RestauMD5-count (distinct ID_UNIQUE_RESTAURANT)>0
order by 4,2


