Select
	Case
		When SERVERPROPERTY ('InstanceName') is not null then SERVERPROPERTY ('InstanceName')
		When @@SERVERNAME is not null then @@SERVERNAME
		When SERVERPROPERTY ('ServerName') is not null then SERVERPROPERTY ('ServerName')
		else SERVERPROPERTY ('MachineName') 
	end 

Select COALESCE (
				SERVERPROPERTY ('InstanceName'), 
				@@SERVERNAME, 
				SERVERPROPERTY ('ServerName'), 
				SERVERPROPERTY ('MachineName')
				)