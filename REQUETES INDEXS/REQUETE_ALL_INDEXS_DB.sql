select distinct object_name(i.object_id) tablename,i.name indexname,
        (select distinct stuff((select ', ' + c.name
                                  from sys.index_columns ic1 inner join 
                                       sys.columns c on ic1.object_id=c.object_id and 
                                                        ic1.column_id=c.column_id
                                 where ic1.index_id = ic.index_id and 
                                       ic1.object_id=i.object_id and 
                                       ic1.index_id=i.index_id
                                 order by index_column_id FOR XML PATH('')),1,2,'')
           from sys.index_columns ic 
          where object_id=i.object_id and index_id=i.index_id) as columnlist
  from sys.indexes i inner join 
       sys.index_columns ic on i.object_id=ic.object_id and i.index_id=ic.index_id inner join
       sys.objects o on i.object_id=o.object_id 
 where o.is_ms_shipped=0