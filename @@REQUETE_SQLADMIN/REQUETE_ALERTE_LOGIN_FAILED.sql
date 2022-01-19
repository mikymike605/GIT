USE [msdb];
GO
EXEC msdb.dbo.sp_delete_alert
   @name = N'Login failed : State 5';

USE [msdb];
GO

EXEC msdb.dbo.sp_add_operator 
   @name = N'Operator1', 
   @enabled = 1, 
   @pager_days = 0, 
   @email_address = N'mikael.hamchaoui@bkqservices.com', 
   @category_name = N'[Uncategorized]';

DECLARE @namespace NVARCHAR(255)
   = N'\\.\root\Microsoft\SqlServer\ServerEvents\' + COALESCE
   (
       CONVERT(NVARCHAR(32), SERVERPROPERTY('InstanceName')),
       N'MSSQLSERVER'
   );

EXEC msdb.dbo.sp_add_alert 
   @name = N'Login Failed : State 5', 
   @message_id = 0, 
   @severity = 0, 
   @enabled = 1, 
   @delay_between_responses = 0, 
   @include_event_description_in = 1, 
   @category_name = N'[Uncategorized]', 
   @wmi_namespace = @namespace, 
   @wmi_query = N'SELECT * FROM AUDIT_LOGIN_FAILED WHERE State = 5';

EXEC msdb.dbo.sp_add_notification
   @alert_name = N'Login Failed : State 5', 
   @operator_name = N'Operator1', 
   @notification_method = 1;
GO