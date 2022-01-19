USE AdminSQL
GO
IF EXISTS (SELECT NULL FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA='dbo' AND ROUTINE_NAME='usp_operate_reindex_list')
	DROP PROCEDURE dbo.usp_operate_reindex_list
GO

--------------------------------------------------------------------------------------------------------------
-- Stored Procedure dbo.usp_operate_reindex_list
--------------------------------------------------------------------------------------------------------------
-- @Author: CapData
-- @CreationDate: 20090505
-- @Parameters: 
--          
--------------------------------------------------------------------------------------------------------------
-- @Comment: select and execute a reindex/reorganize command in reindex list	
--				return 1 if command has been processed
--				return 0 if no command need to be processed
--------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE dbo.usp_operate_reindex_list
AS
	SET NOCOUNT ON

	DECLARE @id int,@sql_command varchar(8000)

	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	BEGIN TRANSACTION
	
	SELECT TOP 1 @id=id FROM AdminSQL.dbo.dba_index_operation WHERE opstatus=1
	
	IF @id IS NULL
	BEGIN
		COMMIT TRANSACTION
		RETURN 0
	END
	ELSE
	BEGIN
		UPDATE AdminSQL.dbo.dba_index_operation SET opstatus=2 WHERE id=@id
	END

	COMMIT TRANSACTION
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	
	BEGIN TRY
		
		SELECT @sql_command=sql_command
		FROM AdminSQL.dbo.dba_index_operation WHERE id=@id
		
		EXEC (@sql_command)
			
		UPDATE AdminSQL.dbo.dba_index_operation SET opstatus=3, dt_op=GETDATE()
		WHERE id=@id
	END TRY
	BEGIN CATCH
		UPDATE AdminSQL.dbo.dba_index_operation SET opstatus=-1, dt_op=GETDATE()
		WHERE id=@id
		PRINT ERROR_MESSAGE()
	END CATCH

RETURN 1