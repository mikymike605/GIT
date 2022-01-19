USE TEST_REPLICATION
GO
SELECT t.name 'Tables without any Indexes',o.type_desc, o.create_date,I.rowcnt as nblignes
FROM sys.tables t
INNER JOIN sys.objects o ON  t.object_id = o.object_id
INNER JOIN sys.sysindexes I ON I.id = o.object_id 
WHERE o.type_desc = 'USER_TABLE' AND  I.indid < 2
AND OBJECTPROPERTY(t.OBJECT_ID,'TableHasIndex')=0
ORDER BY I.rowcnt desc