 IF OBJECT_ID('tempdb..#cal') IS NOT NULL 
        DROP TABLE tempdb..#cal
		
DECLARE @deb date = getdate()-20
DECLARE  @fin date = getdate()-17 ;


with calendrier as 
(   select @deb date
    union all
    select DATEADD(day, 1, date)
    from calendrier
    where DATEADD(day, 1, date) <= @fin )

select date into #cal from calendrier
option(maxrecursion 0)
print @deb
print @fin
DECLARE @date varchar(250)
DECLARE Date_Cursor CURSOR FOR  
select * from #cal

OPEN Date_Cursor  
	FETCH NEXT FROM Date_Cursor INTO @date 
WHILE @@FETCH_STATUS = 0
    BEGIN 
	--PRINT '***************'+@date+'***************'
	--PRINT @loop
	FETCH  NEXT FROM Date_Cursor INTO @date 
	END;  
	
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
   --TRUNCATE TABLE [AdminSQL].[dbo].[TICKET_UNIFIE]

SELECT CommercialDate, RestaurantCode, count(*)
 FROM [AdminSQL].[dbo].[TICKET_UNIFIE]
  where CommercialDate = @date
  and RestaurantCode = @restau
  group by  CommercialDate,RestaurantCode
  HAving count(*) > 1
  -- @date(CommercialDate), month (CommercialDate),day (CommercialDate)
  --order by 1
  PRINT '***************'+@date+'***************'
  PRINT @restau
      END;  
CLOSE Rest_Cursor;  
DEALLOCATE Rest_Cursor; 
     --END;  
	 --FETCH  NEXT FROM Date_Cursor INTO @date 
	 --END

CLOSE Date_Cursor;  
DEALLOCATE Date_Cursor; 

drop table #cal
