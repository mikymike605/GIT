Restore database master from disk = 'G:\bases\mssql\backup\master_20200724120758.bak' WITH REPLACE;

Restore database msdb from disk = 'G:\bases\mssql\backup\msdb_20200724120757.bak' WITH REPLACE;

Restore database model from disk = 'G:\bases\mssql\backup\model_20200724120757.bak' WITH REPLACE;

Setup /QUIET /ACTION=REBUILDDATABASE /INSTANCENAME=SV-R1PRJ-SAP001 /SQLSYSADMINACCOUNTS=LFIPRD01\srvmha /SAPWD=2=KWynbE /SQLCOLLATION=SQL_Latin1_General_CP1_CI_AS