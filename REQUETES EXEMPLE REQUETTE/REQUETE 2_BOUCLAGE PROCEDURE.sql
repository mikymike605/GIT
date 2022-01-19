





DECLARE @irest_nr int


DECLARE CURS CURSOR FOR select distinct RestaurantCode
from ODS..ODS_Bon_DEP_REC
where CommercialDate = '20150101'


OPEN CURS 
FETCH  NEXT  FROM CURS INTO @iRest_nr
WHILE @@FETCH_STATUS = 0

BEGIN
--PRINT @iRest_nr
			--
				EXEC [dbo].[CTPA_Extract_CutOff_CB] @iRest_nr	, '20150402'
				--
				EXEC [dbo].[CTPA_Extract_CutOff_TR] @iRest_nr	, '20150402'
				
				
FETCH  NEXT  FROM CURS INTO @iRest_nr

END
  
close curs 

DEALLOCATE curs



			
			