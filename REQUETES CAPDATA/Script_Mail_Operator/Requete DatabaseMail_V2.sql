 

use master 
go 
sp_configure 'show advanced options',1 
go 
reconfigure with override 
go 
sp_configure 'Database Mail XPs',1 
--go 
--sp_configure 'SQL Mail XPs',0 
go 
reconfigure 
go 
 
-------------------------------------------------------------------------------------------------- 
-- BEGIN Mail Settings EnvoiMAIL 
-------------------------------------------------------------------------------------------------- 
IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_profile WHERE  name = 'EnvoiMAIL')  
  BEGIN 
    --CREATE Profile [EnvoiMAIL] 
    EXECUTE msdb.dbo.sysmail_add_profile_sp 
      @profile_name = 'EnvoiMAIL', 
      @description  = 'Ce profil permet lenvoie des mails'; 
  END --IF EXISTS profile 
   
  IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_account WHERE  name = 'SVPDatabase_Mail') 
  BEGIN 
    --CREATE Account [SVPDatabase_Mail] 
    EXECUTE msdb.dbo.sysmail_add_account_sp 
    @account_name            = 'SVPDatabase_Mail', 
    @email_address           = 'fichiers@quick.fr', 
    @display_name            = 'SVPDATABASE', 
    @replyto_address         = '', 
    @description             = 'Boite messagerie SVPDATABASE', 
    @mailserver_name         = 'smtp.office365.com', 
    @mailserver_type         = 'SMTP', 
    @port                    = '587', 
    @username                = 'fichiers@quick.fr', 
    @password                = 'NotTheRealPassword',  
    @use_default_credentials =  0 , 
    @enable_ssl              =  0 ; 
  END --IF EXISTS  account 
   
IF NOT EXISTS(SELECT * 
              FROM msdb.dbo.sysmail_profileaccount pa 
                INNER JOIN msdb.dbo.sysmail_profile p ON pa.profile_id = p.profile_id 
                INNER JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id   
              WHERE p.name = 'EnvoiMAIL' 
                AND a.name = 'SVPDatabase_Mail')  
  BEGIN 
    -- Associate Account [SVPDatabase_Mail] to Profile [EnvoiMAIL] 
    EXECUTE msdb.dbo.sysmail_add_profileaccount_sp 
      @profile_name = 'EnvoiMAIL', 
      @account_name = 'SVPDatabase_Mail', 
      @sequence_number = 1 ; 
  END  
--IF EXISTS associate accounts to profiles 
--------------------------------------------------------------------------------------------------- 
-- Drop Settings For EnvoiMAIL 
-------------------------------------------------------------------------------------------------- 
/* 
IF EXISTS(SELECT * 
            FROM msdb.dbo.sysmail_profileaccount pa 
              INNER JOIN msdb.dbo.sysmail_profile p ON pa.profile_id = p.profile_id 
              INNER JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id   
            WHERE p.name = 'EnvoiMAIL' 
              AND a.name = 'SVPDatabase_Mail') 
  BEGIN 
    EXECUTE msdb.dbo.sysmail_delete_profileaccount_sp @profile_name = 'EnvoiMAIL',@account_name = 'SVPDatabase_Mail' 
  END  
IF EXISTS(SELECT * FROM msdb.dbo.sysmail_account WHERE  name = 'SVPDatabase_Mail') 
  BEGIN 
    EXECUTE msdb.dbo.sysmail_delete_account_sp @account_name = 'SVPDatabase_Mail' 
  END 
IF EXISTS(SELECT * FROM msdb.dbo.sysmail_profile WHERE  name = 'EnvoiMAIL')  
  BEGIN 
    EXECUTE msdb.dbo.sysmail_delete_profile_sp @profile_name = 'EnvoiMAIL' 
  END 
*/ 
   
-------------------------------------------------------------------------------------------------- 
-- BEGIN Mail Settings EnvoiSMS 
-------------------------------------------------------------------------------------------------- 
--IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_profile WHERE  name = 'EnvoiSMS')  
--  BEGIN 
--    --CREATE Profile [EnvoiSMS] 
--    EXECUTE msdb.dbo.sysmail_add_profile_sp 
--      @profile_name = 'EnvoiSMS', 
--      @description  = 'Envoie SMS'; 
--  END --IF EXISTS profile 
   
