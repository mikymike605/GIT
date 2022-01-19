SELECT distinct (YEAR(commercialdate)),MONTH(commercialdate),count(*)
 from ODS.TICKET_UNIFIE
 where $partition.FCT_SID_PRD_DWH_DATE(commercialdate)>=1 
 and year (commercialdate)=2018
group by (YEAR(commercialdate)),MONTH(commercialdate)
order by 1,2