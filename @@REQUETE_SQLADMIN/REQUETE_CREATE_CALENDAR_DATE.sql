IF EXISTS (SELECT * FROM information_schema.tables WHERE Table_Name = 'Calendar' AND Table_Type = 'BASE TABLE')
BEGIN
DROP TABLE [Calendar]
END

CREATE TABLE [Calendar]
(
    [CalendarDate] DATETIME
)

DECLARE @StartDate DATETIME
DECLARE @EndDate DATETIME
SET @StartDate = GETDATE()-365
SET @EndDate = DATEADD(d, 365, @StartDate)

WHILE @StartDate <= @EndDate
      BEGIN
             INSERT INTO [Calendar]
             (
                   CalendarDate
             )
             SELECT
                   @StartDate

             SET @StartDate = DATEADD(dd, 1, @StartDate)
      END