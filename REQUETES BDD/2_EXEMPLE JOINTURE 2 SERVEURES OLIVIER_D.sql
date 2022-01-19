select  *
FROM (
	select *
	FROM (
		select  *
		from quickmdcube_be8.dbo.MDInvoice
		where FiscalDate >='20130101'
		
	) o
	INNER JOIN (
		select *
		from dbo.FL_Rest_Jour 
		where marche_seq=2
		and commercialdate >='20130101'
	) f
	ON   o.RestaurantCode = f.RestaurantCode
	
) x
WHERE FL_Ticket =0

