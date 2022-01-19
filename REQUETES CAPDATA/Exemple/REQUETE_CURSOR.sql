DECLARE @servername varchar(250)
--DECLARE @Tresult TABLE  (SERVERNAME varchar (250))
--DECLARE @Tfinal	 TABLE (SERVERNAME varchar (250),)

--INSERT INTO @Tresult SELECT name FROM [AdminMonitor]..[Server] 

DECLARE product_cursor CURSOR FOR 
	--SELECT SERVERNAME FROM @Tresult
	SELECT name FROM [AdminMonitor]..[Server] 
OPEN product_cursor  
FETCH FROM product_cursor INTO @SERVERNAME 
WHILE @@FETCH_STATUS = 0  
    BEGIN 
	PRINT @SERVERNAME
	FETCH FROM product_cursor INTO @SERVERNAME 
	--BEGIN 
--	SELECT 
--	rank() OVER (ORDER BY (migs.user_seeks + migs.user_scans) DESC) AS rank, 
--	(migs.user_seeks + migs.user_scans) AS seek_and_scan, 
--	migs.avg_user_impact, 
--	'CREATE INDEX [missing_index]' + ' ON ' + mid.statement + ' (' + ISNULL(mid.equality_columns, '') + CASE WHEN mid.equality_columns IS NOT NULL AND 
--	mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END + ISNULL(mid.inequality_columns, '') + ')' + ISNULL(' INCLUDE (' + mid.included_columns + ')', '') 
--	AS create_index_statement
--INTO #T1
--	SELECT * FROM @servername.master.sys.dm_db_missing_index_groups mig 
--		INNER JOIN @SERVERNAME..sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle 
--		INNER JOIN @SERVERNAME..sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
--	WHERE migs.avg_user_impact > 80 AND (migs.user_seeks + migs.user_scans) > 1000 AND mid.included_columns IS NULL
--/*ORDER BY 3 DESC*/ 
--	SELECT *  INTO #T2
--		FROM #T1 a
--		WHERE NOT EXISTS
--			(SELECT *
--				FROM #T1 b
--				WHERE a.rank <> b.rank AND CHARINDEX(REPLACE(a.create_index_statement, ')', ''), REPLACE(b.create_index_statement, ')', '')) > 0)
--	SELECT *
--		FROM #T2
--ORDER BY 4 


--DROP TABLE #T1 DROP TABLE #T2
--	END

	END
	CLOSE product_cursor  
DEALLOCATE product_cursor

--END
