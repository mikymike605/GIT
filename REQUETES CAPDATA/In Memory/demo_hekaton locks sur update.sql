

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
ALTER DATABASE DB_HEKATON ADD FILE ( name = HEKATON_DIR, filename = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQL2014EVAL\MSSQL\DATA\HEKATON_DIR') TO FILEGROUP HEKATON_FG;
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
CREATE TABLE SESSION_HEKATON_NON_DURABLE_NAT(SessionId int NOT NULL, ApplicationName varchar(100) COLLATE Latin1_General_100_BIN2 NOT NULL, Expire datetime, CONSTRAINT PK_SHNDNAT PRIMARY KEY NONCLUSTERED(SessionId, ApplicationName)) 
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
DECLARE @MODE varchar(30) = 'Classiques'
DECLARE @cpt int=1;
DECLARE @cpu bigint
DECLARE @mem bigint
select @cpu=cpu,@mem=memusage from master..sysprocesses where  spid = @@spid
BEGIN TRAN;
	WHILE @cpt <=2000000
	BEGIN
		INSERT INTO dbo.SESSION_CLASSIQUE VALUES(@cpt,@Application, @expiration);
		set @cpt = @cpt + 1;
	END

--- durée d'execution

SELECT @MODE as 'Mode d''insertion', DATEDIFF(ms, @date_debut, sysdatetime()) as 'Durée (millisecondes)'

--- ressources

select @cpu=cpu-@cpu,@mem=memusage-@mem  from master..sysprocesses where  spid = @@spid
select @cpu as CpuTime, @mem as Memory

--- locks

SELECT COUNT(*) as nbLocks,
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


--select count(*) from SESSION_CLASSIQUE
--TRUNCATE TABLE SESSION_CLASSIQUE;


GO

/************************ INSERTION MEMOIRE DURABLE *************************************************************/

DECLARE @date_debut datetime2 = sysdatetime();
DECLARE @expiration datetime = DATEADD(hour,1,GETDATE());
DECLARE @Application varchar(100) = 'Appli Test ReBUILD';
DECLARE @MODE varchar(30) = 'Insertions Mémoire Durable'
DECLARE @cpt int=1;
DECLARE @cpu bigint
DECLARE @mem bigint

select @cpu=cpu,@mem=memusage from master..sysprocesses where  spid = @@spid

BEGIN TRAN;
	WHILE @cpt <=2000000
	BEGIN
		INSERT INTO dbo.SESSION_HEKATON_DURABLE VALUES(@cpt,@Application, @expiration);
		set @cpt = @cpt + 1;
	END

--- temps d execution

SELECT @MODE as 'Mode d''insertion', DATEDIFF(ms, @date_debut, sysdatetime()) as 'Durée (millisecondes)'

--- ressources

select @cpu=cpu-@cpu,@mem=memusage-@mem  from master..sysprocesses where  spid = @@spid
select @cpu as CpuTime, @mem as Memory

--- locks

SELECT COUNT(*) as nbLocks,
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
GO

---DELETE FROM SESSION_HEKATON_DURABLE;
GO

/************************ INSERTION MEMOIRE NON DURABLE *************************************************************/

DECLARE @date_debut datetime2 = sysdatetime();
DECLARE @expiration datetime = DATEADD(hour,1,GETDATE());
DECLARE @Application varchar(100) = 'Appli Test ReBUILD';
DECLARE @MODE varchar(30) = 'Insertions Mémoire Non Durable'
DECLARE @cpt int=1;
DECLARE @cpu bigint
DECLARE @mem bigint

select @cpu=cpu,@mem=memusage from master..sysprocesses where  spid = @@spid

BEGIN TRAN;
	WHILE @cpt <=2000000
	BEGIN
		INSERT INTO dbo.SESSION_HEKATON_NON_DURABLE VALUES(@cpt,@Application, @expiration);
		set @cpt = @cpt + 1;
	END

--- temps d execution

SELECT @MODE as 'Mode d''insertion', DATEDIFF(ms, @date_debut, sysdatetime()) as 'Durée (millisecondes)'

--- ressources

select @cpu=cpu-@cpu,@mem=memusage-@mem  from master..sysprocesses where  spid = @@spid
select @cpu as CpuTime, @mem as Memory

--- locks

SELECT COUNT(*) as nbLocks,
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
GO
---DELETE FROM SESSION_HEKATON_NON_DURABLE;
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
	DECLARE @MODE varchar(50) = 'Insertions Mémoire Non Durable procédure Native'
	DECLARE @cpt int=1;

	WHILE @cpt <=2000000-
		BEGIN
			INSERT INTO dbo.SESSION_HEKATON_NON_DURABLE_NAT VALUES(@cpt,@Application, @expiration);
			set @cpt = @cpt + 1;
		END
	SELECT @MODE as 'Mode d''insertion', DATEDIFF(ms, @date_debut, sysdatetime()) as 'Durée (millisecondes)'

END;
GO
---DELETE FROM SESSION_HEKATON_NON_DURABLE_NAT;
GO
DECLARE @cpu bigint
DECLARE @mem bigint

select @cpu=cpu,@mem=memusage from master..sysprocesses where  spid = @@spid


EXECUTE Insertion_Native

--- ressources

select @cpu=cpu-@cpu,@mem=memusage-@mem  from master..sysprocesses where  spid = @@spid
select @cpu as CpuTime, @mem as Memory

--- locks

SELECT COUNT(*) as nbLocks,
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

/****************** UPDATES CLASSIQUE *****************************************/
DECLARE @date_debut datetime2 = sysdatetime();
DECLARE @expiration datetime = DATEADD(hour,1,GETDATE());
DECLARE @Application varchar(100) = 'Appli Test ReBUILD';
DECLARE @MODE varchar(30) = 'UPD Classiques'
DECLARE @cpu bigint
DECLARE @mem bigint

select @cpu=cpu,@mem=memusage from master..sysprocesses where  spid = @@spid

BEGIN TRAN
UPDATE SESSION_CLASSIQUE SET Expire=getdate()

--- temps d execution

SELECT @MODE as 'Mode de mise à jour ', DATEDIFF(ms, @date_debut, sysdatetime()) as 'Durée (millisecondes)'

--- ressources

select @cpu=cpu-@cpu,@mem=memusage-@mem  from master..sysprocesses where  spid = @@spid
select @cpu as CpuTime, @mem as Memory


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
GO
/****************** UPDATES MEMOIRE DURABLE *****************************************/
DECLARE @date_debut datetime2 = sysdatetime();
DECLARE @expiration datetime = DATEADD(hour,1,GETDATE());
DECLARE @Application varchar(100) = 'Appli Test ReBUILD';
DECLARE @MODE varchar(30) = 'UPD Memoire Durable'
DECLARE @cpu bigint
DECLARE @mem bigint

select @cpu=cpu,@mem=memusage from master..sysprocesses where  spid = @@spid

BEGIN TRAN
UPDATE SESSION_HEKATON_DURABLE WITH (SNAPSHOT) SET Expire=getdate() 

--- temps d execution

SELECT @MODE as 'Mode de mise à jour ', DATEDIFF(ms, @date_debut, sysdatetime()) as 'Durée (millisecondes)'

--- ressources

select @cpu=cpu-@cpu,@mem=memusage-@mem  from master..sysprocesses where  spid = @@spid
select @cpu as CpuTime, @mem as Memory


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
GO
/****************** UPDATES MEMOIRE NON DURABLE *****************************************/
DECLARE @date_debut datetime2 = sysdatetime();
DECLARE @expiration datetime = DATEADD(hour,1,GETDATE());
DECLARE @Application varchar(100) = 'Appli Test ReBUILD';
DECLARE @MODE varchar(30) = 'UPD Memoire Non Durable'
DECLARE @cpu bigint
DECLARE @mem bigint

select @cpu=cpu,@mem=memusage from master..sysprocesses where  spid = @@spid

BEGIN TRAN
UPDATE SESSION_HEKATON_NON_DURABLE WITH (SNAPSHOT) SET Expire=getdate() 

--- temps d execution

SELECT @MODE as 'Mode de mise à jour ', DATEDIFF(ms, @date_debut, sysdatetime()) as 'Durée (millisecondes)'

--- ressources

select @cpu=cpu-@cpu,@mem=memusage-@mem  from master..sysprocesses where  spid = @@spid
select @cpu as CpuTime, @mem as Memory

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
GO
/************************ UPDATE MEMOIRE NON DURABLE VIA PROCEDURE NATIVE *************************************************************/

IF OBJECT_ID('Insertion_Native') IS NOT NULL
DROP PROCEDURE dbo.Insertion_Native
GO
CREATE PROCEDURE Update_Native
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS
BEGIN ATOMIC
WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')
	DECLARE @date_debut datetime2 = sysdatetime();
	DECLARE @expiration datetime = DATEADD(hour,1,GETDATE());
	DECLARE @Application varchar(100) = 'Appli Test ReBUILD';
	DECLARE @MODE varchar(50) = 'Update Mémoire Non Durable procédure Native'
	DECLARE @cpt int=1;

	UPDATE dbo.SESSION_HEKATON_NON_DURABLE_NAT SET Expire=getdate() 

	SELECT @MODE as 'Mode d''insertion', DATEDIFF(ms, @date_debut, sysdatetime()) as 'Durée (millisecondes)'
	
END;
GO
DECLARE @cpu bigint
DECLARE @mem bigint

select @cpu=cpu,@mem=memusage from master..sysprocesses where  spid = @@spid


EXECUTE Update_Native

--- ressources

select @cpu=cpu-@cpu,@mem=memusage-@mem  from master..sysprocesses where  spid = @@spid
select @cpu as CpuTime, @mem as Memory

--- locks

SELECT COUNT(*) as nbLocks,
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
--DROP DATABASE DB_HEKATON;
GO



