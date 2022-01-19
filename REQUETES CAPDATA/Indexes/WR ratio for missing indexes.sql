-- Calculer le ratio read/write pour les indexes indiqués comme 'missing' ********************************************************************************
-- Aaron Bertrand : http://www.sqlperformance.com/2013/06/t-sql-queries/missing-index
-- ratio write:read > 1, attention aux pénalités de mise à jour
-- ratio write:read > 0, OK plus le ratio est bas, plus il est en faveur d'une création d'index. 

---use <db>
GO

SELECT
  d.[object_id],
  s = OBJECT_SCHEMA_NAME(d.[object_id]),
  o = OBJECT_NAME(d.[object_id]),
  d.equality_columns,
  d.inequality_columns,
  d.included_columns,
  s.unique_compiles,
  s.user_seeks, s.last_user_seek,
  s.user_scans, s.last_user_scan,
  s.avg_total_user_cost,s.avg_user_impact
INTO #candidates
FROM sys.dm_db_missing_index_details AS d
INNER JOIN sys.dm_db_missing_index_groups AS g
ON d.index_handle = g.index_handle
INNER JOIN sys.dm_db_missing_index_group_stats AS s
ON g.index_group_handle = s.group_handle
WHERE d.database_id = DB_ID()
AND OBJECTPROPERTY(d.[object_id], 'IsMsShipped') = 0;

CREATE TABLE #planops
(
  o INT, 
  i INT, 
  h VARBINARY(64), 
  uc INT,
  Scan_Ops   INT, 
  Seek_Ops   INT, 
  Update_Ops INT
);

-- Could take a while (1-2 minutes)
with xmlnamespaces (default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
insert #planops
select o = coalesce(T1.o, T2.o),
   i = coalesce(T1.i, T2.i),
   h = coalesce(T1.h, T2.h),
   uc = coalesce(T1.uc, T2.uc),
   Scan_Ops = isnull(T1.Scan_Ops, 0),
   Seek_Ops = isnull(T1.Seek_Ops, 0),
   Update_Ops = isnull(T2.Update_Ops, 0)
from
  (
  select o = i.object_id,
     i = i.index_id,
     h = t.plan_handle,
     uc = t.usecounts,
     Scan_Ops = sum(case when t.LogicalOp in ('Index Scan', 'Clustered Index Scan') then 1 else 0 end),
     Seek_Ops = sum(case when t.LogicalOp in ('Index Seek', 'Clustered Index Seek') then 1 else 0 end)
  from (
     select 
       r.n.value('@LogicalOp', 'varchar(100)') as LogicalOp,
       o.n.value('@Index', 'sysname') as IndexName,
       pl.plan_handle,
       pl.usecounts
     from sys.dm_exec_cached_plans as pl
       cross apply sys.dm_exec_query_plan(pl.plan_handle) AS p
       cross apply p.query_plan.nodes('//RelOp') as r(n)
       cross apply r.n.nodes('*/Object') as o(n)
     where p.dbid = db_id()
     and p.query_plan is not null
   ) as t
  inner join sys.indexes as i
    on t.IndexName = quotename(i.name)
  where t.LogicalOp in ('Index Scan', 'Clustered Index Scan', 'Index Seek', 'Clustered Index Seek') 
  and exists (select 1 from #candidates as c where c.object_id = i.object_id)
  group by i.object_id,
       i.index_id,
       t.plan_handle,
       t.usecounts
  ) as T1
full outer join
  (
  select o = i.object_id,
      i = i.index_id,
      h = t.plan_handle,
      uc = t.usecounts,
      Update_Ops = count(*)
  from (
      select 
    o.n.value('@Index', 'sysname') as IndexName,
    pl.plan_handle,
    pl.usecounts
      from sys.dm_exec_cached_plans as pl
    cross apply sys.dm_exec_query_plan(pl.plan_handle) AS p
    cross apply p.query_plan.nodes('//Update') as r(n)
    cross apply r.n.nodes('Object') as o(n)
      where p.dbid = db_id()
      and p.query_plan is not null
    ) as t
  inner join sys.indexes as i
    on t.IndexName = quotename(i.name)
  where exists 
  (
    select 1 from #candidates as c where c.[object_id] = i.[object_id]
  )
  and i.index_id > 0
  group by i.object_id,
    i.index_id,
    t.plan_handle,
    t.usecounts
  ) as T2
on T1.o = T2.o and
   T1.i = T2.i and
   T1.h = T2.h and
   T1.uc = T2.uc;

SELECT [object_id], index_id, user_seeks, user_scans, user_lookups, user_updates 
INTO #indexusage
FROM sys.dm_db_index_usage_stats AS s
WHERE database_id = DB_ID()
AND EXISTS (SELECT 1 FROM #candidates WHERE [object_id] = s.[object_id]);

;WITH x AS 
(
  SELECT 
    c.[object_id],
    potential_read_ops = SUM(c.user_seeks + c.user_scans),
    [write_ops] = SUM(iu.user_updates),
    [read_ops] = SUM(iu.user_scans + iu.user_seeks + iu.user_lookups), 
    [write:read ratio] = CONVERT(DECIMAL(18,2), SUM(iu.user_updates)*1.0 / 
      SUM(iu.user_scans + iu.user_seeks + iu.user_lookups)), 
    current_plan_count = po.h,
    current_plan_use_count = po.uc
  FROM 
    #candidates AS c
  LEFT OUTER JOIN 
    #indexusage AS iu
    ON c.[object_id] = iu.[object_id]
  LEFT OUTER JOIN
  (
    SELECT o, h = COUNT(h), uc = SUM(uc)
      FROM #planops GROUP BY o
  ) AS po
    ON c.[object_id] = po.o
  GROUP BY c.[object_id], po.h, po.uc
)
SELECT [object] = QUOTENAME(c.s) + '.' + QUOTENAME(c.o),
  c.equality_columns,
  c.inequality_columns,
  c.included_columns,
  x.potential_read_ops,
  x.write_ops,
  x.read_ops,
  x.[write:read ratio],
  x.current_plan_count,
  x.current_plan_use_count,
  c.avg_total_user_cost,
  c.avg_user_impact
FROM #candidates AS c
INNER JOIN x 
ON c.[object_id] = x.[object_id]
ORDER BY x.[write:read ratio];



drop table #candidates
drop table #planops
drop table #indexusage