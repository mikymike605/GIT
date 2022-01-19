declare @CMD varchar(max)
SET @CMD  = '--- backup to NULL ' + CHAR(13)
select @CMD=@CMD+'BACKUP LOG ['+name+'] TO  DISK = N''NULL'' WITH NOFORMAT, INIT,  NAME = N''Sauvegarde destinée à libérer les TLOG'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10;'+CHAR(13) 
from sys.databases where state_desc = 'ONLINE' and recovery_model_desc <> 'SIMPLE'
print(@CMD)
--exec(@CMD)

DECLARE @CMD2 varchar(max)
SET @CMD2  = '--- Shrink log ' + CHAR(13)
select @CMD2=@CMD2+'USE '+d.name+' DBCC SHRINKFILE ('+m.name+',0,TRUNCATEONLY);'+CHAR(13) 
--SELECT d.name,m.name 
from sys.master_files m inner join sys.databases d on m.database_id=d.database_id where type_desc='log' and m.database_id >4
print(@CMD2)
exec(@CMD2)
--USE [MDS]
--GO
--DBCC SHRINKFILE (N'MDS_log' , 0, TRUNCATEONLY)
--GO

