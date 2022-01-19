
		
DECLARE @deb date = cast (getdate ()-3 as date)
DECLARE @fin date = cast (getdate ()-1 as date)


DEclare @RestauAttendu int 
set @RestauAttendu =(
SELECT count (distinct BK) Compte_Restau
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT]
WHERE FLAG_ACTIVE =1 AND StatutValue LIKE 'A.%'
AND RestaurantUniqueID LIKE '8004%')

select'Ticket_Unifie_Temp' [Table],
       CommercialDate,
       @RestauAttendu-count (distinct RestaurantUniqueID)Restau_Manquant,
	   count (distinct RestaurantUniqueID) Compte_Restau,
	   @RestauAttendu as Total_Restau,
	   Count(*) Compte
from KINGSIDSQLPRD.SID_PRD.ODS.[TICKET_UNIFIE_TEMP] with (nolock)
--where CommercialDate = dateadd(day, @loop, @deb)
--where RestaurantUniqueID='80040920'
group by  CommercialDate--,t.RestaurantUniqueID,s.RestaurantUniqueID--year(CommercialDate), month (CommercialDate),day (CommercialDate)
--order by CommercialDate
UNION ALL
SELECT 'Ticket_Unifie'[Table],
       CommercialDate,
       @RestauAttendu -count (distinct RestaurantUniqueID)Restau_Manquant,
	   count (distinct RestaurantUniqueID) Compte_Restau,
	   @RestauAttendu as Total_Restau,
	   Count(*) Compte
FROM KINGSIDSQLPRD.SID_PRD.ODS.[TICKET_UNIFIE]  with (nolock)
where CommercialDate between @deb and @fin
and RestaurantUniqueID like '8004%'
group by  CommercialDate

order by CommercialDate,[Table]