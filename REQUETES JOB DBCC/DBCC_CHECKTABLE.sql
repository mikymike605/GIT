dbcc traceon(3604)
Go
dbcc dbinfo(SID_PRD)
godbcc traceon(3604)
dbcc page(7,1,117071003,1)
dbcc traceoff(3604)



DBCC CHECKTABLE ('ODS.SEM_TICKET',REPAIR_REBUILD ) with ALL_ERRORMSGS