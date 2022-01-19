select distinct (mu_restaurantcode) -2000, SUM (ca_net_ttc)
from ODS..ods_ticket
where pays_seq=1
--and mu_restaurantcode=2401
and commercialdate = '20151105'
group by mu_restaurantcode


select distinct (id_unique_restaurant) -10010000, sum (TOT_NET_REVENUE_TTC)
from dwh_com..f_restaurant
where id_unique_restaurant like '1001%'
and sid_date = '20151105'
and TOT_NET_REVENUE_TTC <>0
group by id_unique_restaurant



select distinct (id_unique_restaurant) -10010000, sid_date
 from dwh_com..f_restaurant R
where id_unique_restaurant like '1001%'
and sid_date = '20151105'
and not exists
( select *
from   ODS..ods_ticket T
where r.sid_date=T.commercialdate
and (r.id_unique_restaurant -10010000)=(T.mu_restaurantcode-2000)
)

 