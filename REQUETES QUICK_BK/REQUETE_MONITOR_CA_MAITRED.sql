
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
AND RestaurantUniqueID LIKE '2004%' and RestaurantUniqueID not in ('20040746','20040726')
and SystemeVenteValue like 'maitre%')

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
SELECT distinct RestaurantUniqueID,rest_nr +1000 as rest_nr,NomDuRestaurant,@date as date,'**MAITRED NOT EXISTE SHAREPOINT vs F_RESTAUT**'
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
and SID_DATE  =@date--,'20190407','20190408')
)group by RestaurantUniqueID,rest_nr,source,NomDuRestaurant
order by 1
	FETCH  NEXT FROM Date_Cursor INTO @date 
	END;   
	
CLOSE Date_Cursor;  
DEALLOCATE Date_Cursor; 

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