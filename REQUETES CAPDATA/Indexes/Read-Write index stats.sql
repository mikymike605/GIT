
declare @T table (DB varchar(1000),[Table Name] varchar(1000),[Index Name] varchar(1000),[Index_id] int,[Total Writes] int, [Total Reads] int, Difference int)
insert into @T
exec sp_MSforeachdb 'Use ? SELECT OBJECT_NAME(s.[object_id]) AS [ObjectName], i.name AS [IndexName], i.index_id,
	   user_seeks + user_scans + user_lookups AS [Reads], s.user_updates AS [Writes],  
	   i.type_desc AS [IndexType], i.fill_factor AS [FillFactor]
FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON s.[object_id] = i.[object_id]
WHERE OBJECTPROPERTY(s.[object_id],'IsUserTable') = 1
AND i.index_id = s.index_id
AND s.database_id = DB_ID()
ORDER BY user_seeks + user_scans + user_lookups DESC OPTION (RECOMPILE); -- Order by reads
'
select * from @T




SELECT OBJECT_NAME(s.[object_id]) AS [ObjectName]
	      , i.name AS [IndexName], i.index_id,
		  user_seeks + user_scans + user_lookups AS [Reads]
	      , s.user_updates AS [Writes],  
	      i.type_desc AS [IndexType]
	     , i.fill_factor AS [FillFactor]
		 ,s.user_updates / (CASE  user_seeks + user_scans + user_lookups when 0 then 1 else user_seeks + user_scans + user_lookups end)
		 ,*
FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON s.[object_id] = i.[object_id]
WHERE OBJECTPROPERTY(s.[object_id],'IsUserTable') = 1
AND i.index_id = s.index_id
AND s.database_id = DB_ID()
--AND s.user_updates > user_seeks + user_scans + user_lookups
AND i.type_desc not in ('HEAP')
AND s.user_updates / (CASE  user_seeks + user_scans + user_lookups when 0 then 1 else user_seeks + user_scans + user_lookups end) >1000
--ORDER BY user_seeks + user_scans + user_lookups DESC OPTION (RECOMPILE)
ORDER BY  s.user_updates / (CASE  user_seeks + user_scans + user_lookups when 0 then 1 else user_seeks + user_scans + user_lookups end) DESC OPTION (RECOMPILE)