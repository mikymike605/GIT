select 
  stuff( 
     (select ', <' + name + '>' 
     from sys.databases 
     where database_id > 4 
     order by name 
     for xml path(''), root('MyString'), type 
     ).value('/MyString[1]','varchar(max)')
   , 1, 2, '') as namelist;