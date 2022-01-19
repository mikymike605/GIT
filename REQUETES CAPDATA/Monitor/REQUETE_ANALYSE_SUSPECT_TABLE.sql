DECLARE @servername varchar(250) 
DECLARE @requete varchar(5000) 
DECLARE product_cursor CURSOR FOR 


SELECT name FROM [AdminMonitor]..[Server] 

OPEN product_cursor 
FETCH FROM product_cursor INTO @SERVERNAME 

WHILE @@FETCH_STATUS = 0 
BEGIN 
--set @servername = +'['+@servername+']'+'' 

PRINT @SERVERNAME 
set @requete = 'select '''+@SERVERNAME+''', sp.database_id "Database ID",
       d.name "Database",
       sp.file_id "File ID",
       mf.physical_name "File",
       sp.page_id "Page ID",
       case when sp.event_type = 1 then ''823 or 824 error other than a bad checksum or a torn page''
            when sp.event_type = 2 then ''Bad checksum''
            when sp.event_type = 3 then ''Torn Page''
            when sp.event_type = 4 then ''Restored (The page was restored after it was marked bad)''
            when sp.event_type = 5 then ''Repaired (DBCC repaired the page)''
            when sp.event_type = 7 then ''Deallocated by DBCC''
       end as "Event Desc",
       sp.error_count "Error Count",
       sp.last_update_date "Last Updated"
from ['+@SERVERNAME+'].[msdb].dbo.suspect_pages sp
inner join ['+@SERVERNAME+'].[master].sys.databases d on d.database_id=sp.database_id
inner join ['+@SERVERNAME+'].[master].sys.master_files mf on mf.database_id=sp.database_id and mf.file_id=sp.file_id
'
PRINT @requete 

  EXEC  (@requete) 
                                                                
FETCH FROM product_cursor INTO @SERVERNAME 
END 
CLOSE product_cursor 
DEALLOCATE product_cursor 
GO

