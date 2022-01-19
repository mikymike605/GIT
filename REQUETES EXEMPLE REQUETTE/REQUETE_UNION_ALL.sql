

--DECLARE @debut_date		datetime
--DECLARE @fin_date		datetime


--SELECT @debut_date = getdate()-8
--SELECT @fin_date = getdate()-1 


CREATE TABLE #Table1
(	Restaurantcode	int,
	InvoiceId		bigint,
	Commercialdate	date,
	Total			money
)

CREATE TABLE #Table2
(	Restaurantcode	int,
	InvoiceId		bigint,	
	Fiscaldate		date,
	description		varchar (50),
	MDID			int,
	Total			money
)

Insert into #Table1
SELECT RestaurantUniqueID, InvoiceID, CommercialDate,SUM (CA_Net_TTC)
FROM [ODS].[dbo].[ODS_Ticket_unifie]
  where RestaurantUniqueID=20040091
  and CommercialDate between '20160101' and '20160101'
  and FlagDeleted = 0
  and FlagPosted=1
  and FlagTraining=0
  --and InvoiceNumber=1747774
  group by RestaurantUniqueID, InvoiceID, CommercialDate

  --UNION 
Insert into #Table2
SELECT distinct [Id_Restaurant],InvoiceID,CommercialDate,description, mdid, sum (Amount)
FROM [ODS].[dbo].[ODS_Payment] 
where id_Restaurant=20040091
--and  MDID=3
and CommercialDate between '20160101' and '20160101'
--and Invoiceid like '%1747774'
group by [Id_Restaurant],invoiceid,CommercialDate,description, mdid


  Select a.Restaurantcode, a.InvoiceId,a.Commercialdate,a.Total,b.Restaurantcode,b.InvoiceId,b.Fiscaldate,b.Total,b.description,b.MDID, sum (a.Total-b.Total)
  from #Table1 A
  inner join #Table2 b
  on A.InvoiceId=B.InvoiceId
  where b.MDID <>4
  --and sum (a.Total-b.Total) >0
  group by a.Restaurantcode, a.InvoiceId,a.Commercialdate,a.Total,b.Restaurantcode,b.InvoiceId,b.Fiscaldate,b.Total,b.description,b.MDID
  --having sum (a.Total-b.Total) <>1
  order by A.InvoiceId


  DROP TABLE #Table1
  DROP TABLE #Table2

