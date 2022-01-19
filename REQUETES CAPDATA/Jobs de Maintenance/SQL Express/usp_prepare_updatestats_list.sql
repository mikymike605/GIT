USE AdminSQL
GO
IF EXISTS (SELECT NULL FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA='dbo' AND ROUTINE_NAME='usp_prepare_updatestats_list')
	DROP PROCEDURE dbo.usp_prepare_updatestats_list
GO

--------------------------------------------------------------------------------------------------------------
-- Stored Procedure dbo.usp_prepare_updatestats_list
--------------------------------------------------------------------------------------------------------------
-- @Author: CapData
-- @CreationDate: 20090505
-- @Parameters: 
--          
--------------------------------------------------------------------------------------------------------------
-- @Comment: select all user tables for maintenance and build sql_command for update statistics
-- 
--------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE dbo.usp_prepare_updatestats_list
AS

	SET NOCOUNT ON

	IF EXISTS (SELECT NULL FROM AdminSQL.INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME = 'dba_statistic_operation')
		DROP TABLE AdminSQL.dbo.dba_statistic_operation 

	CREATE TABLE AdminSQL.dbo.dba_statistic_operation 
	(
		id int IDENTITY(1,1), databaseid int NOT NULL, objectid int  NOT NULL, databasename sysname, schemaname sysname
		, objectname sysname, sql_command varchar(4000), opstatus smallint, dt_create datetime, dt_op datetime	
	)

	DECLARE @sql_command varchar(8000), @i int, @imax int
	DECLARE @db TABLE (id int IDENTITY(1,1), database_id int, database_name sysname)

	INSERT INTO @db
	SELECT database_id, name FROM sys.databases WHERE database_id>5  AND is_read_only=0 AND state=0

	SET @imax=@@ROWCOUNT
	SET @i=0

	WHILE @i <@imax
	BEGIN
		SET @i=@i+1
		SELECT @sql_command='INSERT INTO AdminSQL.dbo.dba_statistic_operation (databaseid , objectid , databasename , schemaname , objectname  
																			, opstatus , dt_create,sql_command)
					SELECT '+CAST(database_id AS varchar)+', o.object_id, ''['+database_name+']'', QUOTENAME(s.name) AS sch
							, QUOTENAME(o.name) AS obj, 1, CONVERT(varchar(10),GETDATE(),112)
							,N''USE ['+database_name+'] UPDATE STATISTICS ''+QUOTENAME(s.name)+''.''+QUOTENAME(o.name)---+'' WITH FULLSCAN''
						FROM ['+database_name+'].sys.objects o	INNER JOIN ['+database_name+'].sys.schemas s ON o.schema_id = s.schema_id
					WHERE 1=1
					AND o.type =''U'''
		FROM @db WHERE id=@i
		
		EXEC (@sql_command)
	END

