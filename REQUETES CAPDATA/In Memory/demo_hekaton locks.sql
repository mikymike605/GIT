

/*************************************************************************************************

CREATION BASE DB_HEKATON

*************************************************************************************************/

CREATE DATABASE DB_HEKATON;
GO
ALTER DATABASE DB_HEKATON MODIFY FILE (name='DB_HEKATON', size=20MB);
GO
ALTER DATABASE DB_HEKATON MODIFY FILE (name='DB_HEKATON_log', size=150MB);
GO

ALTER DATABASE DB_HEKATON ADD FILEGROUP [HEKATON_FG] CONTAINS MEMORY_OPTIMIZED_DATA;
GO
ALTER DATABASE DB_HEKATON ADD FILE ( name = HEKATON_DIR, filename = 'C:\HEKATON_DIR') TO FILEGROUP HEKATON_FG;
GO
/*************************************************************************************************

BASE DB_HEKATON

*************************************************************************************************/
USE DB_HEKATON;
GO

CREATE TABLE SESSION_CLASSIQUE(SessionId int NOT NULL, ApplicationName varchar(100) COLLATE Latin1_General_100_BIN2 NOT NULL, Expire datetime, CONSTRAINT PK_SC PRIMARY KEY NONCLUSTERED(SessionId, ApplicationName));
GO
CREATE TABLE SESSION_HEKATON_DURABLE(SessionId int NOT NULL, ApplicationName varchar(100) COLLATE Latin1_General_100_BIN2 NOT NULL, Expire datetime, CONSTRAINT PK_SHD PRIMARY KEY NONCLUSTERED(SessionId, ApplicationName)) 
WITH (MEMORY_OPTIMIZED=ON, DURABILITY= SCHEMA_AND_DATA);
GO
CREATE TABLE SESSION_HEKATON_NON_DURABLE(SessionId int NOT NULL, ApplicationName varchar(100) COLLATE Latin1_General_100_BIN2 NOT NULL, Expire datetime, CONSTRAINT PK_SHND PRIMARY KEY NONCLUSTERED(SessionId, ApplicationName)) 
WITH (MEMORY_OPTIMIZED=ON, DURABILITY= SCHEMA_ONLY);
GO
/*************************************************************************************************

100 000 insertions

*************************************************************************************************/
USE DB_HEKATON;
GO
SET NOCOUNT ON;
GO
/************************ INSERTION CLASSIQUE *************************************************************/

DECLARE @date_debut datetime2 = sysdatetime();
DECLARE @expiration datetime = DATEADD(hour,1,GETDATE());
DECLARE @Application varchar(100) = 'Appli Test ReBUILD';
DECLARE @MODE varchar(30) = 'Insertions Classiques'
DECLARE @cpt int=1;
BEGIN TRAN;
	WHILE @cpt <=1000000
	BEGIN
		INSERT INTO dbo.SESSION_CLASSIQUE VALUES(@cpt,@Application, @expiration);
		set @cpt = @cpt + 1;
	END
--- locks
SELECT COUNT(*),
resource_type, 
CASE resource_type  WHEN 'OBJECT' THEN OBJECT_NAME(resource_associated_entity_id)  ELSE cast(resource_associated_entity_id as varchar) END AS resource_associated_entity_id,
request_status, 
request_mode,
request_session_id 
FROM sys.dm_tran_locks 
WHERE request_session_id =@@SPID
GROUP BY resource_type, 
CASE resource_type  WHEN 'OBJECT' THEN OBJECT_NAME(resource_associated_entity_id)  ELSE cast(resource_associated_entity_id as varchar) END,
request_status, 
request_mode,
request_session_id

COMMIT;

--- durée d'execution

SELECT @MODE as 'Mode d''insertion', DATEDIFF(ms, @date_debut, sysdatetime()) as 'Durée (millisecondes)'

--select count(*) from SESSION_CLASSIQUE
--TRUNCATE TABLE SESSION_CLASSIQUE;


GO

/************************ INSERTION MEMOIRE DURABLE *************************************************************/

DECLARE @date_debut datetime2 = sysdatetime();
DECLARE @expiration datetime = DATEADD(hour,1,GETDATE());
DECLARE @Application varchar(100) = 'Appli Test ReBUILD';
DECLARE @MODE varchar(30) = 'Insertions Mémoire Durable'
DECLARE @cpt int=1;
BEGIN TRAN;
	WHILE @cpt <=1000000
	BEGIN
		INSERT INTO dbo.SESSION_HEKATON_DURABLE VALUES(@cpt,@Application, @expiration);
		set @cpt = @cpt + 1;
	END
