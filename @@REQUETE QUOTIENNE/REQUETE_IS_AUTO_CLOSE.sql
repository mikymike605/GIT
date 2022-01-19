/* If the result is 1 then it means AUTO CLOSE option is TRUE or ON for the database */

SELECT DATABASEPROPERTY('WEM_1909','IsAutoClose')
GO

/* Alternate Method */

/* If is_auto_close_on value is 1 then it means AUTO CLOSE option is TRUE or ON for the database */

SELECT name,is_auto_close_on, 'ALTER DATABASE ['+name+']  SET AUTO_CLOSE OFF WITH NO_WAIT'FROM sys.databases 
WHERE is_auto_close_on = 1 --AND name = 'AdventureWorks2008R2' 
GO


ALTER DATABASE [DBTERRA0]  SET AUTO_CLOSE OFF WITH NO_WAIT/* If the result is 1 then it means AUTO CLOSE option is TRUE or ON for the database */

SELECT DATABASEPROPERTY('WEM_1909','IsAutoClose')
GO

/* Alternate Method */

/* If is_auto_close_on value is 1 then it means AUTO CLOSE option is TRUE or ON for the database */

SELECT name,is_auto_shrink_on, 'ALTER DATABASE ['+name+']  SET AUTO_SHRINK OFF WITH NO_WAIT'FROM sys.databases 
WHERE is_auto_shrink_on = 1 --AND name = 'AdventureWorks2008R2'
GO


ALTER DATABASE [TI2019]  SET AUTO_SHRINK OFF WITH NO_WAIT

/* If the result is 1 then it means AUTO CLOSE option is TRUE or ON for the database */

SELECT DATABASEPROPERTY('WEM_1909','IsAutoClose')
GO

/* Alternate Method */

/* If is_auto_close_on value is 1 then it means AUTO CLOSE option is TRUE or ON for the database */

SELECT name,is_auto_close_on FROM sys.databases 
WHERE is_auto_close_on = 1 --AND name = 'AdventureWorks2008R2'
GO

ALTER DATABASE [DBZZZTRA]  SET AUTO_CLOSE OFF WITH NO_WAIT

/* If the result is 1 then it means AUTO CLOSE option is TRUE or ON for the database */

SELECT DATABASEPROPERTY('WEM_1909','IsAutoClose')
GO

/* Alternate Method */

/* If is_auto_close_on value is 1 then it means AUTO CLOSE option is TRUE or ON for the database */

SELECT name,is_auto_close_on FROM sys.databases 
WHERE is_auto_close_on = 1 --AND name = 'AdventureWorks2008R2'
GO
