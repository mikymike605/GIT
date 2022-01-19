DECLARE @deb date = cast (getdate ()-4 as date)
DECLARE @fin date = cast (getdate ()-1 as date)
--DECLARE @diff int = datediff(day, @deb, @fin)
--DECLARE @loop int = 0
--while @loop <= @diff
--begin  

select'TICKET_UNIFIE_TEMP' [Table],
       CommercialDate,
       count (distinct RestaurantUniqueID) Compte_Restau,
       Count(*) Compte
from KINGSIDSQLPRD.SID_PRD.ODS.[TICKET_UNIFIE_TEMP] with (nolock)
--where CommercialDate = dateadd(day, @loop, @deb)
--where RestaurantUniqueID='80040920'
group by  CommercialDate--,t.RestaurantUniqueID,s.RestaurantUniqueID--year(CommercialDate), month (CommercialDate),day (CommercialDate)
--order by CommercialDate
UNION ALL
SELECT 'TICKET_UNIFIE'[Table],
       CommercialDate,
       count (distinct RestaurantUniqueID) Compte_Restau,
       Count(*) Compte
FROM KINGSIDSQLPRD.SID_PRD.ODS.[TICKET_UNIFIE]  with (nolock)
where CommercialDate between @deb and @fin
and RestaurantUniqueID like '8004%'
group by  CommercialDate
--order by CommercialDate
--UNION ALL
--select 'F_RESTAU'[Table],
--       SID_DATE,
--       count (distinct ID_UNIQUE_RESTAURANT) Compte_Restau
--       --Count(*) Compte
--FROM KINGSIDSQLPRD.SID_PRD.[DWH].[F_RESTAURANT] with (nolock)
--where SID_DATE between '20190406' and '20190409'
--and ID_UNIQUE_RESTAURANT like '8004%'
--group by  SID_DATE
--having sum(REVENUE_TTC)>100000
--order by CommercialDate


--SELECT  Restaurantuniqueid,
--CommercialDate,
--Count(*)
--FROM KINGSIDSQLPRD.SID_PRD.ODS.[TICKET_UNIFIE] a
--where CommercialDate  = cast (dateadd(day, @loop, @deb) as date)
--and RestaurantUniqueID like '80040%'
--and not exists
--( 
--SELECT Restaurantuniqueid,
--CommercialDate,
--Count(*)
--FROM KINGSIDSQLPRD.SID_PRD.ODS.[TICKET_UNIFIE_temp] b
--  where CommercialDate = cast (dateadd(day, @loop, @deb) as date)
--  and a.RestaurantUniqueID=b.RestaurantUniqueID 
--and RestaurantUniqueID like '80040%'
--group by RestaurantUniqueID,CommercialDate
--)
--group by  a.RestaurantUniqueID,CommercialDate
--order by 1

--SET @loop = @loop +1

--END 

select  count (distinct ID_UNIQUE_RESTAURANT)
	   ,sid_date
	   ,sum(TOT_NET_REVENUE_HT)
       --Count(*) Compte
FROM KINGSIDSQLPRD.SID_PRD.[DWH].[F_RESTAURANT] with (nolock)
where SID_DATE >= '20190406' 
and ID_UNIQUE_RESTAURANT like '8004%'
group by  sid_date
having sum(TOT_NET_REVENUE_HT)<>0
--order by ID_UNIQUE_RESTAURANT