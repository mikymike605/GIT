DECLARE @DateD varchar(50) 
--SET @DateD =GetDate()-7
----DECLARE @DateF date 
----SET @DateF =GetDate()-1
DECLARE Date_Cursor CURSOR FOR  

/****** Script for SelectTopNRows command from SSMS  ******/
Select cast (calendardate as date) FROM AdminSQL.dbo.Calendar  
where cast (calendardate as date) >=cast(getdate()-3 as date)
and cast (calendardate as date)  <=cast(getdate() as date) 
--and YEAR (calendardate)=2019 
--and month (calendardate)=2

OPEN Date_Cursor  
		FETCH NEXT FROM Date_Cursor INTO @DateD 
WHILE @@FETCH_STATUS =0
    BEGIN 
	PRINT '***********'+@DateD+'***************'
	

DECLARE @restau varchar(250)
DECLARE Rest_Cursor CURSOR FOR  

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT distinct (bk)
  FROM AdminSQL.[dbo].[SHP_BK_SHAREPOINT_RESTAURANT]
  WHERE RestaurantUniqueID like '8004%' 
  ORDER BY BK  

OPEN Rest_Cursor  
		FETCH NEXT FROM Rest_Cursor INTO @restau 

WHILE @@FETCH_STATUS = 0
    BEGIN 
	--PRINT @restau
	FETCH  NEXT FROM Rest_Cursor INTO @restau 
  /************ DELETE RESTAU PAR DATE ************/
   --DELETE FROM [AdminSQL].[dbo].[TICKET_UNIFIE] where CommercialDate =@DateD and RestaurantCode=@restau 
 --GROUP BY RestaurantCode
 -- Having count(*) >1
SELECT CommercialDate, count (distinct(RestaurantUniqueID)), count(*)
 FROM [AdminSQL].[dbo].[TICKET_UNIFIE]
  where CommercialDate < @DateD
   group by  CommercialDate--year(CommercialDate), month (CommercialDate),day (CommercialDate)
  order by 1

      END;  
CLOSE Rest_Cursor;  
DEALLOCATE Rest_Cursor; 
     --END;  
	 FETCH  NEXT FROM Date_Cursor INTO @DateD 
	 END
CLOSE Date_Cursor;  
DEALLOCATE Date_Cursor; 

