SELECT commercialdate,Rest_nr, Pertes_Produits,Pertes_Articles
INTO #TMP1
  FROM AUBFRCOGNOSSQL.[ODS].[dbo].[ODS_PIQUICK_Pertes]
  where CommercialDate >= GETDATE ()-31
  and Marche_seq=2
select s.datval,s.rest_nr,s.mtprod,s.mtart
INTO #TMP2
from
(
SELECT datval,rest_nr,mtprod,mtart
  FROM AUBFRCOGNOSSQL.[ODS].[dbo].[res_per]
  where datval >= GETDATE()-31
  and marche_seq=2
  and mtprod is not null
  )
  as s
  Select ROW_NUMBER()OVER (ORDER BY a.commercialdate) AS Row, a.CommercialDate
		--,a.Pays_seq
		--,a.Marche_seq
		,a.Rest_nr
		,a.Pertes_Produits
		,b.mtprod
		,a.Pertes_Articles
		,b.mtart
		,a.Pertes_Produits-b.mtprod as  Ecarts_Produit
		,a.Pertes_Articles-b.mtart as Ecarts_Articles
  from #TMP1 a
  join #TMP2 b
  on a.Rest_nr=b.rest_nr and a.CommercialDate=b.datval
  and a.Pertes_Articles=b.mtart
  and a.Pertes_Produits=b.mtprod
  where a.Pertes_Produits-b.mtprod <>0
  and a.Pertes_Articles-b.mtart <>0
  order by 1,2


  
drop table #tmp1
drop table #tmp2