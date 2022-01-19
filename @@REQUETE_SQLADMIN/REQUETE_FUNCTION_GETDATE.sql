  DECLARE @debut_date	datetime
  DECLARE @fin_date		datetime
  
  SELECT @debut_date = dbo.GetSameDateWithoutHours ( DateAdd ( dd, -1, GetDate() ) )
  SELECT @fin_date = dbo.GetSameDateWithoutHours ( DateAdd ( dd, 0, GetDate() ) )

  PRINT  @debut_date	
  PRINT @fin_date		