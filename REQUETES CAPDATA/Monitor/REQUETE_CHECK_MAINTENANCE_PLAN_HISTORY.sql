SELECT
    mp.name AS [MTX Plan Name],
    msp.subplan_name AS [Sub Plan Name],    
    mpl.start_time AS [JobStart],
    mpl.end_time AS [JobEnd],
    mpl.succeeded AS [JobSucceeded]
FROM
    msdb.dbo.sysmaintplan_plans mp
    INNER JOIN msdb.dbo.sysmaintplan_subplans msp ON mp.id = msp.plan_id
    INNER JOIN msdb.dbo.sysmaintplan_log mpl ON msp.subplan_id = mpl.subplan_id
        AND mpl.task_detail_id = -- Get the most recent run for this database
            (SELECT TOP 1 ld.task_detail_id 
            FROM msdb.dbo.sysmaintplan_logdetail ld
            WHERE ld.command LIKE ('%['+db_name()+']%')
            ORDER BY ld.start_time DESC)


Select 
case when D.Succeeded=1 then 'Success' when D.succeeded=0 then 'Failed' End as Result,
A.name,B.subplan_name,D.line1,D.line2,D.line3,D.line4,
D.line5,D.start_time,D.end_time,D.command
From msdb.dbo.sysmaintplan_plans a 
	inner join msdb.dbo.sysmaintplan_subplans b 
			on a.id=b.plan_id
	inner join msdb.dbo.sysmaintplan_log c 
			on c.plan_id=b.plan_id and c.Subplan_id=b.subplan_id
	inner join msdb.dbo.sysmaintplan_logdetail d 
			on d.task_detail_id=c.task_detail_id
Order By D.start_time DESC