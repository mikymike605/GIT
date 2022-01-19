DECLARE @restaurantcode varchar(250) 
DECLARE @requete varchar(5000) 
DECLARE product_cursor CURSOR FOR 


SELECT distinct (RestaurantCode)  FROM [QuickMDCube_FR]..vw_MDRestaurant where closed=0

OPEN product_cursor 
FETCH FROM product_cursor INTO @restaurantcode 

WHILE @@FETCH_STATUS = 0 
BEGIN 
set @restaurantcode = @restaurantcode

PRINT @restaurantcode 
set @requete = '



DECLARE @debut_date1		datetime
DECLARE @fin_date1		datetime


SELECT @debut_date = getdate()-10
SELECT @fin_date = getdate()-1 

select distinct RestaurantCode, FiscalDate, sum (Total)--,COUNT(InvoiceId) --,TaxIdApplied1,invoicenumber
--into #TMP2
from QuickMDCube_FR..mdinvoice i
inner join QuickMDCube_FR..mdinvoicedetail d on i.InvoiceId=d.InvoiceId
where fiscaldate >= ''@debut_date1'' and i.fiscaldate <= ''@fin_date1''
and i.FlagDeleted=0
and i.FlagPosted=1
and i.FlagTraining=0
and D.TaxIdApplied1 is null
and restaurantcode =@restaurantcode
--and d.category like ''%liquides%''
--and d.unitprice =0
--and d.inclusivetax <>0
group by RestaurantCode,FiscalDate--,i.InvoiceId--,TaxIdApplied1,invoicenumber
order by restaurantcode, FiscalDate
' ; 
	  
PRINT @requete 

  --EXEC  (@requete) 
                                                                
FETCH FROM product_cursor INTO @restaurantcode 
END 
CLOSE product_cursor 
DEALLOCATE product_cursor 
GO


