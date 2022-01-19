USE [AdminSQL]
GO
/****** Object:  StoredProcedure [dbo].[usp_prepare_reindex_list]    Script Date: 19/09/2018 13:19:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--------------------------------------------------------------------------------------------------------------
-- Stored Procedure dbo.usp_prepare_reindex_list
--------------------------------------------------------------------------------------------------------------
-- @Author: CapData
-- @CreationDate: 20090505
-- @Parameters: 
--            exec [dbo].[usp_prepare_reindex_list] 
--------------------------------------------------------------------------------------------------------------
-- @Comment: select all user indexes that need a maintenance and build sql_command for reindex/reorganize
-- 
--------------------------------------------------------------------------------------------------------------

ALTER PROCEDURE [dbo].[usp_prepare_reindex_list]
AS

	SET NOCOUNT ON

	IF EXISTS (SELECT NULL FROM AdminSQL.INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME = 'dba_index_operation')
		DROP TABLE AdminSQL.dbo.dba_index_operation 

	CREATE TABLE AdminSQL.dbo.dba_index_operation 
	(
		id int IDENTITY(1,1), databaseid int NOT NULL, objectid int  NOT NULL, indexid int  NOT NULL, partitionid bigint  NOT NULL
		, databasename sysname, schemaname sysname, objectname sysname, indexname sysname, partitionnum bigint, nb_partition bigint,avg_frag_in_percent float,Indexsize_MB float,Indexsize_GB float
		, sql_command varchar(4000), opstatus smallint, dt_create datetime, dt_op datetime	
	)

	DECLARE @sql_command varchar(8000), @i int, @imax int, @databaseid int, @objectid int, @indexid int, @partition_number bigint
	DECLARE @db TABLE (id int IDENTITY(1,1), database_id int, database_name sysname)
	DECLARE @t TABLE (id int IDENTITY(1,1),databaseid int, objectid int, indexid int, partition_number bigint, sql_command varchar(8000))
	DECLARE @scanned_table TABLE (id int IDENTITY(1,1), database_id int, object_id int, index_id int, user_scans bigint)
	CREATE TABLE #index_stats (id int IDENTITY(1,1), database_id int, object_id int, index_id int
	, partition_number bigint, avg_page_space_used_in_percent float, avg_fragmentation_in_percent float,page_count bigint)


	INSERT INTO @db
	SELECT database_id, name FROM sys.databases WHERE database_id>4 AND is_read_only=0 AND state=0

	SET @imax=@@ROWCOUNT
	SET @i=0

	WHILE @i <@imax
	BEGIN
		SET @i=@i+1
		SELECT @sql_command='INSERT INTO AdminSQL.dbo.dba_index_operation (databaseid , objectid , indexid   , partitionid , databasename 
																			, schemaname , objectname , indexname , partitionnum 
																			, nb_partition,avg_frag_in_percent, Indexsize_MB, Indexsize_GB, opstatus , dt_create)
					SELECT '+CAST(database_id AS varchar)+', o.object_id, i.index_id, p.partition_id
							, ''['+database_name+']'', QUOTENAME(s.name) AS sch, QUOTENAME(o.name) AS obj, QUOTENAME(i.name) AS ind
							, p.partition_number, np.nb_partition,avg_fragmentation_in_percent
							,CAST(8 * SUM(au.used_pages)/1024.0 AS DECIMAL(18,2)) as Indexsize_MB
							, cast (8*SUM(au.used_pages)/1024.0/1024.0  AS DECIMAL(18,4))as Indexsize_GB
							, 0, CONVERT(varchar(10),GETDATE(),112)
						FROM ['+database_name+'].sys.objects o	INNER JOIN ['+database_name+'].sys.schemas s ON o.schema_id = s.schema_id
																INNER JOIN ['+database_name+'].sys.indexes i ON o.object_id = i.object_id
																INNER JOIN ['+database_name+'].sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
																INNER JOIN ['+database_name+'].sys.dm_db_partition_stats ps on ps.partition_id = p.partition_id
																INNER JOIN ['+database_name+'].sys.allocation_units au ON au.container_id = ps.partition_id
																INNER JOIN sys.dm_db_index_physical_stats(db_id(''?''), null, NULL, NULL, NULL) ips 
																	on ips.object_id=o.object_id and ips.index_id=i.index_id
																INNER JOIN (SELECT object_id, index_id, COUNT(*) AS nb_partition
																
																			FROM ['+database_name+'].sys.partitions WHERE index_id > 0 
																			GROUP BY object_id, index_id) np 
																		ON i.object_id=np.object_id AND i.index_id = np.index_id
						WHERE 1=1
						AND i.index_id > 0
						AND ps.used_page_count>1280
						AND o.type =''U''
						group by o.object_id, i.index_id, p.partition_id ,s.name,o.name,i.name, p.partition_number, np.nb_partition,ips.avg_fragmentation_in_percent'
		FROM @db WHERE id=@i
		--PRINT  (@sql_command)
		EXEC (@sql_command)
	END

	INSERT INTO @scanned_table
	SELECT database_id, object_id, index_id, user_scans 
	FROM sys.dm_db_index_usage_stats ius	
	WHERE user_scans <> 0 AND index_id>0

	INSERT INTO #index_stats EXEC sp_MSforeachdb 'Select database_id , object_id , index_id , partition_number , avg_page_space_used_in_percent, avg_fragmentation_in_percent,page_count from sys.dm_db_index_physical_stats(db_id(''?''), NULL, NULL, NULL, NULL) WHERE index_id > 0'
	
	UPDATE op SET sql_command=
		CASE WHEN avg_page_space_used_in_percent  < 70 
				THEN N'USE '+ op.databasename + N' ALTER INDEX '+ op.indexname + N' ON ' +  op.schemaname + N'.' + op.objectname + N' REBUILD'-- PARTITION ='+ + CAST(partitionnum AS NVARCHAR(10))+' WITH (SORT_IN_TEMPDB = OFF, ONLINE = ON)'
			 WHEN avg_fragmentation_in_percent > 30 --AND user_scans > 0 AND user_scans IS NOT NULL
				THEN N'USE '+ op.databasename + N' ALTER INDEX '+ op.indexname + N' ON ' +  op.schemaname + N'.' + op.objectname + N' REBUILD'-- PARTITION ='+ + CAST(partitionnum AS NVARCHAR(10))+' WITH (SORT_IN_TEMPDB = OFF, ONLINE = ON)'
			WHEN avg_fragmentation_in_percent <= 30 AND avg_fragmentation_in_percent > 10
				THEN N'USE '+ op.databasename + N' ALTER INDEX ' + op.indexname + N' ON ' + op.schemaname + N'.' + op.objectname + N' REORGANIZE'
			ELSE N'USE '+ op.databasename + N'-- NO OPERATIONS' END
			--+CASE WHEN NB_PARTITION>1 THEN  N' PARTITION=' + CAST(op.nb_partition AS varchar(10)) ELSE '' END
			+CASE WHEN NB_PARTITION>1 THEN  N' PARTITION ='+ + CAST(partitionnum AS NVARCHAR(10))+' WITH (SORT_IN_TEMPDB = OFF, ONLINE = ON)' ELSE '' END
			,opstatus=1
	FROM #index_stats ist	INNER JOIN AdminSQL.dbo.dba_index_operation op ON ist.database_id=op.databaseid
																			AND ist.object_id=op.objectid 
																			AND ist.index_id = op.indexid
																			AND ist.partition_number=op.partitionnum
							LEFT OUTER JOIN @scanned_table nst ON  ist.database_id=nst.database_id
																	AND ist.object_id=nst.object_id 
																	AND ist.index_id = nst.index_id

	WHERE (ISNULL(avg_page_space_used_in_percent,0) < 70 
			OR (ISNULL(avg_page_space_used_in_percent,0) > 70  AND avg_fragmentation_in_percent > 30)
			OR ISNULL(avg_fragmentation_in_percent,0) <= 30)
	--AND page_count > 1500
	
	DROP TABLE #index_stats

