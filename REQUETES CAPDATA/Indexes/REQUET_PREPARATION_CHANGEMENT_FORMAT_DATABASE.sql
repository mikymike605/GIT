DECLARE @CMD varchar (MAX)
SET @CMD = ' '
SELECT @CMD=@CMD+'ALTER DATABASE ['+name+'] SET RECOVERY SIMPLE WITH NO_WAIT '+CHAR(13) FROM sys.databases
where recovery_model_desc = 'FULL'
and state_desc='ONLINE'
and database_id >4

print @CMD
---exec @CMD
