DECLARE @exec int set @exec =5
IF @exec=0 goto process;-------Monitor manquants Table finale 'DWH.F_RESTAURANT sur 4 jours'
IF @exec=1 goto process1;-------Monitor manquants SICOM Table finale 'DWH.F_RESTAURANT' sur 4 jours + Monitoring count restau ODS.TICKET_UNIFIE vs DWH.F_RESTAURANT
IF @exec=2 goto process2;-------Monitor manquants REBOOT Table finale 'DWH.F_RESTAURANT' sur 4 jours + Monitoring count restau ODS.TICKET_UNIFIE vs DWH.F_RESTAURANT
IF @exec=3 goto process3;-------Monitor manquants Maitre'D Table finale 'DWH.F_RESTAURANT' sur 4 jours + Monitoring count restau ODS.TICKET_UNIFIE vs DWH.F_RESTAURANT
IF @exec=4 goto process4;-------Monitor ALL manquants Table finale 'DWH.F_RESTAURANT' sur 4 jours + Monitoring count restau ODS.TICKET_UNIFIE vs DWH.F_RESTAURANT
IF @exec=5 goto process5;-------Monitor manquants VILFRMDBRIDGE..MD5_INVOICE vs KINGSIDSQLPRD..TIKCET_UNIFIE
--IF @exec=6 goto process6;-------Lancer requete réintégration données SICOM 
--IF @exec=7 goto process7;-------Lancer requete réintégration données REBOOT
--IF @exec=8 goto process8;-------Lancer requete réintégration données Maitre'D 
goto fin;

process:
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
AND RestaurantUniqueID LIKE '2004%' and RestaurantUniqueID  not in ('20040746')--,'20040726')
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
, CASE WHEN @RestauSicom-count (distinct ID_UNIQUE_RESTAURANT)=0 then '***** RAS *****' else '***** '+cast (@RestauSicom-count (distinct ID_UNIQUE_RESTAURANT) as varchar(5))+' Restau ' +SOURCE+ ' A Réintégrer*****' end
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
,CASE WHEN @RestauReboot-count (distinct ID_UNIQUE_RESTAURANT)=0 then '***** RAS *****' else '***** '+cast (@RestauReboot-count (distinct ID_UNIQUE_RESTAURANT) as varchar(5))+' Restau ' +SOURCE+ ' A Réintégrer*****' end
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
,CASE WHEN @RestauMD5-count (distinct ID_UNIQUE_RESTAURANT)=0 then '***** RAS *****' else '***** '+cast (@RestauMD5-count (distinct ID_UNIQUE_RESTAURANT) as varchar(5))+' Restau '+SOURCE+ ' A Réintégrer*****' end
from SID_PRD.dwh.F_RESTAURANT
where ID_UNIQUE_RESTAURANT like '2004%' 
and SOURCE ='MD5'
and SID_DATE between @deb and @fin 
group by SOURCE,SID_DATE
having sum (TOT_NET_REVENUE_HT) >0 
order by 2 desc
GOTO   fin;

process1:

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
DECLARE @deb1 date = cast (getdate ()-4 as date)
DECLARE @fin1 date = cast (getdate ()-1 as date)
 IF OBJECT_ID('tempdb..#cal') IS NOT NULL 
        DROP TABLE tempdb..#cal
		;
with calendrier as 
(   select @deb1 date
    union all
    select DATEADD(day, 1, date)
    from calendrier
    where DATEADD(day, 1, date) <= @fin1)


select date into #cal from calendrier
option(maxrecursion 0)
print @deb1
print @fin1
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
SELECT distinct SEMS_UID,BK,FR,NomDuRestaurant,@date,'**SICOM NOT EXISTE SHAREPOINT vs F_RESTAUT**'
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
)group by SEMS_UID,BK,FR,source,NomDuRestaurant
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

GOTO   fin;

process2:

/* /*******************REBOOT******************************/ */
/* /*******************REQUETE NOT EXISTE SHAREPOINT vs F_RESTAUT******************************/ */
/* /*******************REBOOT******************************/ */
/* /*****************REQUETE TOTAL NOMNBRE RESTAU REBOOT************************/ */
DECLARE @deb2 date = cast (getdate ()-4 as date)
DECLARE @fin2 date = cast (getdate ()-1 as date)

