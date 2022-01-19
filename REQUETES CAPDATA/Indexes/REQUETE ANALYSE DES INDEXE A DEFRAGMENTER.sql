SET NOCOUNT ON
DECLARE @servername sysname
DECLARE @dbname sysname
DECLARE @cmd varchar(max)
DECLARE @Tdb TABLE (name sysname)
DECLARE @Tfrag TABLE (database_name sysname,object_name sysname,index_name sysname,avg_fragmentation_in_percent float  )
DECLARE servers_cursor CURSOR FOR select name from sys.servers where  name= 'KINGSIDSQLPRD' --server_id =0 and
OPEN servers_cursor
FETCH NEXT FROM servers_cursor INTO @servername
IF @@FETCH_STATUS <> 0 PRINT '         <<No server>>'     
WHILE @@FETCH_STATUS = 0
    BEGIN
		print @servername
		set @cmd='select name from '+QUOTENAME(@servername)+'.master.sys.databases where name not in (''master'',''msdb'',''tempdb'',''model'') and name=''SID_PRD'' and state_desc=''ONLINE'''
		PRINT @cmd
		delete from @Tdb
		insert into @Tdb EXEC(@CMD)
		DECLARE db_cursor CURSOR FOR select * from @Tdb
		OPEN db_cursor
		FETCH NEXT FROM db_cursor INTO @dbname
		IF @@FETCH_STATUS <> 0 PRINT '         <<No db>>'     
		WHILE @@FETCH_STATUS = 0
			BEGIN
				
				SET @CMD='select database_name,object_name,index_name,avg_fragmentation_in_percent  
				from openquery('+QUOTENAME(@servername)+','''+
				'SELECT d.name as database_name,o.name as object_name,idx.name as index_name,i.avg_fragmentation_in_percent
				FROM '+QUOTENAME(@dbname)+'.sys.dm_db_index_physical_stats  (db_id ('''''+@dbname+'''''), NULL, NULL , NULL, ''''LIMITED'''') i
				INNER JOIN '+QUOTENAME(@dbname)+'.sys.all_objects o ON i.object_id = o.object_id 
				INNER JOIN sys.databases d ON i.database_id=d.database_id 
				INNER JOIN '+QUOTENAME(@dbname)+'.sys.indexes idx ON idx.index_id = i.index_id and idx.object_id = o.object_id
				WHERE i.index_id > 0 and d.name='''''+ @dbname+''''' and i.avg_fragmentation_in_percent > 30 and i.page_count > 1500'')'
				print @CMD
				insert into @Tfrag exec(@cmd)
				
				
				FETCH NEXT FROM db_cursor INTO @dbname
			END
			CLOSE db_cursor
			DEALLOCATE db_cursor

        FETCH NEXT FROM servers_cursor INTO @servername
    END
	CLOSE servers_cursor
    DEALLOCATE servers_cursor

select * from @Tfrag order by 4


--select * from sys.all_objects
--select * from sys.databases
--select * from sys.indexes

--SELECT d.name as database_name,o.name as object_name,idx.name as index_name,i.avg_fragmentation_in_percent
--FROM sys.dm_db_index_physical_stats  (NULL, NULL, NULL , NULL, 'LIMITED') i
--INNER JOIN sys.all_objects o ON i.object_id = o.object_id 
--INNER JOIN sys.databases d ON i.database_id=d.database_id 
--INNER JOIN sys.indexes idx ON idx.index_id = i.index_id and idx.object_id = o.object_id
--WHERE i.index_id > 0 and i.avg_fragmentation_in_percent > 30 and i.page_count > 1500