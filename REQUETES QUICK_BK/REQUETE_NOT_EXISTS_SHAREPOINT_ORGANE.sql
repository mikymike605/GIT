SELECT distinct (RestaurantCode), cast (FiscalDate as date), SUM (Total) 
FROM QuickMDCube_FR..MDInvoice
where cast (FiscalDate as date)>= GETDATE ()-100
and RestaurantCode in (1200)
and Total >0
group by cast (FiscalDate as date),RestaurantCode
order by cast (FiscalDate as date) desc

SELECT *
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT] b
where marche_seq=2
and pays_seq=4
and dt_fin is null
and flag_active=1
and statutvalue like 'A.%'
--and rest_nr in (726)
and not exists
( 
select *
FROM KINGSIDSQLPRD.QUICK_REF.DBO.ORGANNE a
WHERE CLOSED=0 and marche_seq=2 and pays_seq=4  and fin_date is null and debut_date >='20190401'
--and rest_nr=359
and a.rest_nr=b.rest_nr
--and closed=0
)



select *
FROM KINGSIDSQLPRD.QUICK_REF.DBO.ORGANNE b
WHERE CLOSED=0 and marche_seq=2 and pays_seq=4  and fin_date is null and debut_date >='20190401'
and closed=0
--and rest_nr in (359,516,746,766)
and not exists
( 
SELECT *
FROM KINGSIDSQLPRD.SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT] a
where marche_seq=2
and pays_seq=4
and dt_fin is null
and flag_active=1
and statutvalue like 'A.%'
--and rest_nr in (200,216)
and a.rest_nr=B.rest_nr
)


SELECT 'VILFRSQLWEB.DBOper.dbo.por_organne',* FROM VILFRSQLWEB.DBOper.dbo.por_organne
where  rest_nr in (359,516,766)
and pays_seq=4
and marche_seq=2
and lang_desc =1

--UPDATE DBOper.dbo.por_organne
--set closed=1
--where rest_nr=746

SELECT 'VILFRCOGNOSSQL.QUICK_REF.DBO.POR_ORGANNE',* FROM VILFRCOGNOSSQL.QUICK_REF.DBO.POR_ORGANNE
where  rest_nr in (359,516,766)
and pays_seq=4
and marche_seq=2
and lang_desc =1

SELECT 'KINGSIDSQLPRD.QUICK_REF.DBO.POR_ORGANNE',* FROM KINGSIDSQLPRD.QUICK_REF.DBO.POR_ORGANNE
where  rest_nr in (359,516,766)
and lang_desc =1
--and pays_seq=4
--and marche_seq=2
--and fin_date is null

SELECT 'KINGSIDSQLPRD.QUICK_REF.DBO.ORGANNE',* FROM KINGSIDSQLPRD.QUICK_REF.DBO.ORGANNE
where  pays_seq=4
and marche_seq=2
and fin_date is null
SELECT 'VILFRSQLWEB.DBOper.dbo.por_organne',* FROM VILFRSQLWEB.DBOper.dbo.por_organne
where  rest_nr in (359,516,766)
and pays_seq=4
and marche_seq=2
and lang_desc =1

SELECT *--DISTINCT rest_nr+1000 as RestaurantCode 
FROM KINGSIDSQLPRD.QUICK_REF.DBO.ORGANNE WHERE CLOSED=0 and rest_nr=002 and fin_date is null 

SELECT *--DISTINCT rest_nr+1000 as RestaurantCode 
FROM KINGSIDSQLPRD.QUICK_REF.DBO.ORGANNE WHERE CLOSED=0 and marche_seq=2 and pays_seq=4  and fin_date is null and debut_date >='20190101'
--and rest_nr in (002,517)