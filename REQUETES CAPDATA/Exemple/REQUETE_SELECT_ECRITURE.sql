SELECT ' BACKUP  DATABASE ' +name+ ' TO  DISK= N''\\aubfrcognossqlol\share_sql\'+name+'.BAK'' WITH NOFORMAT,
NOINIT,  NAME = N'''+name+'-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10 
GO
'
FROM sys.databases
where state_desc = 'ONLINE'
and is_read_only=0
and name not in ('master','msdb', 'model','tempdb')