--  IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_account WHERE  name = 'SVPDatabase_Mail') 
--  BEGIN 
--    --CREATE Account [SVPDatabase_Mail] 
--    EXECUTE msdb.dbo.sysmail_add_account_sp 
--    @account_name            = 'SVPDatabase_Mail', 
--    @email_address           = 'fichiers@quick.fr', 
--    @display_name            = 'SVPDATABASE', 
--    @replyto_address         = '', 
--    @description             = 'Boite messagerie SVPDATABASE', 
--    @mailserver_name         = '10.13.14.24', 
--    @mailserver_type         = 'SMTP', 
--    @port                    = '25', 
--    @username                = 'quick\fichiers', 
--    @password                = 'NotTheRealPassword',  
--    @use_default_credentials =  0 , 
--    @enable_ssl              =  0 ; 
--  END --IF EXISTS  account 
   
--IF NOT EXISTS(SELECT * 
--              FROM msdb.dbo.sysmail_profileaccount pa 
--                INNER JOIN msdb.dbo.sysmail_profile p ON pa.profile_id = p.profile_id 
--                INNER JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id   
--              WHERE p.name = 'EnvoiSMS' 
--                AND a.name = 'SVPDatabase_Mail')  
--  BEGIN 
--    -- Associate Account [SVPDatabase_Mail] to Profile [EnvoiSMS] 
--    EXECUTE msdb.dbo.sysmail_add_profileaccount_sp 
--      @profile_name = 'EnvoiSMS', 
--      @account_name = 'SVPDatabase_Mail', 
--      @sequence_number = 1 ; 
--  END  
--IF EXISTS associate accounts to profiles 
--------------------------------------------------------------------------------------------------- 
-- Drop Settings For EnvoiSMS 
-------------------------------------------------------------------------------------------------- 

IF EXISTS(SELECT * 
            FROM msdb.dbo.sysmail_profileaccount pa 
              INNER JOIN msdb.dbo.sysmail_profile p ON pa.profile_id = p.profile_id 
              INNER JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id   
            WHERE p.name = 'EnvoiSMS' 
              AND a.name = 'SVPDatabase_Mail') 
  BEGIN 
    EXECUTE msdb.dbo.sysmail_delete_profileaccount_sp @profile_name = 'EnvoiSMS',@account_name = 'SVPDatabase_Mail' 
  END  
IF EXISTS(SELECT * FROM msdb.dbo.sysmail_account WHERE  name = 'SVPDatabase_Mail') 
  BEGIN 
    EXECUTE msdb.dbo.sysmail_delete_account_sp @account_name = 'SVPDatabase_Mail' 
  END 
IF EXISTS(SELECT * FROM msdb.dbo.sysmail_profile WHERE  name = 'EnvoiSMS')  
  BEGIN 
    EXECUTE msdb.dbo.sysmail_delete_profile_sp @profile_name = 'EnvoiSMS' 
  END 

  

use master
go
sp_configure 'show advanced options',1
go
reconfigure with override
go
sp_configure 'Database Mail XPs',1
--go
--sp_configure 'SQL Mail XPs',0
go
reconfigure 
go

USE msdb ;  
GO  
  
EXECUTE dbo.sysmail_start_sp ;  
GO  
EXECUTE dbo.sp_sysmail_activate ;  
GO
select * from sysmail_event_log 
order by 3 desc 

USE [msdb]
GO

/****** Object:  Operator [Operator1]    Script Date: 15/03/2018 10:12:22 ******/
EXEC msdb.dbo.sp_add_operator @name=N'Operator1', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'mikael.hamchaoui@bkqservices.com', 
		@category_name=N'[Uncategorized]'
GO



USE [msdb]
GO

/****** Object:  Alert [Login FAiled]    Script Date: 14/03/2018 15:52:48 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Login Failed', 
		@message_id=0, 
		@severity=14, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@notification_message=N'Test', 
		@event_description_keyword=N'Login', 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO




USE [msdb]
GO
EXEC msdb.dbo.sp_update_alert @name=N'Login Failed', 
		@message_id=0, 
		@severity=14, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@database_name=N'', 
		@notification_message=N'Test', 
		@event_description_keyword=N'Login', 
		@performance_condition=N'', 
		@wmi_namespace=N'', 
		@wmi_query=N'', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Login Failed', @operator_name=N'Operator1', @notification_method = 1
GO

  