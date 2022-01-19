--------------------------------------------------------------------------------------------------------------------------------									
------------------------------------------------/*CREATE DATABASE */------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

CREATE DATABASE neoftp_AFE
CREATE DATABASE neoftp_ARL
CREATE DATABASE neoftp_BER
CREATE DATABASE neoftp_CKC
CREATE DATABASE neoftp_CNN
CREATE DATABASE neoftp_DOU
CREATE DATABASE neoftp_ECO
CREATE DATABASE neoftp_ERA
CREATE DATABASE neoftp_FIN
CREATE DATABASE neoftp_GIP
CREATE DATABASE neoftp_HPL
CREATE DATABASE neoftp_LEB
CREATE DATABASE neoftp_LUN
CREATE DATABASE neoftp_MLC
CREATE DATABASE neoftp_MUT
CREATE DATABASE neoftp_MVA
CREATE DATABASE neoftp_NPO
CREATE DATABASE neoftp_O18
CREATE DATABASE neoftp_REV
CREATE DATABASE neoftp_SCC
CREATE DATABASE neoftp_SPG
CREATE DATABASE neoftp_STD
CREATE DATABASE neoftp_TER
CREATE DATABASE neoftp_VAL
CREATE DATABASE neoftp_WZL
CREATE DATABASE neoftp_ZOD



--------------------------------------------------------------------------------------------------------------------------------									
------------------------------------------------/*CREATE LOGIN USER */----------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
USE [master] 
GO
 CREATE LOGIN [usr_neoftp_AFE] WITH PASSWORD=N'AdmOra2 15!', DEFAULT_DATABASE=[neoftp_AFE], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_AFE 			
GO	
CREATE USER [usr_neoftp_AFE]
GO						
USE neoftp_AFE
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_AFE]
GO	
					
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_ARELISSAS]	WITH PASSWORD=N'AdmOra2 15!', DEFAULT_DATABASE=[neoftp_ARL], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO						
USE neoftp_ARL 
GO	
CREATE USER [usr_neoftp_ARELISSAS]
GO						
USE neoftp_ARL 
GO	ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_ARELISSAS]
GO
						
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_BERICAP] WITH PASSWORD=N'AdmOra2 15!', DEFAULT_DATABASE=[neoftp_BER], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_BER 
GO	
CREATE USER [usr_neoftp_BERICAP]
GO						
USE neoftp_BER 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_BERICAP]
GO	
					
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_CKCOMPONENTS] WITH PASSWORD=N'AdmOra2 15!', DEFAULT_DATABASE=[neoftp_CKC], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_CKC 
GO	
CREATE USER [usr_neoftp_CKCOMPONENTS]
GO						
USE neoftp_CKC 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_CKCOMPONENTS]
GO	
					
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_CUNNINGHAMLINDSEY] WITH PASSWORD=N'AdmOra2 15!', DEFAULT_DATABASE=[neoftp_CNN], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_CNN 
GO	
CREATE USER [usr_neoftp_CUNNINGHAMLINDSEY]
GO						
USE neoftp_CNN 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_CUNNINGHAMLINDSEY]
GO	
					
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_DOUX] WITH PASSWORD=N'AdmOra2 15!', DEFAULT_DATABASE=[neoftp_DOU], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_DOU 
GO	
CREATE USER [usr_neoftp_DOUX]
GO						
USE neoftp_DOU
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_DOUX]
GO
						
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_ECOLAB] WITH PASSWORD=N'AdmOra2 15!', DEFAULT_DATABASE=[neoftp_ECO], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_ECO 
GO	
CREATE USER [usr_neoftp_ECOLAB]
GO						
USE neoftp_ECO 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_ECOLAB]
GO	
					
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_ERAMET] WITH PASSWORD=N'AdmOra2 15!', DEFAULT_DATABASE=[neoftp_ERA], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_ERA 
GO	
CREATE USER [usr_neoftp_ERAMET]
GO						
USE neoftp_ERA 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_ERAMET]
GO	
					
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_FINAXOENVIRONNEME] WITH PASSWORD=N'AdmOra2 15!', DEFAULT_DATABASE=[neoftp_FIN], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_FIN
 GO	
 CREATE USER [usr_neoftp_FINAXOENVIRONNEME]
