/****** Script for SelectTopNRows command from SSMS  ******/
SELECT h.Rest_nr
      ,h.CommercialDate
      ,d.DiscountMDID
      ,d.Discount
      ,SUM(h.Total) Total
      ,COUNT(DISTINCT H.InvoiceId)
      ,SUM(-d.DiscountAmount) [Bon Pub]
      ,SUM(d.Quantity*d.PxUnitTTC) PxTTC
  FROM ODS_InvoiceDetail d
  INNER JOIN ODS_Invoice h
  ON d.InvoiceId = h.InvoiceId
  WHERE h.Id_Restaurant = 20040636
  AND  h.CommercialDate BETWEEN '10/20/2012' AND '11/18/2012'
  AND  d.DiscountMDID IS NOT null
  AND d.DiscountMDID = 1
  GROUP BY h.Rest_nr
      ,h.CommercialDate
      ,d.DiscountMDID
      ,d.Discount
      
SELECT h.Rest_nr
      ,h.CommercialDate
      ,d.DiscountMDID
      ,h.InvoiceNumber
      ,d.Discount
      ,-d.DiscountAmount [Bon Pub]
      ,d.Quantity*d.PxUnitTTC PxTTC
      ,d.[Description]
  FROM ODS_InvoiceDetail d
  INNER JOIN ODS_Invoice h
  ON d.InvoiceId = h.InvoiceId
  WHERE h.Id_Restaurant = 20040636
  AND  h.CommercialDate BETWEEN '10/20/2012' AND '11/18/2012'
  AND  d.DiscountMDID IS NOT null
  AND d.DiscountMDID = 1
      
      
 SELECT h.Rest_nr
      ,d.DiscountMDID
      ,d.Discount
      ,SUM(h.Total) Total
      ,COUNT(DISTINCT d.InvoiceId)
      ,SUM(-d.DiscountAmount) [Bon Pub]
      ,SUM(d.Quantity*d.PxUnitTTC) PxTTC
  FROM ODS_InvoiceDetail d
  INNER JOIN ODS_Invoice h
  ON d.InvoiceId = h.InvoiceId
  WHERE h.Id_Restaurant = 20040636
  AND  h.CommercialDate BETWEEN '10/22/2012' AND '11/18/2012'
  AND  d.DiscountMDID IS NOT null
  GROUP BY h.Rest_nr
      ,d.DiscountMDID
      ,d.Discount