----- envoi mail impossible - mail queue shutting down and not restart auto.
--06/12/2016 07:29:56,,Information,99,DatabaseMail process is shutting down,1256,,,12/06/2016 07:29:56,QUICK\adminsql
--06/12/2016 07:29:56,,Information,98,1) Exception Information<nl/>===================<nl/>Exception Type: Microsoft.SqlServer.Management.SqlIMail.Server.DataAccess.NoQueueDataException<nl/>Message: Database Mail shutting down. Mail queue has been stopped.<nl/>Data: System.Collections.ListDictionaryInternal<nl/>TargetSite: Microsoft.SqlServer.Management.SqlIMail.Server.Objects.QueueItem GetQueueItemFromCommand(System.Data.SqlClient.SqlCommand)<nl/>HelpLink: NULL<nl/>Source: DatabaseMailEngine<nl/><nl/>StackTrace Information<nl/>===================<nl/>   at Microsoft.SqlServer.Management.SqlIMail.Server.DataAccess.QueueDataReader.GetQueueItemFromCommand(SqlCommand c)<nl/>   at Microsoft.SqlServer.Management.SqlIMail.Server.DataAccess.QueueDataReader.GetQueueData(Int32 receiveTimeoutSec)<nl/>   at Microsoft.SqlServer.Management.SqlIMail.IMailProcess.QueueItemProcesser.GetDataFromQueue(DataAccessAdapter da<c/> Int32 lifetimeMinimumSec),1256,,,12/06/2016 07:29:56,QUICK\adminsql
---
--- Une des cause peut être la présence de mails bloqués dans l'externalMailQueue !
--- Il faut donc supprimer ces mails.
---

Use msdb
GO
exec sysmail_stop_sp -- stop mail queue
GO
Select count(*) from ExternalMailQueue -- verification présence mails bloqués (count > 0) 

--- SI COUNT > 0
Use msdb
GO
ALTER QUEUE ExternalMailQueue WITH STATUS = ON
set nocount on
declare @Conversation_handle uniqueidentifier;
declare @message_type nvarchar(256);
declare @counter bigint;
declare @counter2 bigint;
set @counter = (select count(*) from ExternalMailQueue)
set @counter2=0
while (@counter2 <= @counter)
begin
receive @Conversation_handle = conversation_handle, @message_type = message_type_name from ExternalMailQueue
set @counter2 = @counter2 + 1
end

Select count(*) from ExternalMailQueue -- verification présence mails bloqués (count = 0) 

USE msdb
GO
EXEC dbo.sysmail_start_sp --- start mail queue