--DEclare @RestauReboot int 

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
(   select @deb2 date
    union all
    select DATEADD(day, 1, date)
    from calendrier
    where DATEADD(day, 1, date) <= @fin2 )

select date into  tempdb..#cal1 from calendrier
option(maxrecursion 0)
print @deb2
print @fin2
DECLARE @date2 varchar(250)
DECLARE Date_Cursor1 CURSOR FOR  
select * from #cal1

OPEN Date_Cursor1  
	FETCH NEXT FROM Date_Cursor1 INTO @date2 
WHILE @@FETCH_STATUS = 0
    BEGIN 
	--PRINT '***************'+@date+'***************'
	--PRINT @loop
	
/*******REQUETE NOT EXISTE SHAREPOINT vs F_RESTAUT******************/
SELECT distinct SEMS_UID,BK,FR,NomDuRestaurant,@date2,'**REBOOT NOT EXISTE SHAREPOINT vs F_RESTAUT**'
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
and SID_DATE =@date2--,'20190407','20190408')
)group by SEMS_UID,BK,FR,source,NomDuRestaurant
order by 1
	FETCH  NEXT FROM Date_Cursor1 INTO @date2 
	END;  
	
CLOSE Date_Cursor1;  
DEALLOCATE Date_Cursor1; 

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
, CASE WHEN @RestauReboot-count (distinct RestaurantUniqueID)=0 then '***** RAS *****' else '***** '+cast (@RestauReboot-count (distinct RestaurantUniqueID) as varchar(5))+' Restau ' +SOURCE+ ' A Réintégrer*****' end
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
, CASE WHEN @RestauReboot-count (distinct ID_UNIQUE_RESTAURANT)=0 then '***** RAS *****' else '***** '+cast (@RestauReboot-count (distinct ID_UNIQUE_RESTAURANT) as varchar(5))+' Restau ' +SOURCE+ ' A Réintégrer*****' end
from SID_PRD.dwh.F_RESTAURANT
where ID_UNIQUE_RESTAURANT like '8004%'
and SOURCE='REB'
and SID_DATE >=cast (getdate()-4 as date)
group by SOURCE,SID_DATE
having @RestauReboot-count (distinct ID_UNIQUE_RESTAURANT)>0
order by 4,2
GOTO fin;

process3:

/* /*******************MAITRE'D******************************/ */
/* /*******************REQUETE NOT EXISTE SHAREPOINT vs F_RESTAUT******************************/ */
/* /*******************MAITRE'D******************************/ */
/* /*****************REQUETE TOTAL NOMNBRE RESTAU MD5************************/ */
DECLARE @deb3 date = cast (getdate ()-4 as date)
DECLARE @fin3 date = cast (getdate ()-1 as date)

--DEclare @RestauMD5 int 

set @RestauMD5 =(
SELECT count (distinct BKQ) Compte_Restau
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT]
WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
AND RestaurantUniqueID LIKE '2004%' and RestaurantUniqueID not in ('20040746','20040726')
and SystemeVenteValue like 'maitre%')

/* /*******************REQUETE NOT EXISTE TICKET_UNIFIE vs F_RESTAUT******************************/ */
 IF OBJECT_ID('tempdb..#cal2') IS NOT NULL 
        DROP TABLE tempdb..#cal2
		;
with calendrier as 
(   select @deb3 date
    union all
    select DATEADD(day, 1, date)
    from calendrier
    where DATEADD(day, 1, date) <= @fin3 )

select date into  tempdb..#cal2 from calendrier
option(maxrecursion 0)
print @deb3
print @fin3
DECLARE @date3 varchar(250)
DECLARE Date_Cursor3 CURSOR FOR  
select * from #cal2

OPEN Date_Cursor3  
	FETCH NEXT FROM Date_Cursor3 INTO @date3 
WHILE @@FETCH_STATUS = 0
    BEGIN 
	--PRINT '***************'+@date+'***************'
	--PRINT @loop
	
