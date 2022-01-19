SELECT 'exec maj_statistiques_base ''' + name + ''', ''OUI'' ; print ''*******''+''' + name + '''+''*****'''
FROM sys.databases
where state_desc = 'ONLINE'
and is_read_only=0
and name not in ('master','msdb', 'model','tempdb')

SELECT 'exec defragmente_base ''' + name + ''', ''OUI'' ; print ''*******''+''' + name + '''+''*****'''
FROM sys.databases
where state_desc = 'ONLINE'
and is_read_only=0
and name not in ('master','msdb', 'model','tempdb')

