USE CAPDATA
GO
/****** Object:  StoredProcedure [dbo].[DEFRAG_Check]    Script Date: 02/03/2016 14:06:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[DEFRAG_Check]
	@Servername sysname=NULL,
	@Basename sysname=NULL,
	@tablename sysname=NULL,
	@frag int=30

As
-- **********************************************************************************
-- StoredProcedure [dbo].[DEFRAG_Check]
--
-- Christophe ISSENLOR
-- CAPDATA - OSMOZIUM
-- 
--
-- Version 1 Release 0 - 02/03/2016 - Version initiale
--
-- Paramêtres :
-- @Servername = Nom du serveur à contrôler (Linked server) - Si NULL => tous
-- @Basename = Nom de la base à contrôler - Si NULL => tous
-- @tablename = Nom de la table à contrôler - Si NULL => tous
-- @frag = Seuil de fragmentation pour sortie
-- 
-- notes : Si pb data access => exec SP_SERVEROPTION 'nom server','DATA ACCESS',TRUE
-- **********************************************************************************dbname

SET NOCOUNT ON

DECLARE @srvname sysname
DECLARE @dbname sysname
DECLARE @cmd varchar(max)
DECLARE @Tdb TABLE (name sysname)
DECLARE @Tfrag TABLE (server_name sysname,database_name sysname,object_name sysname,index_name sysname,avg_fragmentation_in_percent float  )
DECLARE servers_cursor CURSOR FOR select name from sys.servers where @servername is NULL or name=@servername
OPEN servers_cursor
FETCH NEXT FROM servers_cursor INTO @srvname
IF @@FETCH_STATUS <> 0 PRINT '         <<No server>>'     
WHILE @@FETCH_STATUS = 0
    BEGIN
		print 'Traitement serveur : '+@srvname
		set @cmd='select name from '+QUOTENAME(@srvname)+'.master.sys.databases where name not in (''master'',''msdb'',''tempdb'',''model'') and state_desc=''ONLINE'' and ('''+ISNULL(@basename,'')+''' = '''' or name='''+ISNULL(@basename,'')+''')'
		---PRINT @cmd
		delete from @Tdb
		insert into @Tdb EXEC(@CMD)
		DECLARE db_cursor CURSOR FOR select * from @Tdb
		OPEN db_cursor
		FETCH NEXT FROM db_cursor INTO @dbname
		IF @@FETCH_STATUS <> 0 PRINT '         <<No db>>'     
		WHILE @@FETCH_STATUS = 0
			BEGIN
				Print '   traitement base : '+@dbname
				SET @CMD='select '''+@srvname+''',database_name,object_name,index_name,avg_fragmentation_in_percent  
				from openquery('+QUOTENAME(@srvname)+','''+
				'SELECT d.name as database_name,o.name as object_name,idx.name as index_name,i.avg_fragmentation_in_percent
				FROM '+QUOTENAME(@dbname)+'.sys.dm_db_index_physical_stats  (db_id ('''''+@dbname+'''''), CASE '''''+ISNULL(@tablename,'-')+''''' WHEN ''''-'''' THEN NULL ELSE OBJECT_ID('''''+ISNULL(@tablename,'-')+''''') END,NULL, NULL, ''''LIMITED'''') i
				INNER JOIN '+QUOTENAME(@dbname)+'.sys.all_objects o ON i.object_id = o.object_id 
				INNER JOIN sys.databases d ON i.database_id=d.database_id 
				INNER JOIN '+QUOTENAME(@dbname)+'.sys.indexes idx ON idx.index_id = i.index_id and idx.object_id = o.object_id
				WHERE i.index_id > 0 and d.name='''''+ @dbname+'''''  and i.page_count > 1500'')'
				---print @CMD
				Begin try
				insert into @Tfrag exec(@cmd)
				end try
				begin catch
					Print  ERROR_MESSAGE()
				end catch
				
				FETCH NEXT FROM db_cursor INTO @dbname
			END
			CLOSE db_cursor
			DEALLOCATE db_cursor

        FETCH NEXT FROM servers_cursor INTO @srvname
    END
	CLOSE servers_cursor
    DEALLOCATE servers_cursor

select * from @Tfrag where avg_fragmentation_in_percent > @frag order by 4

			
			

