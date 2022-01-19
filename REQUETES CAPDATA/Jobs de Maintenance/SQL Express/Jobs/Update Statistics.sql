USE [AdminSQL]
GO

DECLARE @return_code int = 0
EXEC @return_code = AdminSQL.dbo.usp_prepare_updatestats_list

IF @return_code <> 0
BEGIN
RETURN
END

SET @return_code = 1
WHILE (@return_code =1)
BEGIN
	EXEC @return_code = AdminSQL.dbo.usp_operate_updatestats_list
END

RETURN
