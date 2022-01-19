USE [AdminSQL]
GO

DECLARE @return_code INT = 1
EXEC @return_code = sp_msforeachdb 'USE [?];DBCC checkdb WITH NO_INFOMSGS'
RETURN
