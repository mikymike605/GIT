select substring(a.database_name,1,35) as 'Database',
datepart(year,a.backup_start_date) as 'year',
datepart(month,a.backup_start_date) as 'month' ,
avg(cast((a.backup_size /1073741824) as decimal (9,2)))as 'Avg Gig'
FROM msdb.dbo.backupset a
join msdb.dbo.backupset b on a.server_name = b.server_name and a.database_name = b.database_name
WHERE a.type = 'D' and b.type = 'D'
and a.backup_start_date >= '2012-12-01'
and a.database_name='SID_PRD'
GROUP BY a.database_name,datepart(year,a.backup_start_date),datepart(month,a.backup_start_date)
order by a.database_name,datepart(year,a.backup_start_date) desc,datepart(month,a.backup_start_date) desc