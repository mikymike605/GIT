/****** Script for SelectTopNRows command from SSMS  ******/
SELECT count (*)NBR_Tickets, YEAR (termine_le)YEAR,'MIKAEL', MONTH(termine_le) MONTH
  FROM [EVO_DATA50004].[50005].[E_V_tickets]
  where [intervenant_cloturant] like '%HAMCH%'
  group by YEAR (termine_le), MONTH(termine_le) 
  --order by YEAR (termine_le)desc--, MONTH(termine_le)desc  
UNION ALL
SELECT count (*)NBR_Tickets, YEAR (termine_le)YEAR,'TANIA', MONTH(termine_le) MONTH
  FROM [EVO_DATA50004].[50005].[E_V_tickets]
  where [intervenant_cloturant] like '%TANIA%'
  group by YEAR (termine_le), MONTH(termine_le) 
  --order by YEAR (termine_le)desc--, MONTH(termine_le)desc  
UNION ALL
SELECT count (*)NBR_Tickets, YEAR (termine_le)YEAR,'ALAIN', MONTH(termine_le) MONTH
  FROM [EVO_DATA50004].[50005].[E_V_tickets]
  where [intervenant_cloturant] like '%HUMBER%'
  group by YEAR (termine_le), MONTH(termine_le) 
  order by YEAR (termine_le)desc, MONTH(termine_le)desc,1 desc  
