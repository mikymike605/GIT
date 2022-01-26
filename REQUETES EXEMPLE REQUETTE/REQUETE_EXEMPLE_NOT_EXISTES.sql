DECLARE @date1 date
set @date1 = getdate ()-2
DECLARE @date2 date
set @date2 = getdate ()-1


SELECT  store_uid, date
FROM [SID_PRD].[ODS].[SEM_BUSINESS_DATES] a
where date = @date1
and not exists
( 
SELECT  store_uid, date
FROM [SID_PRD].[ODS].[SEM_BUSINESS_DATES] b
where date = @date2 and a.store_uid=b.store_uid 
)