GO						
USE neoftp_FIN 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_FINAXOENVIRONNEME]
GO						
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_GIEP] WITH PASSWORD=N'AdmOra2 15!', DEFAULT_DATABASE=[neoftp_GIP], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_GIP 
GO	
CREATE USER [usr_neoftp_GIEP]
GO						
USE neoftp_GIP 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_GIEP]
GO						
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_HLMPIERRESETLU] WITH PASSWORD=N'AdmOra2 15!', DEFAULT_DATABASE=[neoftp_HPL], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_HPL 
GO	
CREATE USER [usr_neoftp_HLMPIERRESETLU]
GO						
USE neoftp_HPL 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_HLMPIERRESETLU]
GO						
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_LEBASSYSTEM] WITH PASSWORD=N'AdmOra2 15!', DEFAULT_DATABASE=[neoftp_LEB], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_LEB 
GO	
CREATE USER [usr_neoftp_LEBASSYSTEM]
GO						
USE neoftp_LEB 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_LEBASSYSTEM]
GO						
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_GUILDEDESLUNETIER] WITH PASSWORD=N'AdmOra2 15!', DEFAULT_DATABASE=[neoftp_LUN], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_LUN 
GO	
CREATE USER [usr_neoftp_GUILDEDESLUNETIER]
GO						
USE neoftp_LUN 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_GUILDEDESLUNETIER]
GO						
USE [master] 
GO
 CREATE LOGIN [usr_neoftp_MAIRIEDELEZIGNANC] WITH PASSWORD=N'AdmOra2 15!', DEFAULT_DATABASE=[neoftp_MLC], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_MLC 
GO	
CREATE USER [usr_neoftp_MAIRIEDELEZIGNANC]
GO						
USE neoftp_MLC
 GO	
 ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_MAIRIEDELEZIGNANC]
GO						
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_NEOCLES] WITH PASSWORD=N'AdmOra2 15!', DEFAULT_DATABASE=[neoftp_MUT], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_MUT 
GO	
CREATE USER [usr_neoftp_NEOCLES]
GO						
USE neoftp_MUT 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_NEOCLES]
GO						
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_MAIRIEDEVILLEDAVR] WITH PASSWORD=N'AdmOra2 15!', DEFAULT_DATABASE=[neoftp_MVA], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_MVA 
GO	
CREATE USER [usr_neoftp_MAIRIEDEVILLEDAVR]
GO						
USE neoftp_MVA 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_MAIRIEDEVILLEDAVR]
GO						
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_NEOPOST] WITH PASSWORD=N'AdmOra2 15!', DEFAULT_DATABASE=[neoftp_NPO], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_NPO 
GO	
CREATE USER [usr_neoftp_NEOPOST]
GO						
USE neoftp_NPO
GO
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_NEOPOST]
GO						
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_OPH18] WITH PASSWORD=N'AdmOra2015!', DEFAULT_DATABASE=[neoftp_O18], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE [neoftp_O18] 
GO	
CREATE USER [usr_neoftp_OPH18]
GO						
USE [neoftp_O18] 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_OPH18]
GO						
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_REVIMA] WITH PASSWORD=N'AdmOra2015!', DEFAULT_DATABASE=[neoftp_REV], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_REV 
GO	
CREATE USER [usr_neoftp_REVIMA]
GO						
USE neoftp_REV 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_REVIMA]
GO						
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_SOCIETEDESCENTREC] WITH PASSWORD=N'AdmOra2015!', DEFAULT_DATABASE=[neoftp_SCC], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_SCC 
GO	
CREATE USER [usr_neoftp_SOCIETEDESCENTREC]
GO						
USE neoftp_SCC 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_SOCIETEDESCENTREC]
GO						
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_SPEIG] WITH PASSWORD=N'AdmOra2015!', DEFAULT_DATABASE=[neoftp_SPG], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_SPG 
GO	
CREATE USER [usr_neoftp_SPEIG]
GO						
USE neoftp_SPG 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_SPEIG]
GO						
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_STRADAL] WITH PASSWORD=N'AdmOra2015!', DEFAULT_DATABASE=[neoftp_STD], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_STD 
GO	
CREATE USER [usr_neoftp_STRADAL]
GO						
USE neoftp_STD
 GO	
 ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_STRADAL]
GO						
USE [master]
 GO 
 CREATE LOGIN [usr_neoftp_TERENVI] WITH PASSWORD=N'AdmOra2015!', DEFAULT_DATABASE=[neoftp_TER], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_TER 
GO	
CREATE USER [usr_neoftp_TERENVI]
GO						
USE neoftp_TER 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_TERENVI]
GO						
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_AGGLOVALDORGE] WITH PASSWORD=N'AdmOra2015!', DEFAULT_DATABASE=[neoftp_VAL], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_VAL 
GO	
CREATE USER [usr_neoftp_AGGLOVALDORGE]
GO						
USE neoftp_VAL 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_AGGLOVALDORGE]
GO						
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_WANZL] WITH PASSWORD=N'AdmOra2015!', DEFAULT_DATABASE=[neoftp_WZL], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_WZL 
GO	
CREATE USER [usr_neoftp_WANZL]
GO						
USE neoftp_WZL 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_WANZL]
GO						
USE [master] 
GO 
CREATE LOGIN [usr_neoftp_INLHC] WITH PASSWORD=N'AdmOra2015!', DEFAULT_DATABASE=[neoftp_ZOD], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF	
GO						
USE neoftp_ZOD 
GO	
CREATE USER [usr_neoftp_INLHC]
GO						
USE neoftp_ZOD 
GO	
ALTER ROLE [db_owner] ADD MEMBER [usr_neoftp_INLHC]
GO						
