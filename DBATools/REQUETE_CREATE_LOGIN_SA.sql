USE [master]
GO
CREATE LOGIN [sa_sa] WITH PASSWORD=N'Capdata!123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [sa_sa]
GO


USE [master]
GO
ALTER LOGIN [sa] WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
USE [master]
GO
ALTER LOGIN [sa] WITH PASSWORD=N'parisnord*+'
GO
ALTER LOGIN [sa] ENABLE
GO

USE [master]
GO
EXEC master.dbo.sp_addlinkedserver @server = N'AUBFRTESTSQL02', @srvproduct=N'SQL Server'

GO
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'collation compatible', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'data access', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'dist', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'pub', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'rpc', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'rpc out', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'sub', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'connect timeout', @optvalue=N'0'
GO
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'collation name', @optvalue=null
GO
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'lazy schema validation', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'query timeout', @optvalue=N'0'
GO
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'use remote collation', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'AUBFRTESTSQL02', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO
USE [master]
GO
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'AUBFRTESTSQL02', @locallogin = NULL , @useself = N'False', @rmtuser = N'sa_sa', @rmtpassword = N'Capdata!123'
GO
