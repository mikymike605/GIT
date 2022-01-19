/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [DBAtools].[dbo].[BlitzFirst]
where cast (CheckDate as datetime)>=DATEADD(MINUTE,-5,GETDATE())

--EXEC DBAtools..sp_BlitzCache  @SortOrder = 'reads'

/* To see the waits over a current 5-second period: 
   Pour voir les attentes sur une période de 5 secondes: */
EXEC DBAtools..sp_BlitzFirst;

/* OR, to see waits since startup, skip taking a sample:
OU, pour voir les attentes depuis le démarrage, passez un échantillon */
EXEC DBAtools..sp_BlitzFirst @Seconds = 0;


WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p)
SELECT  st.text,
        qp.query_plan,
        qs.* 
FROM    (
    SELECT  TOP 50 *
    FROM    sys.dm_exec_query_stats
    ORDER BY total_worker_time DESC
) AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE qp.query_plan.value('count(//p:MissingIndexGroup)', 'int') > 10
and cast (last_execution_time as datetime)>=DATEADD(DAY,-5,GETDATE())
