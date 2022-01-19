USE [DBCAHC]
GO


DECLARE @irest_nr int


DECLARE CURS CURSOR FOR SELECT distinct rest_nr from [QuickMDCube_FR]..[vw_MDRestaurant]

OPEN CURS 
FETCH  NEXT  FROM CURS INTO @iRest_nr
WHILE @@FETCH_STATUS = 0
BEGIN
--PRINT @iRest_nr
EXEC	[dbo].[MK_Extract_CA_Jour_Periode_NewNew]
		4,
		@iRest_nr,
		 N'20140101',
		 N'20140430',
		 8 
FETCH  NEXT  FROM CURS INTO @iRest_nr

END
  
close curs 

DEALLOCATE curs 
--------------------**********************--------------------**********************------------------------*******************----------------------
--------------------**********************--------------------**********************------------------------*******************----------------------
--------------------**********************--------------------**********************------------------------*******************----------------------
DECLARE @net_net float
DECLARE @ticket float
DECLARE @date date
DECLARE @net_net1 float
DECLARE @ticket1 float
DECLARE @date1 date


DECLARE CURS CURSOR FOR
Select net_net,ticket,date,corr
From comm..avm_jour_conv1
where pays_seq=7
and corr = 0
and net_net<>0
and rest_nr in (950)
and date >= '01/01/2014'
Order by date


OPEN CURS 
FETCH  NEXT  FROM CURS INTO @net_net, @ticket, @date
WHILE @@FETCH_STATUS = 0
BEGIN

Select @net_net1=net_net,@ticket1=ticket,@date1=date
From comm..avm_jour_conv1
where pays_seq=7
and corr = 1
and rest_nr in (950)
and date = @date


UPDATE avm_jour_conv1
SET net_net=@net_net1
where pays_seq=7
and corr = 0
and rest_nr in (950)
and date = @date

SET @net_net1=0
SET @ticket1=0
SEt @date1=null

FETCH  NEXT  FROM CURS INTO @net_net, @ticket, @date


END
  
close curs 

DEALLOCATE curs 