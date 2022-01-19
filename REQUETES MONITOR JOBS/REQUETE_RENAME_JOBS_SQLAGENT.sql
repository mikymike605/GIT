USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'ADM - DatabaseBackup - SYSTEM_DATABASES - FULL',  
    @new_name = N'@-ADM - DatabaseBackup - SYSTEM_DATABASES - FULL',  
    @description = N' ',  
    @enabled = 0 ;  
GO  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'ADM - DatabaseBackup - USER_DATABASES - DIFF',  
    @new_name = N'@-ADM - DatabaseBackup - USER_DATABASES - DIFF',  
    @description = N' ',  
    @enabled = 0 ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'ADM - DatabaseBackup - USER_DATABASES - FULL',  
    @new_name = N'@-ADM - DatabaseBackup - USER_DATABASES - FULL',  
    @description = N' ',  
    @enabled = 0 ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'ADM - DatabaseBackup - USER_DATABASES - LOG',  
    @new_name = N'@-ADM - DatabaseBackup - USER_DATABASES - LOG',  
    @description = N' ',  
    @enabled = 0 ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'ADM - DatabaseIntegrityCheck - SYSTEM_DATABASES',  
    @new_name = N'@-ADM - DatabaseIntegrityCheck - SYSTEM_DATABASES',  
    @description = N' ',  
    @enabled = 0 ;  
GO 

EXEC dbo.sp_update_job  
    @job_name = N'ADM - DatabaseIntegrityCheck - USER_DATABASES',  
    @new_name = N'@-ADM - DatabaseIntegrityCheck - USER_DATABASES',  
    @description = N' ',  
    @enabled = 0 ;  
GO 

EXEC dbo.sp_update_job  
    @job_name = N'ADM - DBCC_CHECKDB',  
    @new_name = N'@-ADM - DBCC_CHECKDB',  
    @description = N' ',  
    @enabled = 0 ;  
GO 

EXEC dbo.sp_update_job  
    @job_name = N'ADM - Database Mirroring Monitor Job',  
    @new_name = N'@-ADM - Database Mirroring Monitor Job',  
    @description = N' ',  
    @enabled = 0 ;  
GO 
EXEC dbo.sp_update_job  
    @job_name = N'ADM - INDEX MAINTENANCE - JOB3',  
    @new_name = N'@-ADM - INDEX MAINTENANCE - JOB3',  
    @description = N' ',  
    @enabled = 0 ;  
GO 

EXEC dbo.sp_update_job  
    @job_name = N'ADM - INDEX MAINTENANCE PREPARE LIST',  
    @new_name = N'@-ADM - INDEX MAINTENANCE PREPARE LIST',  
    @description = N' ',  
    @enabled = 0 ;  
GO 
