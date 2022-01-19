

--DROP TABLE [AdminSQL].[dbo].[TBserver]

USE [AdminSQL]
GO

/****** Object:  Table [dbo].[TBserver]    Script Date: 06/12/2017 16:05:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[TBserver](
	[Servername] [varchar](250) NULL,
	[MajorVersion] [varchar](128) NULL,
	[ProductLevel] [varchar](10) NULL,
	[Edition] [varchar](250) NULL,
	[ProductVersion] [varchar](250) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


INSERT INTO [AdminSQL].[dbo].[TBserver]
(
Servername ,
MajorVersion,
ProductLevel,
Edition ,
ProductVersion 
)
SELECT '['+@@servername+']',
  CASE 
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '8%' THEN 'SQL2000'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '9%' THEN 'SQL2005'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.0%' THEN 'SQL2008'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.5%' THEN 'SQL2008 R2'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '11%' THEN 'SQL2012'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '12%' THEN 'SQL2014'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '13%' THEN 'SQL2016'     
     ELSE 'unknown'
  END AS MajorVersion,
  convert (varchar (10),SERVERPROPERTY('ProductLevel')) AS ProductLevel,
  convert (varchar (250),SERVERPROPERTY('Edition')) AS Edition,
  convert (varchar (250),SERVERPROPERTY('ProductVersion')) AS ProductVersion

  EXEC sp_dropserver 'AUBFRTESTSQL02'
EXEC sp_addServer 'AUBFRTESTSQL02', 'local'
 