/*******REQUETE NOT EXISTE SHAREPOINT vs F_RESTAUT******************/
SELECT distinct RestaurantUniqueID,rest_nr +1000 as rest_nr,NomDuRestaurant,@date3 as date,'**MAITRED NOT EXISTE SHAREPOINT vs F_RESTAUT**'
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT] a
WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
AND RestaurantUniqueID LIKE '2004%'--and RestaurantUniqueID <>'20040746'
and SystemeVenteValue like 'Maitre%'
and not exists 
(select distinct RestaurantUniqueID
from SID_PRD.dwh.F_RESTAURANT b
where ID_UNIQUE_RESTAURANT like '2004%'--and RestaurantUniqueID <>'20040746'
and SOURCE='MD5'
and a.RestaurantUniqueID=b.ID_UNIQUE_RESTAURANT
and SID_DATE  =@date3--,'20190407','20190408')
)group by RestaurantUniqueID,rest_nr,source,NomDuRestaurant
order by 1
	FETCH  NEXT FROM Date_Cursor3 INTO @date3 
	END;   
	
CLOSE Date_Cursor3;  
DEALLOCATE Date_Cursor3; 

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
, CASE WHEN @RestauMD5-count (distinct RestaurantUniqueID)=0 then '***** RAS *****' else '***** '+cast (@RestauMD5-count (distinct RestaurantUniqueID) as varchar(5))+' Restau ' +SOURCE+ ' A Réintégrer*****' end
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
, CASE WHEN @RestauMD5-count (distinct ID_UNIQUE_RESTAURANT)=0 then '***** RAS *****' else '***** '+cast (@RestauMD5-count (distinct ID_UNIQUE_RESTAURANT) as varchar(5))+' Restau ' +SOURCE+ ' A Réintégrer*****' end
from SID_PRD.dwh.F_RESTAURANT
where ID_UNIQUE_RESTAURANT like '2004%'--and ID_UNIQUE_RESTAURANT <>'20040746'
and SOURCE='MD5'
and SID_DATE  >=cast (getdate()-4 as date)
group by SOURCE,SID_DATE
having @RestauMD5-count (distinct ID_UNIQUE_RESTAURANT)>0
order by 4,2
GOTO fin;

process4:

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
DECLARE @deb4 date = cast (getdate ()-4 as date)
DECLARE @fin4 date = cast (getdate ()-1 as date)
 IF OBJECT_ID('tempdb..#cal3') IS NOT NULL 
        DROP TABLE tempdb..#cal3
		;
with calendrier as 
(   select @deb4 date
    union all
    select DATEADD(day, 1, date)
    from calendrier
    where DATEADD(day, 1, date) <= @fin4)


select date into #cal3 from calendrier
option(maxrecursion 0)
print @deb4
print @fin4
DECLARE @date4 varchar(250)
DECLARE Date_Cursor4 CURSOR FOR  
select * from #cal3

OPEN Date_Cursor4  
	FETCH NEXT FROM Date_Cursor4 INTO @date4 
WHILE @@FETCH_STATUS = 0
    BEGIN 
	--PRINT '***************'+@date+'***************'
	--PRINT @loop
	
/*******REQUETE NOT EXISTE SHAREPOINT vs F_RESTAUT******************/
SELECT distinct SEMS_UID,BK,FR,NomDuRestaurant,@date4,'**SICOM NOT EXISTE SHAREPOINT vs F_RESTAUT**'
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
and SID_DATE =@date4--,'20190407','20190408')
)group by SEMS_UID, BK,FR,source,NomDuRestaurant
order by 1
	FETCH  NEXT FROM Date_Cursor4 INTO @date4 
	END;  
	
CLOSE Date_Cursor4;  
DEALLOCATE Date_Cursor4; 

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


/* /*******************REBOOT******************************/ */
/* /*******************REQUETE NOT EXISTE SHAREPOINT vs F_RESTAUT******************************/ */
/* /*******************REBOOT******************************/ */
/* /*****************REQUETE TOTAL NOMNBRE RESTAU REBOOT************************/ */
DECLARE @deb5 date = cast (getdate ()-4 as date)
DECLARE @fin5 date = cast (getdate ()-1 as date)

--DEclare @RestauReboot int 

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
IF OBJECT_ID('tempdb..#cal4') IS NOT NULL 
        DROP TABLE tempdb..#cal4
;
with calendrier as 
(   select @deb5 date
    union all
    select DATEADD(day, 1, date)
    from calendrier
    where DATEADD(day, 1, date) <= @fin5 )

