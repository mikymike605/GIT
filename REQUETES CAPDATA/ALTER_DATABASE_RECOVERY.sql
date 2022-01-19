SELECT 'ALTER DATABASE ' + name + ' SET RECOVERY SIMPLE' 
FROM master.sys.databases
where name in ('master','model','msdb','tempdb')
and recovery_model_desc='FULL'
