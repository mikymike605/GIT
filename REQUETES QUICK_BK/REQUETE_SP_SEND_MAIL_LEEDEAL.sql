BEGIN
EXEC msdb.dbo.sp_send_dbmail
@profile_name= 'EnvoiMail',
@recipients= 'mikael.hamchaoui@bkqservices.com',
@subject= 'Monitor Data Insert LEEDEAL',
@query= 'DECLARE @tableHTML  NVARCHAR(MAX) ;  
  declare @deb date = cast (getdate ()-3 as date)
declare @fin date = cast (getdate ()-1 as date)
declare @diff int = datediff(day, @deb, @fin)
--PRINT ''******************''+cast (@deb as varchar)+''**************************''
--PRINT ''******************''+cast (@fin as varchar)+''**************************'' 
--PRINT ''******************''+cast (@fin as varchar)+''**************************'' datediff(day, @deb, @fin)
declare @loop int = 0
while @loop <= @diff
begin  

SELECT   distinct(RestaurantUniqueID)RestaurantUniqueID,CommercialDate, count(*)count
FROM kingsidsqlprd.SID_PRD.ODS.[TICKET_UNIFIE] a
 where CommercialDate = cast (dateadd(day, @loop, @deb) as date)
and RestaurantUniqueID like ''80040%''
and not exists
( 
SELECT  distinct(RestaurantUniqueID)RestaurantUniqueID,CommercialDate, count(*)count
FROM kingsidsqlprd.SID_PRD.ODS.[TICKET_UNIFIE_temp] b
  where CommercialDate = cast (dateadd(day, @loop, @deb) as date)and a.RestaurantUniqueID=b.RestaurantUniqueID 
and RestaurantUniqueID like ''80040%''
group by RestaurantUniqueID,CommercialDate
)
group by  a.RestaurantUniqueID,CommercialDate
--order by 1

SET @loop = @loop +1

end'
END 