select date into  tempdb..#cal4 from calendrier
option(maxrecursion 0)
print @deb5
print @fin5
DECLARE @date5 varchar(250)
DECLARE Date_Cursor5 CURSOR FOR  
select * from #cal4

OPEN Date_Cursor5  
	FETCH NEXT FROM Date_Cursor5 INTO @date5 
WHILE @@FETCH_STATUS = 0
    BEGIN 
	--PRINT '***************'+@date+'***************'
	--PRINT @loop
	
/*******REQUETE NOT EXISTE SHAREPOINT vs F_RESTAUT******************/
SELECT distinct SEMS_UID,BK,FR,NomDuRestaurant,@date5,'**REBOOT NOT EXISTE SHAREPOINT vs F_RESTAUT**'
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
and SID_DATE =@date5--,'20190407','20190408')
)group by SEMS_UID,BK,FR,source,NomDuRestaurant
order by 1
	FETCH  NEXT FROM Date_Cursor5 INTO @date5 
	END;  
	
CLOSE Date_Cursor5;  
DEALLOCATE Date_Cursor5; 

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
, CASE WHEN @RestauReboot-count (distinct RestaurantUniqueID)=0 then '***** RAS *****' else '***** '+cast (@RestauReboot-count (distinct RestaurantUniqueID) as varchar(5))+' Restau ' +SOURCE+ ' A Réintégrer*****' end
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
, CASE WHEN @RestauReboot-count (distinct ID_UNIQUE_RESTAURANT)=0 then '***** RAS *****' else '***** '+cast (@RestauReboot-count (distinct ID_UNIQUE_RESTAURANT) as varchar(5))+' Restau ' +SOURCE+ ' A Réintégrer*****' end
from SID_PRD.dwh.F_RESTAURANT
where ID_UNIQUE_RESTAURANT like '8004%'
and SOURCE='REB'
and SID_DATE >=cast (getdate()-4 as date)
group by SOURCE,SID_DATE
having @RestauReboot-count (distinct ID_UNIQUE_RESTAURANT)>0
order by 4,2


/* /*******************MAITRE'D******************************/ */
/* /*******************REQUETE NOT EXISTE SHAREPOINT vs F_RESTAUT******************************/ */
/* /*******************MAITRE'D******************************/ */
/* /*****************REQUETE TOTAL NOMNBRE RESTAU MD5************************/ */
DECLARE @deb6 date = cast (getdate ()-4 as date)
DECLARE @fin6 date = cast (getdate ()-1 as date)

--DEclare @RestauMD5 int 

set @RestauMD5 =(
SELECT count (distinct BKQ) Compte_Restau
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT]
WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
AND RestaurantUniqueID LIKE '2004%' and RestaurantUniqueID not in ('20040746','20040726')
and SystemeVenteValue like 'maitre%')

/* /*******************REQUETE NOT EXISTE TICKET_UNIFIE vs F_RESTAUT******************************/ */
 IF OBJECT_ID('tempdb..#cal5') IS NOT NULL 
        DROP TABLE tempdb..#cal5
		;
with calendrier as 
(   select @deb6 date
    union all
    select DATEADD(day, 1, date)
    from calendrier
    where DATEADD(day, 1, date) <= @fin6 )

select date into  tempdb..#cal5 from calendrier
option(maxrecursion 0)
print @deb6
print @fin6
DECLARE @date6 varchar(250)
DECLARE Date_Cursor6 CURSOR FOR  
select * from #cal5

OPEN Date_Cursor6  
	FETCH NEXT FROM Date_Cursor6 INTO @date6 
WHILE @@FETCH_STATUS = 0
    BEGIN 
	--PRINT '***************'+@date+'***************'
	--PRINT @loop
	
/*******REQUETE NOT EXISTE SHAREPOINT vs F_RESTAUT******************/
SELECT distinct RestaurantUniqueID,rest_nr +1000 as rest_nr,NomDuRestaurant,@date6 as date,'**MAITRED NOT EXISTE SHAREPOINT vs F_RESTAUT**'
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT] a
WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
AND RestaurantUniqueID LIKE '2004%'--and RestaurantUniqueID <>'20040746'
and SystemeVenteValue like 'Maitre%'
and not exists 
(select distinct RestaurantUniqueID
from SID_PRD.dwh.F_RESTAURANT b
where ID_UNIQUE_RESTAURANT like '2004%'--and RestaurantUniqueID <>'20040746'
and SOURCE='MD5'
and a.RestaurantUniqueID=b.ID_UNIQUE_RESTAURANT
and SID_DATE  =@date6--,'20190407','20190408')
)group by RestaurantUniqueID,rest_nr,source,NomDuRestaurant
order by 1
	FETCH  NEXT FROM Date_Cursor6 INTO @date6 
	END;   
	
