
/* /*******************SICOM******************************/ */
/* /*******************REQUETE NOT EXISTE SHAREPOINT vs F_RESTAUT******************************/ */
/* /*******************SICOM******************************/ */

DECLARE @deb date = cast (getdate ()-4 as date)
DECLARE @fin date = cast (getdate ()-1 as date)

Declare @RestauSicom int 

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
, CASE WHEN @RestauSicom-count (distinct RestaurantUniqueID)=0 then '***** RAS *****' else '***** '+cast (@RestauSicom-count (distinct RestaurantUniqueID) as varchar(5))+' Restau ' +SOURCE+ ' A Réintégrer*****' end
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
, CASE WHEN @RestauSicom-count (distinct ID_UNIQUE_RESTAURANT)=0 then '***** RAS *****' else '***** '+cast (@RestauSicom-count (distinct ID_UNIQUE_RESTAURANT) as varchar(5))+' Restau ' +SOURCE+ ' A Réintégrer*****' end
from SID_PRD.dwh.F_RESTAURANT
where ID_UNIQUE_RESTAURANT like '8004%'
and SOURCE='SEM'
and SID_DATE >=cast (getdate()-4 as date)
group by SOURCE,SID_DATE
having @RestauSicom-count (distinct ID_UNIQUE_RESTAURANT)>0
order by 4,2
GO