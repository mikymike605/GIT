

SELECT p.[Id_Restaurant]as Restaurantcode,RIGHT (p.InvoiceID,7)as invoiceid,p.CommercialDate,description, mdid, sum(x.ca_net) as ca_net,sum (Amount)as Amount
FROM [ODS].[dbo].[ODS_Payment] p
inner join
(
SELECT RestaurantUniqueID as Restaurantcode, T.InvoiceID, T.CommercialDate,SUM (CA_Net_TTC) as ca_net
FROM [ODS].[dbo].[ODS_Ticket_unifie] T
inner join [ODS].[dbo].ODS_Payment P
on T.invoiceid=P.InvoiceId
  where t.RestaurantUniqueID in (20040091,20040129,20040340,20040660)
  and T.CommercialDate between '20150101' and '20151231'
  and FlagDeleted = 0
  and FlagPosted=1
  and FlagTraining=0
  and p.mdid=3
  group by RestaurantUniqueID, T.InvoiceID, T.CommercialDate
) x
on x.Restaurantcode=p.[Id_Restaurant]
and x.InvoiceID =  p.InvoiceID
and x.CommercialDate = p.CommercialDate
where p.id_Restaurant in (20040091,20040129,20040340,20040660)
and p.CommercialDate between '20150101' and '20161231'
--and Invoiceid like '%1747774'
group by [Id_Restaurant],P.InvoiceId,P.CommercialDate,description, mdid	
order by Id_Restaurant,InvoiceId, CommercialDate

