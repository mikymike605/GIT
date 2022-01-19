USE [master]
GO

/****** Object:  Login [maintenance]    Script Date: 21/04/2016 16:24:20 ******/
CREATE LOGIN [maintenance] WITH PASSWORD=N'HvpzVGfk3Lp5', DEFAULT_DATABASE=[tempdb], DEFAULT_LANGUAGE=[Français], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
EXEC sp_addsrvrolemember N'maintenance', N'sysadmin'
GO
