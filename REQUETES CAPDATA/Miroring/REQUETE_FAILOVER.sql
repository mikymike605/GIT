
SELECT ' ALTER DATABASE ' +name+ ' SET PARTNER FAILOVER ;'
FROM sys.databases
where state_desc = 'ONLINE'
and is_read_only=0
and name not in ('master','msdb', 'model','tempdb')