--- locks
SELECT COUNT(*),
resource_type, 
CASE resource_type  WHEN 'OBJECT' THEN OBJECT_NAME(resource_associated_entity_id)  ELSE cast(resource_associated_entity_id as varchar) END AS resource_associated_entity_id,
request_status, 
request_mode,
request_session_id 
FROM sys.dm_tran_locks 
WHERE request_session_id =@@SPID
GROUP BY resource_type, 
CASE resource_type  WHEN 'OBJECT' THEN OBJECT_NAME(resource_associated_entity_id)  ELSE cast(resource_associated_entity_id as varchar) END,
request_status, 
request_mode,
request_session_id

COMMIT;

--- temps d execution

SELECT @MODE as 'Mode d''insertion', DATEDIFF(ms, @date_debut, sysdatetime()) as 'Durée (millisecondes)'
GO

DELETE FROM SESSION_HEKATON_DURABLE;
GO

/************************ INSERTION MEMOIRE NON DURABLE *************************************************************/

DECLARE @date_debut datetime2 = sysdatetime();
DECLARE @expiration datetime = DATEADD(hour,1,GETDATE());
DECLARE @Application varchar(100) = 'Appli Test ReBUILD';
DECLARE @MODE varchar(30) = 'Insertions Mémoire Non Durable'
DECLARE @cpt int=1;
BEGIN TRAN;
	WHILE @cpt <=1000000
	BEGIN
		INSERT INTO dbo.SESSION_HEKATON_NON_DURABLE VALUES(@cpt,@Application, @expiration);
		set @cpt = @cpt + 1;
	END
--- locks
SELECT COUNT(*),
resource_type, 
CASE resource_type  WHEN 'OBJECT' THEN OBJECT_NAME(resource_associated_entity_id)  ELSE cast(resource_associated_entity_id as varchar) END AS resource_associated_entity_id,
request_status, 
request_mode,
request_session_id 
FROM sys.dm_tran_locks 
WHERE request_session_id =@@SPID
GROUP BY resource_type, 
CASE resource_type  WHEN 'OBJECT' THEN OBJECT_NAME(resource_associated_entity_id)  ELSE cast(resource_associated_entity_id as varchar) END,
request_status, 
request_mode,
request_session_id

COMMIT;

--- temps d execution

SELECT @MODE as 'Mode d''insertion', DATEDIFF(ms, @date_debut, sysdatetime()) as 'Durée (millisecondes)'

GO
DELETE FROM SESSION_HEKATON_NON_DURABLE;
GO

/************************ INSERTION MEMOIRE NON DURABLE VIA PROCEDURE NATIVE *************************************************************/

IF OBJECT_ID('Insertion_Native') IS NOT NULL
DROP PROCEDURE dbo.Insertion_Native
GO
CREATE PROCEDURE Insertion_Native
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS
BEGIN ATOMIC
WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')
	DECLARE @date_debut datetime2 = sysdatetime();
	DECLARE @expiration datetime = DATEADD(hour,1,GETDATE());
	DECLARE @Application varchar(100) = 'Appli Test ReBUILD';
	DECLARE @MODE varchar(30) = 'Insertions Mémoire Non Durable procédure Native'
	DECLARE @cpt int=1;

	WHILE @cpt <=1000000
		BEGIN
			INSERT INTO dbo.SESSION_HEKATON_NON_DURABLE VALUES(@cpt,@Application, @expiration);
			set @cpt = @cpt + 1;
		END
	SELECT @MODE as 'Mode d''insertion', DATEDIFF(ms, @date_debut, sysdatetime()) as 'Durée (millisecondes)'
END;
GO
DELETE FROM SESSION_HEKATON_NON_DURABLE;
GO

EXECUTE Insertion_Native
--- locks
SELECT COUNT(*),
resource_type, 
CASE resource_type  WHEN 'OBJECT' THEN OBJECT_NAME(resource_associated_entity_id)  ELSE cast(resource_associated_entity_id as varchar) END AS resource_associated_entity_id,
request_status, 
request_mode,
request_session_id 
FROM sys.dm_tran_locks 
WHERE request_session_id =@@SPID
GROUP BY resource_type, 
CASE resource_type  WHEN 'OBJECT' THEN OBJECT_NAME(resource_associated_entity_id)  ELSE cast(resource_associated_entity_id as varchar) END,
request_status, 
request_mode,
request_session_id

GO



USE master;
GO
DROP DATABASE DB_HEKATON;
GO



