select * 
from sys.sysprocesses
where spid>50
and waittime >0

EXEC sp_who2

DBCC INPUTBUFFER (129)

SELECT * FROM sys.sysprocesses
where spid=125