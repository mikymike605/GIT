USE master
GO

-- ============================================================
-- Author:      Eli Leiba
-- Create date: 12-2017
-- Description: Compute the DB backup compression ratio %
-- ============================================================
CREATE PROCEDURE usp_Calc_DB_Compression_Ratio_Pct (
   @dbName SYSNAME,
   @compressPct DECIMAL (5, 1) OUTPUT
   )
AS
BEGIN
   DECLARE @dynaTSQL VARCHAR(400)

   SET NOCOUNT ON
   SET @dynaTSQL = CONCAT (
         'BACKUP DATABASE ',
         @dbName,
         ' TO DISK = N',
         '''',
         'nul',
         '''',
         ' with compression, copy_only '
         )

   EXEC (@dynaTSQL)

   SELECT @compressPct = cast (100.0*a.compressed_backup_size / a.backup_size AS DECIMAL (5, 1))
   FROM msdb..backupset a
   WHERE lower (a.database_name) = @dbName AND a.backup_finish_date = (
         SELECT max (backup_finish_date)
         FROM msdb..backupset
         )

   SET NOCOUNT OFF
END
GO

USE master
GO

DECLARE @comppct DECIMAL (5, 1)

EXEC usp_Calc_DB_Compression_Ratio_Pct @dbname = 'DBATools',
   @compressPct = @comppct OUTPUT

PRINT @comppct
GO

USE [master]
GO

/****** Object:  StoredProcedure [dbo].[usp_Calc_DB_Compression_Ratio_Pct]    Script Date: 11/18/2019 3:56:49 PM ******/
DROP PROCEDURE [dbo].[usp_Calc_DB_Compression_Ratio_Pct]
GO


USE AdventureWorks2012 
GO 
EXEC sp_spaceused @updateusage = 'true' 

SELECT CONVERT(VARCHAR, CONVERT(DECIMAL(18,1), backup_size/1024))+ ' KB' [Backup Size] 
FROM msdb.dbo.backupset 
WHERE database_name = 'AdventureWorks2012' 
  AND backup_finish_date > DATEADD(hh, -1, GETDATE()) 
  GO