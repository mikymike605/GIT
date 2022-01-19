USE [DBAtools]
GO

CREATE TABLE [dbo].[BlockingScene](
[name] [varchar](20) NULL,
[Add] [varchar](20) NULL,
[City] [varchar](20) NULL
) ON [PRIMARY]

insert into BlockingScene values('Dharmesh','Maharashtra','Mumbai')
GO 100000


BEGIN TRANSACTION
select * from blockingScene WITH (TABLOCKx, HOLDLOCK)
waitfor delay '00:55:00' --will wait for 55 minutes.The format is ‘hh:mm:ss’
--release lock
commit transaction

select * from blockingScene


CREATE TABLE [dbo].[CaptureBlockingDetails](
[spid] [smallint] NULL,
[VillainSpid] [smallint] NULL,
[last_batch] [datetime] NULL,
[CurrentTime] [datetime] default getdate() NOT NULL,
[waittime] [bigint] NULL,
[waitresource] [nchar](256) NULL,
[lastwaittype] [nchar](32) NULL,
[CmdStatement] [nchar](16) NULL,
[RunningQueries] [nvarchar](max) NULL,
[DatabaseName] [sysname] NOT NULL,
[LoginName] [varchar](30) NULL,
[HostName] [varchar](30) NULL,
[cpu] [int] NULL
) ON [PRIMARY]
GO

/*
Created by: Dharmesh Mishra
Date/Time:14th June 2015,12:00 PM
Like my fb page:www.facebook.com/sqlserverkillers
-- exec Usp_sendMailNotificationWhenBlockingGoesAboveThreeMinutes
Visit my blogs:lapsql.wordpress.com
*/
USE [DBAtools]   ---use any system or user database
GO

/****** Object: StoredProcedure [dbo].[Usp_sendMailNotificationWhenBlockingGoesAboveThreeMinutes] Script Date: 06/14/2015 12:02:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Usp_sendMailNotificationWhenBlockingGoesAboveThreeMinutes]
as
begin

------------2nd insert value in created table for which is blocking more than 3 minutes-------------
insert into dbo.CaptureBlockingDetails(spid ,
VillainSpid ,
last_batch ,
waittime,
waitresource ,
lastwaittype ,
CmdStatement ,
DatabaseName ,
RunningQueries,
LoginName,
HostName,
cpu

) select sp.spid,sp.blocked, sp.last_batch,sp.waittime,sp.waitresource,sp.lastwaittype,sp.cmd, DB_NAME(sp.dbid),
st.[text],sp.loginame,sp.hostname,sp.cpu
from sys.sysprocesses sp
cross apply sys.dm_exec_sql_text(sp.sql_handle) st
where sp.spid>50 and sp.spid<>sp.blocked and sp.blocked<>0 --and datediff(mm,last_batch,GETDATE())>3
---final touch for sending mail notification when blocking duration goes above 3 Minutes
if (select top 1 DATEdiff(MI,last_batch,currenttime) from CaptureBlockingDetails where DATEdiff(MI,last_batch,currenttime)>3)>3

begin
print 'CPU Alert Condition True, Sending Email..'DECLARE @tableHTML NVARCHAR(MAX) ;
SET @tableHTML =
N'<H1 bgcolor="magenta">Blocking Found</H1>' +
N'<H2 bgcolor="magenta">SQL Server Session Details</H2>' +
N'<table border="1">' +
N'<tr bgcolor="RED"><th>spid</th><th>VillainSpid</th><th>last_batch</th><th>CurrentTime</th><th>waittime</th>'+
N'<th>waitresource</th><th>lastwaittype</th><th>CmdStatement</th><th>DatabaseName</th>'+
N'<th>RunningQueries</th><th>LoginName</th><th>HostName</th> <th>cpu</th></tr>'+

CAST ( ( SELECT distinct -- or all by using *

td= spid,'',
td= VillainSpid,'',
td= last_batch,'',
td= CurrentTime,'',
td= waittime,'',
td= waitresource,'',
td= lastwaittype,'',
td= CmdStatement,'',
td= DatabaseName,'',
td= RunningQueries,'',
td= LoginName,'',
td= HostName,'',
td=cpu,''from CaptureBlockingDetails
FOR XML PATH('tr'), TYPE )AS NVARCHAR(MAX))+N'</table>'

-- Change SQL Server Email notification code here
EXEC msdb.dbo.sp_send_dbmail
@recipients='mikael.hamchaoui@bkqservices.com',
@profile_name = 'EnvoiMail',
@subject = 'Blocking Found',
@body = @tableHTML,
@body_format = 'HTML';
END
-- Truncate the Table
truncate Table CaptureBlockingDetails
end
