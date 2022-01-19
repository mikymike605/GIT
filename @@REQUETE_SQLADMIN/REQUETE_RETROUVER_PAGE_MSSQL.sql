SELECT * FROM sys.indexes WHERE object_id=550397130

DBCC IND (0,'ODS.SEM_TICKET',1)



SELECT sys.fn_PhysLocFormatter(%%physloc%%) PageId, *
FROM ODS.SEM_TICKET
where sys.fn_PhysLocFormatter(%%physloc%%) = '(1:116705537)'
GO

--DBCC CHECKtable('ODS.SEM_TICKET') WITH NO_INFOMSGS, ALL_ERRORMSGS;
--GO