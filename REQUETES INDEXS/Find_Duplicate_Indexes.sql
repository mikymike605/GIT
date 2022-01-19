select t1.tablename,t1.indexname,t1.columnlist,t2.indexname,t2.columnlist, t1.[Index size (MB)] from
   (select distinct object_name(i.object_id) tablename,i.name indexname,
   8 * SUM(au.used_pages) AS 'Index size (KB)',
CAST(8 * SUM(AU.used_pages) / 1024.0 AS DECIMAL(18,2)) AS 'Index size (MB)',
CAST(8 * SUM(AU.used_pages) / 1024.0/1024.0 AS DECIMAL(18,2)) AS 'Index size (GB)',
		(select distinct stuff
			((select ', ' + c.name
			  from sys.index_columns ic1 
				inner join sys.columns c on ic1.object_id=c.object_id 
				 and  ic1.column_id=c.column_id
				  where ic1.index_id = ic.index_id 
					and  ic1.object_id=i.object_id 
					and  ic1.index_id=i.index_id
			  order by index_column_id FOR XML PATH('')),1,2,'')
		 from sys.index_columns ic 
		 where object_id=i.object_id and index_id=i.index_id) as columnlist
	 from sys.indexes i
	 inner join sys.index_columns ic on i.object_id=ic.object_id and i.index_id=ic.index_id 
     inner join sys.objects o on i.object_id=o.object_id 
    INNER JOIN sys.partitions P ON P.OBJECT_ID = I.OBJECT_ID AND P.index_id = I.index_id
    INNER JOIN sys.allocation_units AU ON AU.container_id = P.partition_id
    where o.is_ms_shipped=0 
	group by i.object_id, i.name,i.index_id) t1 
   inner join (select distinct object_name(i.object_id) tablename,i.name indexname,
(select distinct stuff
	((select ', ' + c.name
     from sys.index_columns ic1 
	 inner join  sys.columns c on ic1.object_id=c.object_id 
	 and  ic1.column_id=c.column_id
     where ic1.index_id = ic.index_id 
	 and ic1.object_id=i.object_id 
	 and  ic1.index_id=i.index_id
     order by index_column_id FOR XML PATH('')),1,2,'')
from sys.index_columns ic 
where object_id=i.object_id and index_id=i.index_id) as columnlist
 from sys.indexes i 
 inner join  sys.index_columns ic on i.object_id=ic.object_id and  i.index_id=ic.index_id 
inner join sys.objects o on i.object_id=o.object_id 
JOIN sys.partitions P ON P.OBJECT_ID = I.OBJECT_ID AND P.index_id = I.index_id
JOIN sys.allocation_units AU ON AU.container_id = P.partition_id
 where o.is_ms_shipped=0 group by i.object_id, i.name,i.index_id) t2 
 on t1.tablename=t2.tablename and substring(t2.columnlist,1,len(t1.columnlist))=t1.columnlist 
 and (t1.columnlist<>t2.columnlist or (t1.columnlist=t2.columnlist and t1.indexname<>t2.indexname))
 ----group by sys.indexes.object_id
 order by 1-- desc
