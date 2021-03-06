/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [Id_Restaurant]
      ,[dDebut]
      ,[Marche_seq]
      ,[Pays_seq]
      ,[Rest_nr]
      ,[dFin]
      ,[RestaurantCode]
  FROM [ODS].[dbo].[MDP_Rest_Borne]
  where Rest_nr in (535,265,091)
  
  update MDP_Rest_Borne  
  set
  dDebut='20130201'
  where dDebut='20120201'
  and Rest_nr in (535,265,091)
  
  
  
  
  
  update MDInvoiceDetail
  set 
  TaxIdApplied1=4
  from MDInvoiceDetail D
   inner join MDInvoice I  on I.InvoiceId=D.InvoiceId
  where I.FiscalDate between '20140101' and '20141115'
  and I.RestaurantCode in (7903,7904)
  and D.TaxIdApplied1 is null
  