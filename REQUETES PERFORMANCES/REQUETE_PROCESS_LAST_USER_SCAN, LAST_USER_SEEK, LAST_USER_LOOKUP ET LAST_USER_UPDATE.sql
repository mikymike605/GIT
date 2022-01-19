Select Distinct
@@ServerName As ServerName
,Name As DBName 
,Max(Login_Time) As LoginTime 
,Max(Last_Batch) As LastBatch 
,Coalesce([Status], '') As [Status] 
,Coalesce(HostName, '') As HostName 
,Coalesce(Program_Name, '') As ProgramName 
,Coalesce(NT_UserName,'') As NTUserName 
,Coalesce(LogiName,'') As LogiName 
,Max(last_user_SCAN) As last_user_Scan 
,Max(last_user_Seek) As last_user_Seek 
,Max(last_user_Lookup) As last_user_Lookup 
,Max(last_user_Update) As last_user_Update 
From 
sys.databases d
Left Join 
master.dbo.sysprocesses sp On (d.database_id = sp.dbid)
Left Join 
sys.dm_db_index_usage_stats i on (d.database_id=i.database_id)
Where 
d.database_id Not Between 1 and 4 /* Exclude system databases */
and Name='SID_PRD'
Group By 
d.database_id 
,Name 
,Coalesce([Status],'') 
,Coalesce(HostName,'') 
,Coalesce(Program_Name,'') 
,Coalesce(NT_UserName,'') 
,Coalesce(LogiName,'')