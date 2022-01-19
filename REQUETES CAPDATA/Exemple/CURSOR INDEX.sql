DECLARE @tbname varchar(250)
--DECLARE @servername varchar(250)
DECLARE product_cursor CURSOR FOR 
	SELECT name FROM SYs.SYSDATABASES where name not in ('master','tempdb','model','msdb','ReportServer','ReportServerTempDB')   
OPEN product_cursor  
FETCH NEXT FROM product_cursor INTO @tbname  
IF @@FETCH_STATUS <> 0   PRINT '         <<None>>'       
WHILE @@FETCH_STATUS = 0  
    BEGIN  
		EXEC AdminMonitor..MISSING_INDEXS_v3 @tbname
        FETCH NEXT FROM product_cursor INTO @tbname  
	END  
CLOSE product_cursor  
DEALLOCATE product_cursor  
GO