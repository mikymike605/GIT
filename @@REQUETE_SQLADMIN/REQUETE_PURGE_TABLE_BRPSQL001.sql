--SELECT * FROM dbo.VUEMAgentsLog 

SELECT 'DELETE FROM CitrixWEM.dbo.VUEMAgentsLog WHERE YEAR (Timestamp)='''+CONVERT (VARCHAR (MAX),YEAR (Timestamp))+''' AND MONTH(Timestamp)='''+CONVERT (VARCHAR (MAX),MONTH(Timestamp))+''''
,COUNT (*) NBR_LIGNES,YEAR (Timestamp) YEAR,MONTH(Timestamp) MONTH 
FROM CitrixWEM.dbo.VUEMAgentsLog 
GROUP BY YEAR (Timestamp) ,MONTH(Timestamp)  
ORDER BY YEAR (Timestamp) ,MONTH(Timestamp)  