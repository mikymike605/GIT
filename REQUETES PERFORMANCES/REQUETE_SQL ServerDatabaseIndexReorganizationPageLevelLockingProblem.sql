---------------------------------------------------------------------------------------------------------------------------
--https://interworks.com/blog/bbickell/2010/05/10/sql-server-index-indexname-table-tablename-cannot-be-reorganized-because/
---------------------------------------------------------------------------------------------------------------------------

SELECT 'ALTER INDEX [' + I.name + '] ON [' +  T.name + '] SET (ALLOW_PAGE_LOCKS = ON)' As Command,
I.name,I.type_desc,I.is_disabled,I.allow_page_locks,I.allow_row_locks
FROM sys.indexes I
LEFT OUTER JOIN sys.tables T ON I.object_id = T.object_id
WHERE I.allow_page_locks = 0 AND T.name IS NOT NULL

---------------------------------------------------------------------------------------------------------------------------
--https://interworks.com/blog/bbickell/2010/05/10/sql-server-index-indexname-table-tablename-cannot-be-reorganized-because/
---------------------------------------------------------------------------------------------------------------------------
