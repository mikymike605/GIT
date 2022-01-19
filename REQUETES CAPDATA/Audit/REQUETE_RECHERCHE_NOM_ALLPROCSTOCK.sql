
DECLARE @servername varchar(250)
DECLARE @requete varchar(5000) 
DECLARE product_cursor CURSOR FOR   

SELECT ' USE ['+name+'] '  FROM [AdminMonitor].[dbo].[DbName] where Servername = '[AUBFRINFRASQL]' and name not in ('tempdb','ReportServerTempDB','ReportServer','model','master','msdb')

OPEN product_cursor  
FETCH NEXT FROM product_cursor INTO @servername  

IF @@FETCH_STATUS <> 0   PRINT '         <<None>>'       
WHILE @@FETCH_STATUS = 0  
    BEGIN  

	set @requete = '
	'+@SERVERNAME+'
SELECT '''+@SERVERNAME+'''='''+@SERVERNAME+''',sys.sysobjects.name, sys.syscomments.text
FROM sys.sysobjects INNER JOIN syscomments 
ON sys.sysobjects.id = sys.syscomments.id
WHERE sys.syscomments.text LIKE ''%EVENT%''
AND sys.sysobjects.type =''P''
ORDER BY sys.sysobjects.NAME

----Variante vue INFORMATION_SCHEMA.ROUTINES pour SP
SELECT '''+@SERVERNAME+'''='''+@SERVERNAME+''', ROUTINE_NAME, ROUTINE_DEFINITION 
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_DEFINITION LIKE ''%EVENT%'' 
AND ROUTINE_TYPE=''PROCEDURE''
ORDER BY ROUTINE_NAME


----Variante vue INFORMATION_SCHEMA.ROUTINES pour fonction
SELECT '''+@SERVERNAME+'''='''+@SERVERNAME+''',ROUTINE_NAME, ROUTINE_DEFINITION 
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_DEFINITION LIKE ''%EVENT%'' 
AND ROUTINE_TYPE=''FUNCTION''
ORDER BY ROUTINE_NAME

'

PRINT @requete 
--EXEC (@requete)
        FETCH NEXT FROM product_cursor INTO @servername  
	END  
CLOSE product_cursor  
DEALLOCATE product_cursor  
GO


--/****** Script for SelectTopNRows Mohamed.CHARGUI@bkqservices.com from SSMS  ******/
--TRUNCATE TABLE [AdminMonitor].[dbo].[DbName_v3]
--INSERT INTO [AdminMonitor].[dbo].[DbName_v3]
--([Servername]
--      ,[Name]
--      ,[database_id]
--      ,[create_date])
--SELECT  [Servername]
--      ,[Name]
--      ,[database_id]
--      ,[create_date]
--  FROM [AdminMonitor].[dbo].[DbName]
--  where Servername='[VILFRSQLWEB]'
--  --and Name like 'as%'
 