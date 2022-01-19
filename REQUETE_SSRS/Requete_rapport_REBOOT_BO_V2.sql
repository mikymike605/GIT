SELECT rest_nr, * 
FROM ODS..res_dep
where datval >= '20170125'
and rest_nr in (768,672,511)
order by datval desc 

SELECT * from  [SAS].[dbo].[SAS_PIQUICK_deprec_Monitor] 
where  Id_Resto in (768,672,511)
and Id_Pays=4

SELECT * from  [ODS].[dbo].ODS_PIQUICK_DepRec
where  Rest_nr in (768,672,511)
and Pays_seq=4
and CommercialDate>= '20170125'
order by CommercialDate desc


DECLARE @debut_date	date
DECLARE @fin_date	date


SELECT @debut_date = GETDATE()-31
SELECT @fin_date = GETDATE ()-1

select commercialdate,RestaurantUniqueID, LibelleFamille, sum(TotalTheorique) as TotalTheorique
into #tmp1
from ODS..REB_BO_REGLEMENT
where CommercialDate >= @debut_date 
and LibelleFamille not in ('REPAS EMPLOYE', 'TPE MOBILE')
group by commercialdate,RestaurantUniqueID, LibelleFamille
having sum(TotalTheorique) <>0
order by 1,2,3
--UNION ALL
select s.CommercialDate, s.RestaurantUniqueID,s.libelle as label, sum(s.montant)as montant
into #tmp2
from
(
select commercialdate, 
	   RestaurantUniqueID,
	   case when label in ('ESPECES','RENDU') then 'ESPECES' 
			when label in ('CHEQUE') then 'CHEQUES' ELSE label end libelle , 
	   sum(amount)as montant
from ODS..REB_PAYMENT
where CommercialDate >= @debut_date
group by commercialdate,RestaurantUniqueID,label
)
as s
group by  s.CommercialDate,s.RestaurantUniqueID ,s.libelle
order by 1,2,3

SELECT a.CommercialDate,a.RestaurantUniqueID,a.LibelleFamille,a.TotalTheorique,b.montant,a.TotalTheorique-b.montant as Ecart
from #tmp1 a  
join #tmp2 b 
on a.RestaurantUniqueID=b.RestaurantUniqueID
and a.LibelleFamille=b.label 
and a.CommercialDate=b.CommercialDate
where a.TotalTheorique-b.montant <>0


drop table #tmp1
drop table #tmp2