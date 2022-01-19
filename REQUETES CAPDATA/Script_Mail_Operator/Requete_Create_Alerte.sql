

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
