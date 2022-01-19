
SELECT YEAR (DateEcritureAnal)YEAR,MONTH  (DateEcritureAnal)MONTH,COUNT (*) 
FROM [dbo].[Ecritures Comptabilité analytique]
GROUP BY YEAR (DateEcritureAnal),MONTH  (DateEcritureAnal)
ORDER BY YEAR (DateEcritureAnal) dESC,MONTH  (DateEcritureAnal) DESC


SELECT YEAR (DateEcriture)YEAR,MONTH  (DateEcriture)MONTH,COUNT (*)
FROM [dbo].[Ecritures Comptabilité générale]
GROUP BY YEAR (DateEcriture),MONTH  (DateEcriture)
ORDER BY YEAR (DateEcriture) dESC,MONTH  (DateEcriture) DESC