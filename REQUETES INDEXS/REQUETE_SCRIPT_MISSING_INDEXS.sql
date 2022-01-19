SELECT 
db_name(d.database_id) dbname
 ,object_name(d.object_id) tablename
, d.equality_columns
, d.inequality_columns
, d.included_columns
,'CREATE INDEX [missing_index_' + CONVERT (varchar, g.index_group_handle) + '_' + CONVERT (varchar, d.index_handle)
      + '_' + LEFT (PARSENAME(d.statement, 1), 32) + ']'
      + ' ON ' + d.statement
      + ' (' + ISNULL (d.equality_columns,'')
        + CASE WHEN d.equality_columns IS NOT NULL AND d.inequality_columns IS NOT NULL THEN ',' ELSE '' END
        + ISNULL (d.inequality_columns, '')
      + ')'
      + ISNULL (' INCLUDE (' + d.included_columns + ')', '') AS create_index_statement
       FROM  sys.dm_db_missing_index_groups g
       join sys.dm_db_missing_index_group_stats gs ON gs.group_handle = g.index_group_handle
       join sys.dm_db_missing_index_details d ON g.index_handle = d.index_handle
WHERE  d.database_id =  db_id() and d.object_id =  d.object_id
ORDER BY 2 DESC  