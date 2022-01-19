-- ================================================================
-- Author:      Eli Leiba
-- Create date: 04-2018
-- 05-2018 
--    1. Adding database name for check
--    2. Result is in MB
-- Description: Check if drive has enough space for DB backup
/*
USE SID_PRD
GO
DECLARE @enoughSpaceForBackupFlag bit
EXEC DoesDBBackupHaveSpace 'K', @enoughSpaceForBackupFlag OUTPUT
PRINT @enoughSpaceForBackupFlag
IF @enoughSpaceForBackupFlag = 1
   PRINT 'Continue to Backup...'
ELSE 
   PRINT 'Drive Space Problem...'
GO	
*/
-- ================================================================
CREATE PROCEDURE dbo.DoesDBBackupHaveSpace (
   @drvLetter VARCHAR (5),
   @enoughSpaceForBackupFlag BIT OUTPUT
   )
AS
BEGIN
   DECLARE @estimatedBackSizeMB INT
   DECLARE @estimatedDriveFreeSpaceMB INT
   DECLARE @dbCheckMessage varchar(80)

   SET NOCOUNT ON

   SET @dbCheckMessage = concat ('Checking database ', DB_NAME ())
   PRINT @dbCheckMessage

   SELECT @estimatedBackSizeMB = round (sum (a.total_pages) * 8192 / SQUARE (1024.0), 0)
   FROM sys.partitions p
   JOIN sys.allocation_units a
      ON p.partition_id = a.container_id
   LEFT JOIN sys.internal_tables it
      ON p.object_id = it.object_id

   CREATE TABLE #freespace (drive VARCHAR (5), MBFree DECIMAL (8, 2))

   INSERT INTO #freespace (
      Drive,
      MBFree) EXEC xp_fixeddrives

   SELECT @estimatedDriveFreeSpaceMB = MBFree 
   FROM #freespace
   WHERE drive = @drvLetter

   IF @estimatedBackSizeMB * 1.15 < @estimatedDriveFreeSpaceMB
      SET @enoughSpaceForBackupFlag = 1
   ELSE
      SET @enoughSpaceForBackupFlag = 0

   SELECT DatabaseName = db_name(),	
      Estimated_Back_Size_MB = @estimatedBackSizeMB,
      Estimated_Drive_Free_Space_MB = @estimatedDriveFreeSpaceMB,
      EnoughSpaceForBackupFlag = @enoughSpaceForBackupFlag

   DROP TABLE #freespace
   SET NOCOUNT OFF
END
GO