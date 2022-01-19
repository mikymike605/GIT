

EXEC xp_cmdshell 'bcp.exe SID_PRD.DWH.F_PRODUCT_TIMESLOT format nul -T -n -f D:\Share_SQL\Archive_20131231\FG_F_PRODUCT_TIMESLOT.FMT -S KINGSIDSQLPRD'

EXEC xp_cmdshell 'bcp.exe "select * from SID_PRD.DWH.F_PRODUCT_TIMESLOT where SID_DATE <=''20131231''" queryout "D:\Share_SQL\Archive_20131231\F_PRODUCT_TIMESLOT_ARCHIVE.txt" -f "D:\Share_SQL\Archive_20131231\FG_F_PRODUCT_TIMESLOT.FMT" -n -T -S'

--DELETE from SID_PRD.ODS.MD5_PAYMENT where year (commercialdate) = 2013 and MONTH (commercialdate)=01
--DELETE from SID_PRD.ODS.MD5_PAYMENT where year (commercialdate) = 2013 and MONTH (commercialdate)=02
--DELETE from SID_PRD.ODS.MD5_PAYMENT where year (commercialdate) = 2013 and MONTH (commercialdate)=03
--DELETE from SID_PRD.ODS.MD5_PAYMENT where year (commercialdate) = 2013 and MONTH (commercialdate)=04
--DELETE from SID_PRD.ODS.MD5_PAYMENT where year (commercialdate) = 2013 and MONTH (commercialdate)=05
--DELETE from SID_PRD.ODS.MD5_PAYMENT where year (commercialdate) = 2013 and MONTH (commercialdate)=06
--DELETE from SID_PRD.ODS.MD5_PAYMENT where year (commercialdate) = 2013 and MONTH (commercialdate)=07
--DELETE from SID_PRD.ODS.MD5_PAYMENT where year (commercialdate) = 2013 and MONTH (commercialdate)=08
--DELETE from SID_PRD.ODS.MD5_PAYMENT where year (commercialdate) = 2013 and MONTH (commercialdate)=09
--DELETE from SID_PRD.ODS.MD5_PAYMENT where year (commercialdate) = 2013 and MONTH (commercialdate)=10
--DELETE from SID_PRD.ODS.MD5_PAYMENT where year (commercialdate) = 2013 and MONTH (commercialdate)=11
--DELETE from SID_PRD.ODS.MD5_PAYMENT where year (commercialdate) = 2013 and MONTH (commercialdate)=12




SELECT count (*) from SID_PRD.ODS.MD5_PAYMENT where year (commercialdate) = 2013 and MONTH (commercialdate)=01
 


select 'ODS.TICKET_UNIFIE',count(*) from sid_prd.ODS.TICKET_UNIFIE where commercialdate <='20131231'
union
select 'ODS.MD5_INVOICE_DETAIL',count(*) from sid_prd.ODS.MD5_INVOICE_DETAIL where commercialdate <='20131231'
union 
select 'ODS.MD8_TICKET',count(*) from sid_prd.ODS.MD8_TICKET where commercialdate <='20131231'
union 
select  'ODS.SEM_TICKET',count(*) from sid_prd.ODS.SEM_TICKET where commercialdate <='20131231'
union
select 'DWH.F_PRODUCT',count(*) from sid_prd.DWH.F_PRODUCT where SID_DATE <='20131231'
union
select 'DWH.F_PRODUCT_TIMESLOT',count(*) from sid_prd.DWH.F_PRODUCT_TIMESLOT where SID_DATE <='20131231'
union
select 'ODS.MD5_PAYMENT',count(*) from sid_prd.ODS.MD5_PAYMENT where commercialdate <='20131231'
union
select 'ODS.MD5_INVOICE',count(*) from sid_prd.ODS.MD5_INVOICE where commercialdate <='20131231'
union
select 'ODS.REB_INVOICEDETAIL',count(*) from sid_prd.ODS.REB_INVOICEDETAIL where commercialdate <='20131231'

select 'ODS.TICKET_UNIFIE',min (commercialdate) from sid_prd.ODS.TICKET_UNIFIE
union
select 'ODS.MD5_INVOICE_DETAIL',min (commercialdate) from sid_prd.ODS.MD5_INVOICE_DETAIL
union
select 'ODS.MD8_TICKET',min (commercialdate) from sid_prd.ODS.MD8_TICKET
union
select  'ODS.SEM_TICKET',min (commercialdate) from sid_prd.ODS.SEM_TICKET
union
select 'DWH.F_PRODUCT',min (sid_date) from sid_prd.DWH.F_PRODUCT
union
select 'DWH.F_PRODUCT_TIMESLOT',min (sid_date) from sid_prd.DWH.F_PRODUCT_TIMESLOT
union
select 'ODS.MD5_PAYMENT',min (commercialdate) from sid_prd.ODS.MD5_PAYMENT
union
select 'ODS.MD5_INVOICE',min (commercialdate) from sid_prd.ODS.MD5_INVOICE
union
select 'ODS.REB_INVOICEDETAIL',min (commercialdate) from sid_prd.ODS.REB_INVOICEDETAIL
