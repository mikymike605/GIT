
TRUNCATE table AdminMonitor.[dbo].[ErrorLog]
DECLARE @servername varchar(250)
DECLARE product_cursor CURSOR FOR SELECT name FROM [AdminMonitor].[dbo].SERVER 
DECLARE @cmd varchar(5000)  
OPEN product_cursor  
FETCH NEXT FROM product_cursor INTO @servername  
IF @@FETCH_STATUS <> 0   PRINT '         <<None>>'       
WHILE @@FETCH_STATUS = 0  
    BEGIN  
		SET @CMD='INSERT INTO AdminMonitor.[dbo].[ErrorLog] SELECT '''+@ServerName+''',* FROM OPENROWSET(''SQLNCLI'',''Server='+@ServerName+';Uid=sa_sa;pwd=Capdata!123;'',''SET FMTONLY OFF; EXEC master.sys.xp_readerrorlog 0,1,Error'')'
		PRINT @CMD
		EXEC(@CMD)
        FETCH NEXT FROM product_cursor INTO @servername  
	END  
CLOSE product_cursor  
DEALLOCATE product_cursor  
GO