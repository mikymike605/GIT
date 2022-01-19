------------TABLE VERIFICATION MB ET MT BELUX

create table #DATE_VERIF 
(
DATE_DATA date
)

declare @date_debut date
declare @date_fin date
select @date_debut='20120626'
select @date_fin='20120730'

--select @date_debut='20140501'
--select @date_fin='20140530'

while @date_debut<=@date_fin
begin 
insert into #DATE_VERIF (DATE_DATA)
values (@date_debut)
select @date_debut=DATEADD (day, 1, @date_debut)
end 

select * from 
(
select T1.DATE_DATA,T2.CommercialDate
--,T2.Marche_seq,T2.Pays_seq 
from #DATE_VERIF T1
left join MK_QA_Jour T2 on CAST(T2.CommercialDate AS DATE)=T1.DATE_DATA and T2.Pays_seq=2
--where T2.Marche_seq=1
) Resultat
where CommercialDate is NULL
order by DATE_DATA


drop table #DATE_VERIF

