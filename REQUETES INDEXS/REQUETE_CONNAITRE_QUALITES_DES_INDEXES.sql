-- DROP INDEX [IDX_MDINVOICEDETAIL_INVOICEID_CATEGORY] ON [dbo].[MDInvoiceDetail];

/******* https://blog.developpez.com/sqlpro/p7010/ms-sql-server/quleques_requetes_sql_server_pour_connai ********/

/*******1 - index faiblement utilisés ********/

select OBJECT_NAME(IUS.object_id), I.name, IUS.user_seeks, IUS.user_scans, IUS.user_lookups, IUS.user_updates, 
       IUS.user_seeks + IUS.user_scans + IUS.user_lookups AS Total_use, 
       T.user_seeks + T.user_scans + T.user_lookups AS Table_use, 
       (CAST(IUS.user_seeks + IUS.user_scans + IUS.user_lookups AS FLOAT) / 
        NULLIF(CAST(T.user_seeks + T.user_scans + T.user_lookups AS FLOAT), 0)) * 100 AS efficacite_percent 
from   sys.dm_db_index_usage_stats AS IUS 
       INNER JOIN sys.indexes AS I 
             ON IUS.object_id = I.object_id 
                AND IUS.index_id = I.index_id   
       INNER JOIN sys.dm_db_index_usage_stats AS T 
             ON IUS.object_id = T.object_id 
                AND T.index_id IN (0, 1) 
where  IUS.database_id = DB_ID() 
--and OBJECT_NAME(IUS.object_id) = '[SEM_STORE_PLU]'
--and I.name = 'SAS_SEM_STORE_PLU_IX2'
  AND  I.name NOT IN (SELECT CONSTRAINT_NAME  
                      FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS) 
ORDER  BY efficacite_percent



/* https://blog.developpez.com/sqlpro/p7010/ms-sql-server/quleques_requetes_sql_server_pour_connai ********/
/*******2 – Cette requête génère un script SQL de suppression des index inutiles  ********/

select 'DROP INDEX [' + I.name +'] ON [' + SCHEMA_NAME(o.schema_id) + '].['+ OBJECT_NAME(IUS.object_id) +'];' 
from   sys.dm_db_index_usage_stats AS IUS 
       INNER JOIN sys.objects AS o 
             ON IUS.object_id = o.object_id  
       INNER JOIN sys.indexes AS I  
             ON IUS.object_id = I.object_id  
                AND IUS.index_id = I.index_id    
where  database_id = DB_ID()  
--and OBJECT_NAME(IUS.object_id) = 'SEM_V2_TLOG_SALE_HEADERS_HISTO'
  AND  user_seeks + user_scans + user_lookups = 0  
  AND  I.name NOT IN (SELECT CONSTRAINT_NAME   
                      FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS)


/******* https://blog.developpez.com/sqlpro/p7010/ms-sql-server/quleques_requetes_sql_server_pour_connai ********/


/*******3 – Contraintes d’intégrité non indexées  ********/

WITH 
T_IDX AS (SELECT TABLE_SCHEMA, TABLE_NAME, i.name AS INDEX_NAME,  
                 c.name AS COLUMN_NAME, key_ordinal AS ORDINAL_POSITION 
          FROM   sys.indexes AS i 
                 INNER JOIN sys.objects AS o 
                       ON i.object_id = o.object_id 
                 INNER JOIN sys.schemas AS s 
                       ON o.schema_id = s.schema_id 
                 INNER JOIN INFORMATION_SCHEMA.TABLES AS T 
                       ON s.name = T.TABLE_SCHEMA AND o.name = TABLE_NAME 
                 INNER JOIN sys.index_columns AS ic 
                       ON i.object_id = ic.object_id 
                          AND i.index_id = ic.index_id 
                 INNER JOIN sys.columns AS c 
                       ON i.object_id = c.object_id 
                          AND ic.column_id = c.column_id 
          WHERE is_included_column = 0), 
T_CFK AS (SELECT TC.TABLE_SCHEMA, TC.TABLE_NAME, TC.CONSTRAINT_NAME, 
                 COLUMN_NAME, ORDINAL_POSITION 
          FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC 
                 INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KCU 
                       ON TC.TABLE_SCHEMA = KCU.TABLE_SCHEMA 
                          AND TC.TABLE_NAME = KCU.TABLE_NAME 
                          AND TC.CONSTRAINT_NAME = KCU.CONSTRAINT_NAME 
          WHERE  CONSTRAINT_TYPE = 'FOREIGN KEY' 
		  )
SELECT T_CFK.TABLE_SCHEMA, T_CFK.TABLE_NAME, T_CFK.CONSTRAINT_NAME 
FROM   T_CFK 
EXCEPT     
SELECT T_CFK.TABLE_SCHEMA, T_CFK.TABLE_NAME, T_CFK.CONSTRAINT_NAME 
FROM   T_IDX 
       INNER JOIN T_CFK 
             ON T_IDX.TABLE_SCHEMA = T_CFK.TABLE_SCHEMA  
                AND T_IDX.TABLE_NAME = T_CFK.TABLE_NAME 
                AND T_IDX.COLUMN_NAME = T_CFK.COLUMN_NAME 
WHERE (SELECT COUNT(*) 
       FROM   T_IDX AS X 
       WHERE  X.TABLE_SCHEMA = T_CFK.TABLE_SCHEMA  
         AND  X.TABLE_NAME = T_CFK.TABLE_NAME 
         AND  X.COLUMN_NAME = T_CFK.COLUMN_NAME 
       GROUP  BY INDEX_NAME) = (SELECT COUNT(*) 
                                FROM   T_IDX AS K 
                                WHERE  K.TABLE_SCHEMA = T_CFK.TABLE_SCHEMA  
                                  AND  K.TABLE_NAME = T_CFK.TABLE_NAME 
                                  AND  K.COLUMN_NAME = T_CFK.COLUMN_NAME 
                                 GROUP  BY INDEX_NAME);