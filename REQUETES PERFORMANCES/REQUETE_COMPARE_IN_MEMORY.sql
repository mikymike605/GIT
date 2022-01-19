--Étape 1: Créer une base de données qui crée un groupe de fichiers contenant memory_optimized_data
CREATE DATABASE InMemory
ON PRIMARY(NAME = InMemoryData,
FILENAME = 'C:\Share_SQL\SQL_DATA\InMemoryData.mdf', size=200MB),
-- Memory Optimized Data
FILEGROUP [InMem_FG] CONTAINS MEMORY_OPTIMIZED_DATA(
NAME = [InMemory_InMem_dir],
FILENAME = 'C:\Share_SQL\SQL_DATA\InMemory_InMem_dir')
LOG ON (name = [InMem_demo_log], Filename='C:\Share_SQL\SQL_LOG\InMemory.ldf', size=100MB)

--Étape 2: Créez deux tables différentes 1) Table régulière et 2) Table optimisée pour la mémoire
USE InMemory
GO
-- Create a Simple Table
CREATE TABLE DummyTable (ID INT NOT NULL PRIMARY KEY,
Name VARCHAR(100) NOT NULL)
GO
-- Create a Memeory Optimized Table
CREATE TABLE DummyTable_Mem (ID INT NOT NULL,
Name VARCHAR(100) NOT NULL
CONSTRAINT ID_Clust_DummyTable_Mem PRIMARY KEY NONCLUSTERED HASH (ID) WITH (BUCKET_COUNT=1000000))
WITH (MEMORY_OPTIMIZED=ON)
GO


/*
Étape 3: Créer deux procédures stockées 1) SP standard et 2) SP compilé de manière native
Procédure stockée - Insertion simple
Simple table to insert 100,000 Rows
*/

CREATE PROCEDURE Simple_Insert_test
AS
BEGIN
SET NOCOUNT ON
DECLARE @counter AS INT = 1
DECLARE @start DATETIME
SELECT @start = GETDATE()
WHILE (@counter <= 100000000)
BEGIN
INSERT INTO DummyTable VALUES(@counter, 'SQLAuthority')
SET @counter = @counter + 1
END
SELECT DATEDIFF(SECOND, @start, GETDATE() ) [Simple_Insert in sec] END
GO

/*
Procédure stockée - Insert InMemory
Inserting same 100,000 rows using InMemory Table
*/

CREATE PROCEDURE ImMemory_Insert_test
WITH NATIVE_COMPILATION, SCHEMABINDING,EXECUTE AS OWNER
AS
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL=SNAPSHOT, LANGUAGE='english')
DECLARE @counter AS INT = 1
DECLARE @start DATETIME
SELECT @start = GETDATE()
WHILE (@counter <= 100000000)
BEGIN
INSERT INTO dbo.DummyTable_Mem VALUES(@counter, 'SQLAuthority')
SET @counter = @counter + 1
END
SELECT DATEDIFF(SECOND, @start, GETDATE() ) [InMemory_Insert in sec] END
GO

/*
Étape 4: Comparer les performances de deux SP
Les deux procédures stockées mesures et le temps dimpression pris pour les exécuter. Laissez-nous les exécuter et mesurer le temps.

Running the test for Insert
*/
EXEC Simple_Insert_test
GO
EXEC ImMemory_Insert_test
GO

/*
Voici le temps pris par Simple Insert: 12 secondes
Voici le temps pris par InMemory Insert: Presque 0 seconde (moins de 1 seconde)

Étape 5: Nettoyer!
Clean up
*/
USE MASTER
GO
DROP DATABASE InMemory
GO

/*
Analyse du résultat
Il est très clair que la mémoire In-Memory OLTP améliore les performances de la requête et de la procédure stockée. Pour implémenter OLTP en mémoire, 
il y a peu d'étapes que l'utilisateur doit suivre en ce qui concerne la création de groupes de fichiers et de tables. 
Cependant, le résultat final est bien meilleur dans le cas d'une configuration OTLP en mémoire.
https://blog.sqlauthority.com/2014/09/15/sql-server-beginning-in-memory-oltp-with-sample-example/amp/?__twitter_impression=true
*/