CLOSE Date_Cursor6;  
DEALLOCATE Date_Cursor6; 

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
, CASE WHEN @RestauMD5-count (distinct RestaurantUniqueID)=0 then '***** RAS *****' else '***** '+cast (@RestauMD5-count (distinct RestaurantUniqueID) as varchar(5))+' Restau ' +SOURCE+ ' A Réintégrer*****' end
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
, CASE WHEN @RestauMD5-count (distinct ID_UNIQUE_RESTAURANT)=0 then '***** RAS *****' else '***** '+cast (@RestauMD5-count (distinct ID_UNIQUE_RESTAURANT) as varchar(5))+' Restau ' +SOURCE+ ' A Réintégrer*****' end
from SID_PRD.dwh.F_RESTAURANT
where ID_UNIQUE_RESTAURANT like '2004%'--and ID_UNIQUE_RESTAURANT <>'20040746'
and SOURCE='MD5'
and SID_DATE  >=cast (getdate()-4 as date)
group by SOURCE,SID_DATE
having @RestauMD5-count (distinct ID_UNIQUE_RESTAURANT)>0
order by 4,2
GOTO fin;

process5:

select count (distinct (restaurantcode))Total_Restau,cast (FiscalDate as date)Date,'**[QuickMDCube_FR].dbo.mdinvoice**' as Info
FROM VILFRMDBRIDGE.[QuickMDCube_FR].dbo.mdinvoice --a
--where Total >0
where cast (FiscalDate as date)>= cast (GETDATE ()-4 as date)
group by cast (FiscalDate as date)
order by 2 

SELECT count (distinct (restaurantcode))Total_Restau,commercialdate as Date,'**SID_PRD.[ODS].[Ticket_Unifie]**' as Info
FROM SID_PRD.[ODS].[Ticket_Unifie]
where restaurantuniqueid like '2004%' and commercialdate >=  cast (GETDATE ()-4 as date)
group by commercialdate
order by 2

SELECT distinct (RestaurantCode)Restau,cast (fiscaldate as date) Date ,'**RESTAU MANQUANTS DANS SID_PRD.ODS.[TICKET_UNIFIE]**' as Info
FROM VILFRMDBRIDGE.[QuickMDCube_FR].dbo.MDINVOICE a
where cast (fiscaldate as date) >= cast (getdate ()-4 as date)
and not exists
( 
SELECT distinct( RestaurantCode),CommercialDate
FROM SID_PRD.ODS.[TICKET_UNIFIE] b
where CommercialDate >=  cast (getdate ()-4 as date)
and a.RestaurantCode+20039000=b.RestaurantUniqueID
and cast (a.fiscaldate as date)=b.CommercialDate
and RestaurantUniqueID like '2004%'
and CA_Brut_HT>0
group by RestaurantCode,CommercialDate
)
group by  RestaurantCode,cast (fiscaldate as date)


SELECT distinct( RestaurantCode),CommercialDate,'**RESTAU MANQUANTS DANS [QuickMDCube_FR].dbo.MDINVOICE**'
FROM SID_PRD.ODS.[TICKET_UNIFIE] b
where CommercialDate >=  cast (getdate ()-4 as date)
and RestaurantUniqueID like '2004%'
and not exists
( SELECT distinct (RestaurantCode),cast (fiscaldate as date) 
FROM VILFRMDBRIDGE.[QuickMDCube_FR].dbo.mdinvoice a
where cast (fiscaldate as date) >= cast (getdate ()-4 as date)
and a.RestaurantCode+20039000=b.RestaurantUniqueID
and cast (a.fiscaldate as date)=b.CommercialDate
--and CA_Brut_HT>0
group by RestaurantCode,cast (fiscaldate as date)
)
group by  RestaurantCode,CommercialDate
--order by 1
GOTO fin;
  fin: