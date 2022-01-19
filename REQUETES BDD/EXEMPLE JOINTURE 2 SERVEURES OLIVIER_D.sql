select  RestaurantCode
	   ,CommercialDate
	   ,ODS_Ticket
	   ,ODS_CA_Net_HT
	   ,FL_Ticket
	   ,FL_CA_Net_HT
FROM (
	select  o.RestaurantCode
		   ,o.CommercialDate
		   ,o.Ticket ODS_Ticket
		   ,o.CA_Net_HT ODS_CA_Net_HT
		   ,f.Tickets FL_Ticket
		   ,f.CA_Net_HT FL_CA_Net_HT
	FROM (

		select  RestaurantCode
			   ,CommercialDate
			   ,Ticket
			   ,CA_Net_HT
		from VILFRCOGNOSSQL.ods.dbo.ods_rest_jour 
		where marche_seq=2
		and commercialdate >='20130101'
		and import_statut =2 
	) o
	INNER JOIN (
		select RestaurantCode
			,CommercialDate
			,Tickets
			,Ca_net_HT
		from dbo.FL_Rest_Jour 
		where marche_seq=2
		and commercialdate >='20130101'
	) f
	ON   o.RestaurantCode = f.RestaurantCode
	AND  o.CommercialDate = f.CommercialDate
) x
WHERE FL_Ticket =0

