 USE [msdb]
GO

/****** Object:  Operator [DBA_operator]    Script Date: 09/03/2017 15:06:20 ******/
EXEC msdb.dbo.sp_delete_operator @name=N'DBA_operator'

EXEC msdb.dbo.sp_add_operator @name=N'DBA_operator', 
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

/****** Object:  Alert [SSPI Handshake]    Script Date: 09/03/2017 15:06:47 ******/
EXEC msdb.dbo.sp_add_alert @name=N'SSPI Handshake', 
		@message_id=0, 
		@severity=1, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@event_description_keyword=N'SSPI', 
		@category_name=N'[Uncategorized]'
GO




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
-- BEGIN Mail Settings EnvoiMail 
-------------------------------------------------------------------------------------------------- 
IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_profile WHERE  name = 'EnvoiMail')  
  BEGIN 
    --CREATE Profile [EnvoiMail] 
    EXECUTE msdb.dbo.sysmail_add_profile_sp 
      @profile_name = 'EnvoiMail', 
      @description  = 'Ce profil permet l''envoie des mails'; 
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
    @mailserver_name         = '10.13.14.23', 
    @mailserver_type         = 'SMTP', 
    @port                    = '25', 
    @username                = 'quick\fichiers', 
    @password                = 'NotTheRealPassword',  
    @use_default_credentials =  0 , 
    @enable_ssl              =  0 ; 
  END --IF EXISTS  account 
   
IF NOT EXISTS(SELECT * 
              FROM msdb.dbo.sysmail_profileaccount pa 
                INNER JOIN msdb.dbo.sysmail_profile p ON pa.profile_id = p.profile_id 
                INNER JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id   
              WHERE p.name = 'EnvoiMail' 
                AND a.name = 'SVPDatabase_Mail')  
  BEGIN 
    -- Associate Account [SVPDatabase_Mail] to Profile [EnvoiMail] 
    EXECUTE msdb.dbo.sysmail_add_profileaccount_sp 
      @profile_name = 'EnvoiMail', 
      @account_name = 'SVPDatabase_Mail', 
      @sequence_number = 1 ; 
  END  
--IF EXISTS associate accounts to profiles 
--------------------------------------------------------------------------------------------------- 
-- Drop Settings For EnvoiMail 
-------------------------------------------------------------------------------------------------- 
/* 
IF EXISTS(SELECT * 
            FROM msdb.dbo.sysmail_profileaccount pa 
              INNER JOIN msdb.dbo.sysmail_profile p ON pa.profile_id = p.profile_id 
              INNER JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id   
            WHERE p.name = 'EnvoiMail' 
              AND a.name = 'SVPDatabase_Mail') 
  BEGIN 
    EXECUTE msdb.dbo.sysmail_delete_profileaccount_sp @profile_name = 'EnvoiMail',@account_name = 'SVPDatabase_Mail' 
  END  
IF EXISTS(SELECT * FROM msdb.dbo.sysmail_account WHERE  name = 'SVPDatabase_Mail') 
  BEGIN 
    EXECUTE msdb.dbo.sysmail_delete_account_sp @account_name = 'SVPDatabase_Mail' 
  END 
IF EXISTS(SELECT * FROM msdb.dbo.sysmail_profile WHERE  name = 'EnvoiMail')  
  BEGIN 
    EXECUTE msdb.dbo.sysmail_delete_profile_sp @profile_name = 'EnvoiMail' 
  END 
*/ 
  