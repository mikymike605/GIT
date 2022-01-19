----------------------------------------------------------------------------
-- Creation de la base AdminSQL
----------------------------------------------------------------------------

USE [master]
GO

/****** Object:  Database [AdminSQL]    Script Date: 21/04/2016 11:39:06 ******/
CREATE DATABASE [AdminSQL]
GO

----------------------------------------------------------------------------
-- Creation du Database Mail
----------------------------------------------------------------------------

USE [msdb]
GO

--Enabling Database Mail
sp_configure 'show advanced options',1
reconfigure
go
sp_configure 'Database Mail XPs',1
reconfigure
go

--Creating a Profile
EXECUTE msdb.dbo.sysmail_add_profile_sp
@profile_name = 'DatabaseMail',
@description = 'Compte de Service Office365' ;
go
-- Create a Mail account for gmail. We have to use our company mail account.
EXECUTE msdb.dbo.sysmail_add_account_sp
@account_name = 'DatabaseMail',
@email_address = 'mikael.hamchaoui@bkqservices.com',
@display_name = 'mikael.hamchaoui@bkqservices.com',
@replyto_address = 'noreply@deltadore.com',
@mailserver_name = 'smtp.office365.com',
@port=587,
@enable_ssl=1,
@username='mikael.hamchaoui@bkqservices.com',
@password='DatabaseMail'
go
-- Adding the account to the profile
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
@profile_name = 'DatabaseMail',
@account_name = 'DatabaseMail',
@sequence_number =1 ;
go
-- Granting access to the profile to the DatabaseMailUserRole of MSDB
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
@profile_name = 'DatabaseMail',
@principal_id = 0,
@is_default = 1 ;
go
--Sending Test Mail
DECLARE @bodyText AS varchar(100) = 'Creation du profil de mail sur ' + @@SERVERNAME + ' avec succes'
DECLARE @subjectText AS varchar(100) = 'Creation du profil de mail sur ' + @@SERVERNAME
EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'DatabaseMail',
@recipients = 'mikael.hamchaoui@bkqservices.com',
@body = @bodyText,
@subject = @subjectText;
go

----------------------------------------------------------------------------
-- Creation de l'operateur
----------------------------------------------------------------------------

USE [msdb]
GO

/****** Object:  Operator [DBA_operator]    Script Date: 21/04/2016 12:11:54 ******/
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

----------------------------------------------------------------------------
-- Activation du Database Mail sur l'Agent SQL (Clic-Droit propriétés sur SQL Server Agent)
----------------------------------------------------------------------------

--USE [msdb]
--GO
--EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder=1, 
--		@databasemail_profile=N'DatabaseMail'
--GO

----------------------------------------------------------------------------
-- Configuration du Fail-Safe Operator
----------------------------------------------------------------------------

USE [msdb]
GO
EXEC master.dbo.sp_MSsetalertinfo @failsafeoperator=N'DBA_operator', 
		@notificationmethod=1
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder=1
GO
