SET NOCOUNT ON

DECLARE @DATE_DEBUT date=convert(date, dateadd(day,-1,getdate()))
DECLARE @DATE_FIN date=convert(date, dateadd(day,-1,getdate()))
DECLARE @TauxRemontee integer

--#################################################################################################
DECLARE @NombreTotalgc varchar (50) = (
SELECT COUNT(*) 
 FROM
(
select  A.id_unique_restaurant,A.bk,A.NomDuRestaurant, A.ouverture, A.store_uid,C.sid_date FROM
(select sid_date from dwh.dim_time where sid_date>=@DATE_DEBUT and sid_date<=@DATE_FIN)  C
LEFT JOIN  ( select distinct RestaurantUniqueID id_unique_restaurant,bk, ouverture, NomDuRestaurant , sems_uid store_uid 
from ODS.SHP_BK_SHAREPOINT_RESTAURANT where FLAG_ACTIVE =1 and RestaurantUniqueID like '2004%' and StatutValue like 'A.%' and Ouverture <=@DATE_FIN 
) A 
ON A.ouverture<=C.sid_date   
) A)
PRINT 'TOTAL MD5*****MD5*****MD5****       '+@NombreTotalgc+'       *********MD5*****MD5*****MD5****'


--#################################################################################################
DECLARE @Nombretraitegc varchar(50) = (
SELECT COUNT(*) FROM
(
  select distinct id_unique_restaurant ,sid_date
FROM KINGSIDSQLPRD.SID_PRD.DWH.[F_RESTAURANT] with(nolock)
WHERE  id_unique_restaurant in (  select distinct RestaurantUniqueID  
from ODS.SHP_BK_SHAREPOINT_RESTAURANT where FLAG_ACTIVE =1 and RestaurantUniqueID like '2004%'   )
 and 
sid_date  >=@DATE_DEBUT
and TOT_NET_REVENUE_HT <>0
)  B)
PRINT '  J-1 MD5*****MD5*****MD5****       '+@Nombretraitegc+'       *********MD5*****MD5*****MD5****'


SELECT @TauxRemontee = @Nombretraitegc * 100 / @NombreTotalgc
PRINT @TauxRemontee


DECLARE @TauxRemonteeREBOOT integer

--#################################################################################################
DECLARE @NombreTotalgcREBOOT varchar(50) = (
SELECT COUNT(*)
 FROM
(
select  A.id_unique_restaurant,A.bk,A.NomDuRestaurant, A.ouverture, A.store_uid,C.sid_date FROM
(select sid_date from dwh.dim_time where sid_date>=@DATE_DEBUT and sid_date<=@DATE_FIN)  C
LEFT JOIN  ( select distinct 80040000+BKQ id_unique_restaurant,bk, ouverture, NomDuRestaurant , sems_uid store_uid 
from ODS.SHP_BK_SHAREPOINT_RESTAURANT where FLAG_ACTIVE =1 and SystemeVenteValue='Reboot' and Ouverture <=@DATE_FIN
) A 
ON A.ouverture<=C.sid_date
) A )
PRINT 'TOTAL REB*****REB*****REB****       '+@NombreTotalgcREBOOT+'       *********REB*****REB*****REB****'

--#################################################################################################
DECLARE @NombretraitegcREBOOT varchar(50) = (
SELECT COUNT(*) FROM (
  select distinct id_unique_restaurant ,sid_date
FROM KINGSIDSQLPRD.SID_PRD.DWH.[F_RESTAURANT] with(nolock)
WHERE  id_unique_restaurant in ( select distinct 80040000+BKQ from ODS.SHP_BK_SHAREPOINT_RESTAURANT where FLAG_ACTIVE =1 and SystemeVenteValue='Reboot')
 and 
sid_date  >=@DATE_DEBUT
and TOT_NET_REVENUE_HT <>0 ) B)

PRINT '  J-1 REB*****REB*****REB****       '+@NombretraitegcREBOOT+'       *********REB*****REB*****REB****'

--#################################################################################################
SELECT @TauxRemonteeREBOOT = @NombretraitegcREBOOT * 100 / @NombreTotalgcREBOOT
PRINT @TauxRemonteeREBOOT



DECLARE @TauxRemonteeSEM integer
--#################################################################################################
DECLARE @NombreTotalgcSEM varchar(50) = (

SELECT COUNT(*) as NombreTotal FROM (
SELECT A.bk,A.NomDuRestaurant, A.ouverture, A.store_uid, id_unique_restaurant, getdate() as date  FROM
(
select  A.id_unique_restaurant,A.bk,A.NomDuRestaurant, A.ouverture, A.store_uid,C.sid_date, DESC_WEEKDAY, dimanche, lundi FROM
(select sid_date,DESC_WEEKDAY from dwh.dim_time where sid_date>=@DATE_DEBUT and sid_date<=@DATE_FIN)  C
LEFT JOIN  ( select distinct 80040000+BKQ id_unique_restaurant,bk, ouverture, NomDuRestaurant , sems_uid store_uid , isnull(HoraireDimanche, 'ferme_dimanche') dimanche, isnull(HoraireLundi, 'ferme_lundi') lundi
from ODS.SHP_BK_SHAREPOINT_RESTAURANT where FLAG_ACTIVE =1 and SystemeVenteValue='Sicom' and Ouverture <=@DATE_FIN 
) A 
ON A.ouverture<=C.sid_date
where DESC_WEEKDAY <> case when dimanche='ferme_dimanche' then 'dimanche' else '1' end
and DESC_WEEKDAY <> case when lundi='ferme_lundi' then 'lundi' else '1' end
) A ) Nombre_Total)

PRINT 'TOTAL SEM*****SEM*****SEM****       '+@NombreTotalgcSEM+'       *********SEM*****SEM*****SEM****'
--#################################################################################################
DECLARE @NombretraitegcSEM Varchar (50) = (
SELECT COUNT(*) as NombreTraite FROM (
  select distinct id_unique_restaurant ,sid_date
FROM KINGSIDSQLPRD.SID_PRD.DWH.[F_RESTAURANT] with(nolock)
WHERE  id_unique_restaurant in ( select distinct 80040000+BKQ from ODS.SHP_BK_SHAREPOINT_RESTAURANT where FLAG_ACTIVE =1 and SystemeVenteValue='Sicom')
 and 
sid_date  >=@DATE_DEBUT
and TOT_NET_REVENUE_HT <>0
) Nombre_traite)

PRINT '  J-1 SEM*****SEM*****SEM****       '+@NombretraitegcSEM+'       *********SEM*****SEM*****SEM****'
--#################################################################################################
SELECT @TauxRemonteeSEM = @NombretraitegcSEM * 100 / @NombreTotalgcSEM
PRINT @TauxRemonteeSEM
