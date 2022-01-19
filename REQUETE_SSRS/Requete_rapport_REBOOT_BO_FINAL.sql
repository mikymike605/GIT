

	DECLARE @date_courante AS DATE
	DECLARE @date_suivante AS DATE
	DECLARE @mois char(2)
	DECLARE @annee char(4)
	DECLARE @date_debut date
	DECLARE @date_fin date

--trouver date debut
	SELECT @date_courante=GETDATE()
	SELECT @mois=MONTH(@date_courante)
	SELECT @annee=YEAR(@date_courante)
--SELECT CAST(@annee + REPLICATE('0',2-LEN(@mois)) + @mois +'01' AS DATE)
	SELECT @date_debut=@annee + RTRIM(REPLICATE('0',2-LEN(@mois)) + @mois )+'01' 
--trouver date fin
	SELECT @date_suivante=DATEADD(month,1,@date_courante)
	SELECT @mois=MONTH(@date_suivante)
	SELECT @annee=YEAR(@date_suivante)
--SELECT CAST(@annee + REPLICATE('0',2-LEN(@mois)) + @mois +'01' AS DATE)
	SELECT @date_fin=@annee + RTRIM(REPLICATE('0',2-LEN(@mois)) + @mois )+'01' 
	SELECT @date_fin=DATEADD(day,-1,@date_fin)



select commercialdate,RestaurantUniqueID, LibelleFamille, sum(TotalTheorique) as TotalTheorique
into #tmp1
from ODS..REB_BO_REGLEMENT
where CommercialDate >= @date_debut 
and LibelleFamille not in ('REPAS EMPLOYE', 'TPE MOBILE')
group by commercialdate,RestaurantUniqueID, LibelleFamille
having sum(TotalTheorique) <>0


select s.CommercialDate, s.RestaurantUniqueID,s.RestaurantCode,s.libelle as label, sum(s.montant)as montant
into #tmp2
from
(
select commercialdate, 
	   RestaurantUniqueID,
	   restaurantcode,
	   case when label in ('ESPECES','RENDU') then 'ESPECES' 
			when label in ('CHEQUE') then 'CHEQUES' ELSE label end libelle , 
	   sum(amount)as montant
from ODS..REB_PAYMENT
where CommercialDate >= @date_debut
group by commercialdate,RestaurantUniqueID,label,RestaurantCode
)
as s
group by  s.CommercialDate,s.RestaurantUniqueID,s.restaurantcode ,s.libelle


SELECT a.CommercialDate,a.RestaurantUniqueID,a.LibelleFamille,a.TotalTheorique,b.montant,a.TotalTheorique-b.montant as Ecart
from #tmp1 a  
join #tmp2 b 
on a.RestaurantUniqueID=b.RestaurantUniqueID
and a.LibelleFamille=b.label 
and a.CommercialDate=b.CommercialDate
inner join [dbo].[ODS_BK_SHAREPOINT_RESTAURANT] S
on b.RestaurantCode=s.bk
where a.TotalTheorique-b.montant <>0
and S.ExploitationValue ='Compagnie'
order by 1,2,3

drop table #tmp1
drop table #tmp2