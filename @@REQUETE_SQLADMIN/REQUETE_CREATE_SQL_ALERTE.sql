-- Creating Severity alerts from 17-25
-- The operator should be created prior to creating the severity alerts.
-- Replace OperatorName with the name of your operator.
-- Error messages with a severity level from 19 through 25 are written to the error log.

USE [msdb]
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity Level 17 Alert: Insufficient Resources',
  @message_id=0,
  @severity=17,
  @enabled=1,
  @delay_between_responses=0,
  @include_event_description_in=1,
  @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity Level 17 Alert: Insufficient Resources',
@operator_name=N'Operator1',
@notification_method = 1
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity Level 18 Alert: Nonfatal Internal Error',
  @message_id=0,
  @severity=18,
  @enabled=1,
  @delay_between_responses=0,
  @include_event_description_in=1,
  @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity Level 18 Alert: Nonfatal Internal Error',
@operator_name=N'Operator1',
@notification_method = 1
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity Level 19 Alert: Fatal Error in Resource',
  @message_id=0,
  @severity=19,
  @enabled=1,
  @delay_between_responses=0,
  @include_event_description_in=1,
  @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity Level 19 Alert: Fatal Error in Resource',
@operator_name=N'Operator1',
@notification_method = 1
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity Level 20 Alert: Fatal Error in Current Process',
  @message_id=0,
  @severity=20,
  @enabled=1,
  @delay_between_responses=0,
  @include_event_description_in=1,
  @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity Level 20 Alert: Fatal Error in Current Process',
@operator_name=N'Operator1',
@notification_method = 1
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity Level 21 Alert: Fatal Error in Database Processes',
  @message_id=0,
  @severity=21,
  @enabled=1,
  @delay_between_responses=0,
  @include_event_description_in=1,
  @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity Level 21 Alert: Fatal Error in Database Processes',
@operator_name=N'Operator1',
@notification_method = 1
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity Level 22 Alert: Fatal Error - Table or Index Integrity Suspect',
  @message_id=0,
  @severity=22,
  @enabled=1,
  @delay_between_responses=0,
  @include_event_description_in=1,
  @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity Level 22 Alert: Fatal Error - Table or Index Integrity Suspect',
@operator_name=N'Operator1',
@notification_method = 1
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity Level 23 Alert: Fatal Error - Database Integrity Suspect',
  @message_id=0,
  @severity=23,
  @enabled=1,
  @delay_between_responses=0,
  @include_event_description_in=1,
  @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity Level 23 Alert: Fatal Error - Database Integrity Suspect',
@operator_name=N'Operator1',
@notification_method = 1
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity Level 24 Alert: Fatal Error - Hardware Error',
  @message_id=0,
  @severity=24,
  @enabled=1,
  @delay_between_responses=0,
  @include_event_description_in=1,
  @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity Level 24 Alert: Fatal Error - Hardware Error',
@operator_name=N'Operator1',
@notification_method = 1
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity Level 25 Alert: Fatal Error - Hardware Error',
  @message_id=0,
  @severity=25,
  @enabled=1,
  @delay_between_responses=0,
  @include_event_description_in=1,
  @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity Level 25 Alert: Fatal Error - Hardware Error',
@operator_name=N'Operator1',
@notification_method = 1
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity Level 823 Alert: Fatal Error - I/O Error',
  @message_id=0,
  @severity=25,
  @enabled=1,
  @delay_between_responses=0,
  @include_event_description_in=1,
  @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity Level 823 Alert: Fatal Error - I/O Error',
@operator_name=N'Operator1',
@notification_method = 1
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity Level 824 Alert: Fatal Error - I/O Error',
  @message_id=0,
  @severity=25,
  @enabled=1,
  @delay_between_responses=0,
  @include_event_description_in=1,
  @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity Level 824 Alert: Fatal Error - I/O Error',
@operator_name=N'Operator1',
@notification_method = 1
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity Level 825 Alert: Fatal Error - I/O Error',
  @message_id=0,
  @severity=25,
  @enabled=1,
  @delay_between_responses=0,
  @include_event_description_in=1,
  @job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity Level 825 Alert: Fatal Error - I/O Error',
@operator_name=N'Operator1',
@notification_method = 1
GO