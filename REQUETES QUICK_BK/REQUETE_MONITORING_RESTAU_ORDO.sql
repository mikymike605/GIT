
DECLARE @exec int set @exec=2
/*************************MAITRE'D************************/
IF @exec=1 goto process1;------------- Controle données table MD5 dans SAS  
IF @exec=11 goto process11;----------- Start Job MD5_TICKET_DTL
IF @exec=111 goto process111;--------- INSERT RESTAURANT TABLES MD5_MONITOR_DAYTOLOAD 
/*************************SICOM************************/
IF @exec=2 goto process2;------------- Controle données table MD5 dans SAS  
IF @exec=22 goto process22;----------- Start Job SEM_TICKET_DTL
IF @exec=222 goto process222;--------- INSERT RESTAURANT TABLES SEM_MONITOR_TICKET_DAYTOLOAD 
/*************************REBOOT************************/
IF @exec=3 goto process3;------------- Controle données table REBOOT dans SAS  
IF @exec=33 goto process33;----------- Start Job REB_TICKET, @step_name='SAS_REB_API_XML_RECUP'
IF @exec=333 goto process333;--------- INSERT RESTAURANT TABLES REBOOT MONITOR TEC.TEC_RUN_JOB 
/*************************REBOOT BO************************/
IF @exec=4 goto process4;------------- Controle données table REBOOT BOdans SAS  
IF @exec=44 goto process44;----------- Start Job REB_BO, @step_name='API_REBOOT'
IF @exec=444 goto process444;---------- INSERT RESTAURANT TABLES REBOOT BO MONITOR TEC.TEC_RUN_JOB 

goto fin;
/**********************************************************/
/*************************MAITRE'D************************/
/********************************************************/
/*Controle données table MD5 dans SAS  */
process1:
select 'MD5_MONITOR_DAYTOLOAD' as [Table], * 
from SID_PRD.SAS.MD5_MONITOR_DAYTOLOAD 
order by CommercialDate
goto fin;
-----TRUNCATE TABLE SID_PRD.SAS.MD5_MONITOR_DAYTOLOAD 
/*Start Job MD5_TICKET_DTL*/
process11:
USE msdb
EXEC dbo.sp_start_job 'MD5_TICKET_DTL' ;  
goto fin;

/*INSERT RESTAURANT TABLES MD5_MONITOR_DAYTOLOAD */
process111:
INSERT INTO SID_PRD.SAS.MD5_MONITOR_DAYTOLOAD
	(restaurantcode,
	CommercialDate,
	DT_INS)
VALUES 
	('1260',
	'2019-05-20',
	GETDATE());	

select 'MD5_MONITOR_DAYTOLOAD' as [Table], * 
from SID_PRD.SAS.MD5_MONITOR_DAYTOLOAD 
where restaurantcode=1260
order by CommercialDate
goto fin;

/**********************************************************/
/**************************SICOM**************************/
/********************************************************/
/*Controle données table SEM dans SAS  */
process2:
select 'SEM_MONITOR_TICKET_DAYTOLOAD'as [Table],* 
from SID_PRD.[SAS].[SEM_MONITOR_TICKET_DAYTOLOAD]
order by Date
goto fin;

/*Start Job SEM_TICKET_DTL*/
process22:
USE msdb
  
EXEC dbo.sp_start_job 'SEM_TICKET_DTL' ;  
  
goto fin;

/*INSERT RESTAURANT TABLES SEM_MONITOR_TICKET_DAYTOLOAD */
process222:
INSERT INTO SID_PRD.SAS.SEM_MONITOR_TICKET_DAYTOLOAD
	([Store_uid]
      ,[RestaurantUniqueID]
      ,[Date]
      ,[DT_INS]
      ,[DT_MAJ]
      ,[DT_SUP]
      ,[SOURCE])
VALUES 
	('2',
	 '80040005',
	 '2019-05-15',
	 GETDATE(),
	 GETDATE (),
	 NULL,
	 'INI');

select 'SEM_MONITOR_TICKET_DAYTOLOAD' as [Table], * 
from SID_PRD.SAS.SEM_MONITOR_TICKET_DAYTOLOAD 
where [RestaurantUniqueID]=80040005
order by Date
goto fin;

/**********************************************************/
/*************************REBOOT**************************/
/********************************************************/
/*Controle données table REB dans SAS  */
process3:
select 'REB_MONITOR_TICKET_DTL'as [Table],* 
from SID_PRD.SAS.REB_MONITOR_TICKET_DTL
goto fin;

/*INSERT RESTAURANT TABLES REBOOT MONITOR TEC.TEC_RUN_JOB */
process333:
--UPDATE TEC.TEC_RUN_JOB
--SET STATUS_RUN = 'CLOSED'
--WHERE JOB_NAME = 'REB';

--UPDATE TEC.TEC_RUN_JOB
--SET STATUS_RUN = 'CLOSED'
--WHERE JOB_NAME = 'REB_BO';

INSERT INTO SID_PRD.TEC.TEC_RUN_JOB
	(ID_JOB_EXECUTION,
	JOB_NAME,
	STATUS_RUN,
	LAST_USER)
VALUES 
	(NEWID(),
	'REB',
	'OPEN',
	'Initialisation');



select 'TEC.TEC_RUN_JOB' as [Table], * 
from SID_PRD.TEC.TEC_RUN_JOB
order by DATE_CREATE desc
goto fin;

/*Start Job SEM_TICKET_DTL*/
process33:
USE msdb
  
-- EXEC dbo.sp_start_job @job_name='REB_TICKET', @step_name='SAS_REB_API_XML_RECUP';  

goto fin;


/**********************************************************/
/*************************REBOOT_BO**************************/
/********************************************************/
/*Controle données table REB BO dans SAS  */
process4:
select 'REB_BO_MONITOR_TICKET_DTL'as [Table],* 
from SID_PRD.SAS.REB_BO_MONITOR_TICKET_DTL
goto fin;
/*INSERT RESTAURANT TABLES REBOOT BO MONITOR TEC.TEC_RUN_JOB */
process444:
INSERT INTO SID_PRD.TEC.TEC_RUN_JOB
	(ID_JOB_EXECUTION,
	JOB_NAME,
	STATUS_RUN,
	LAST_USER)
VALUES 
	(NEWID(),
	'REB_BO',
	'OPEN',
	'Initialisation');

select 'TEC.TEC_RUN_JOB' as [Table], * 
from SID_PRD.TEC.TEC_RUN_JOB
order by DATE_CREATE
goto fin;

/*Start Job SEM_TICKET_DTL*/
process44:
USE msdb
  -- EXEC dbo.sp_start_job @job_name='REB_BO', @step_name='API_REBOOT';  
goto fin;

/* REFERENTIEL SHAREPOINT */
SELECT SEMS_UID , *
FROM SID_PRD.[ODS].[SHP_BK_SHAREPOINT_RESTAURANT] 
WHERE FLAG_ACTIVE = 1 
AND StatutValue LIKE 'A.%'
--AND bk LIKE '20771'
and RestaurantUniqueID='80040034'



fin:

--UPDATE TEC.TEC_RUN_JOB
--SET STATUS_RUN = 'CLOSED'
--WHERE JOB_NAME = 'REB_BO';

--INSERT INTO TEC.TEC_RUN_JOB
--	(ID_JOB_EXECUTION,
--	JOB_NAME,
--	STATUS_RUN,
--	LAST_USER)
--VALUES 
--	(NEWID(),
--	'REB_BO',
--	'OPEN',
--	'Initialisation');