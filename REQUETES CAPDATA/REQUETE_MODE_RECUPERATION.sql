SELECT db.name AS [Base de données],
       fl.name AS [Groupe de fichier],
       fl.[physical_name] AS [Fichier physique],
       db.[recovery_model_desc] AS [Type de récupération]    
  FROM [msdb].[sys].[databases] db
  JOIN [msdb].[sys].[master_files] fl ON db.database_id = fl.database_id
  ORDER BY db.name, fl.[physical_name]
  

--USE MSDB

--ALTER DATABASE MSDB  SET RECOVERY SIMPLE WITH NO_WAIT

--DBCC SHRINKFILE(MSDBLog,0, TRUNCATEONLY)

--ALTER DATABASE MSDB SET RECOVERY FULL WITH NO_WAIT 