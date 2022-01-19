--Mikael.HAMCHAOUI@bkqservices.com;thibaut.lallement@bkqservices.com

--------------------------------------------------------------------------------------------------- 
-- Drop Settings For EnvoiMAIL 
-------------------------------------------------------------------------------------------------- 

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
    @replyto_address         = 'fichiers@quick.fr', 
    @description             = 'Boite messagerie SVPDATABASE', 
    @mailserver_name         = 'smtp.office365.com', 
    @mailserver_type         = 'SMTP', 
    @port                    = '587', 
    @username                = 'fichiers@quick.fr', 
    @password                = 'PCINFO',  
    @use_default_credentials =  0 , 
    @enable_ssl              =  1 ; 
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

--use msdb
--go
--select * from sysmail_event_log 
--order by 3 desc 

   