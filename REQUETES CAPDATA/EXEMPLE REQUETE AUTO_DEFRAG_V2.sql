
SELECT  'ALTER INDEX '+'['+dbindexes.[name]+']'+  ' on ' +'['+dbschemas.[name]+']'+'.'+dbtables.[name]+' REBUILD WITH (ONLINE=ON);',
indexstats.avg_fragmentation_in_percent,
indexstats.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
and dbtables.names not in ('ODS.sem_ticket')
and avg_fragmentation_in_percent >=30
and indexstats.page_count > 1500
and dbindexes.[name] is not null
ORDER BY indexstats.avg_fragmentation_in_percent desc



SELECT dbschemas.[name] as 'Schema',
dbtables.[name] as 'Table',
dbindexes.[name] as 'Index',
indexstats.avg_fragmentation_in_percent,
indexstats.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
and avg_fragmentation_in_percent >=30
and dbindexes.[name] is not null
ORDER BY indexstats.avg_fragmentation_in_percent desc


ALTER INDEX PK__temp_ent__CAABC5F40EC32C7A on temp_entmut REBUILD WITH (ONLINE=ON)
ALTER INDEX PK__temp_mar__1ABA75A66F4A8121 on temp_marges REBUILD WITH (ONLINE=ON)
ALTER INDEX PK__temp_dep__B6DE9F891B29035F on temp_deprec REBUILD WITH (ONLINE=ON)
ALTER INDEX PK__temp_per__041EF00060083D91 on temp_pertes REBUILD WITH (ONLINE=ON)
ALTER INDEX PK__trhr_moi__AE59876459904A2C on trhr_mois REBUILD WITH (ONLINE=ON)
ALTER INDEX PK__rep_mp_m__F2D5137B7D63964E on rep_mp_m REBUILD WITH (ONLINE=ON)
ALTER INDEX PK__rep_mp_h__9094FFCA031C6FA4 on rep_mp_h REBUILD WITH (ONLINE=ON)
ALTER INDEX PK__rep_de_m__E61A99CE08D548FA on rep_de_m REBUILD WITH (ONLINE=ON)
ALTER INDEX PK__temp_rec__9686DF3011D4A34F on temp_recetp REBUILD WITH (ONLINE=ON)
ALTER INDEX PK__res_inv__30218E2C03A67F89 on res_inv REBUILD WITH (ONLINE=ON)
ALTER INDEX test_Key_P1_Organne on test_organne REBUILD WITH (ONLINE=ON)
ALTER INDEX PK__tacode__51983335451F3D2B on tacode REBUILD WITH (ONLINE=ON)
ALTER INDEX PK__tacoca__41244D884DB4832C on tacoca REBUILD WITH (ONLINE=ON)
ALTER INDEX PK__dr__ABE3CCB069279377 on dr REBUILD WITH (ONLINE=ON)
ALTER INDEX PK__tacoca2__41244D8849E3F248 on tacoca2 REBUILD WITH (ONLINE=ON)
ALTER INDEX PK__ptamutp1__E26A79EE1AF3F935 on ptamutp1 REBUILD WITH (ONLINE=ON)
ALTER INDEX PK__dimensio__51335C762EC5E7B8 on dimension1 REBUILD WITH (ONLINE=ON)
ALTER INDEX PK__societe__FCE010736CF8245B on societe REBUILD WITH (ONLINE=ON)

SELECT dbschemas.[name] as 'Schema',
dbtables.[name] as 'Table',
dbindexes.[name] as 'Index',
indexstats.avg_fragmentation_in_percent,
indexstats.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
and avg_fragmentation_in_percent >=30
and dbindexes.[name] is not null
ORDER BY indexstats.avg_fragmentation_in_percent desc


SELECT  'ALTER INDEX '+dbindexes.[name]+  ' on '  + dbtables.[name]+' REBUILD --WITH (ONLINE=ON)'
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
ORDER BY indexstats.avg_fragmentation_in_percent desc

--ALTER INDEX PK__res_per__30218E2C793DFFAF on res_per REBUILD with (online = on) ;

SELECT 'exec maj_statistiques_base ''' + name + ''', ''OUI'' ; print ''*******''+''' + name + '''+''*****'''
FROM sys.databases
where state_desc = 'ONLINE'
and is_read_only=0
and name not in ('master','msdb', 'model','tempdb')