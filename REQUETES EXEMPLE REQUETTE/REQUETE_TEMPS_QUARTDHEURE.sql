/****** Script for SelectTopNRows command from SSMS  ******/
SELECT DATEADD(MINUTE, [Periode]*15, '2015-01-15 00:00:00') As [Id_Temps_Periode]
  FROM [ODS].[dbo].[ODS_Ticket]
  where CommercialDate = '20160201'
  order by 1

  SELECT DATEPART(HOUR, DATEADD(MINUTE, [periode]*15, '2009-01-01 00:00:00')) AS Heure
  FROM [ODS].[dbo].[ODS_Ticket]
  where CommercialDate = '20160201'
    order by 1