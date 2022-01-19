/*
https://www.sqlshack.com/insight-into-the-sql-server-buffer-cache/
*/
--Les résultats de cette requête me renseignent un peu sur l'utilisation de la mémoire sur mon serveur:
SELECT
	physical_memory_kb/1024/1024 as physical_memory_Gb,
	virtual_memory_kb/1024/1024 as virtual_memory_Gb ,
	committed_kb/1024/1024 as committed_Gb ,
	committed_target_kb/1024/1024 as committed_target_Gb
FROM sys.dm_os_sys_info;

 /*
 Cette requête renvoie, dans l'ordre de la plupart des pages en mémoire au plus petit nombre, 
 la quantité de mémoire consommée par chaque base de données dans le cache de la mémoire tampon:
 */
 SELECT
    databases.name AS database_name,
    COUNT(*) * 8 / 1024 AS mb_used
FROM sys.dm_os_buffer_descriptors
INNER JOIN sys.databases
ON databases.database_id = dm_os_buffer_descriptors.database_id
GROUP BY databases.name
ORDER BY COUNT(*) DESC;

 /*
Cela retourne une seule ligne contenant le nombre de pages du cache, ainsi que la mémoire consommée par celles-ci:
Une page ayant une taille de 8 Ko, nous pouvons convertir le nombre de pages en mégaoctets en multipliant par 8 pour obtenir le Ko, 
puis diviser par 1024 pour arriver à MB. 
*/
SELECT
	COUNT(*) AS buffer_cache_pages,
	COUNT(*) * 8 / 1024/1024 AS buffer_cache_used_GB
FROM sys.dm_os_buffer_descriptors;

/*
Nous pouvons subdiviser la requete ci dessus et regarder comment le cache de mémoire tampon est utilisé par des objets spécifiques. 
Cela peut fournir beaucoup plus d'informations sur l'utilisation de la mémoire car nous pouvons déterminer quelles tables sont des porcs de mémoire. 
De plus, nous pouvons vérifier certaines métriques intéressantes, telles que le pourcentage de table actuellement en mémoire 
ou les tables rarement utilisées (ou non). La requête suivante renverra des pages tampon et une taille par table:
Les tables système sont exclues et cela extraira uniquement les données pour la base de données actuelle. 
Les vues indexées seront incluses car leurs index sont des entités distinctes des tables dont ils sont dérivés. 
La jointure sur sys.partitions contient deux parties afin de tenir compte des index, ainsi que des segments. 
Les données présentées ici incluent tous les index d'une table, ainsi que le tas, s'il n'y en a pas de défini.
Un segment des résultats est le suivant (pour AdventureWorks2014):
*/
SELECT
	objects.name AS object_name,
	objects.type_desc AS object_type_description,
	COUNT(*) AS buffer_cache_pages,
	COUNT(*) * 8 / 1024 /1024 AS buffer_cache_used_GB
FROM sys.dm_os_buffer_descriptors
INNER JOIN sys.allocation_units
ON allocation_units.allocation_unit_id = dm_os_buffer_descriptors.allocation_unit_id
INNER JOIN sys.partitions
ON ((allocation_units.container_id = partitions.hobt_id AND type IN (1,3))
OR (allocation_units.container_id = partitions.partition_id AND type IN (2)))
INNER JOIN sys.objects
ON partitions.object_id = objects.object_id
WHERE allocation_units.type IN (1,2,3)
AND objects.is_ms_shipped = 0
AND dm_os_buffer_descriptors.database_id = DB_ID()
GROUP BY objects.name,
		 objects.type_desc
ORDER BY COUNT(*) DESC;
 
/*
De même, nous pouvons séparer ces données par index, plutôt que par table, ce qui offre encore plus de précision sur l’utilisation du cache tampon:
*/
  
SELECT
	indexes.name AS index_name,
	objects.name AS object_name,
	objects.type_desc AS object_type_description,
	COUNT(*) AS buffer_cache_pages,
	COUNT(*) * 8 / 1024  AS buffer_cache_used_MB
FROM sys.dm_os_buffer_descriptors
INNER JOIN sys.allocation_units
ON allocation_units.allocation_unit_id = dm_os_buffer_descriptors.allocation_unit_id
INNER JOIN sys.partitions
ON ((allocation_units.container_id = partitions.hobt_id AND type IN (1,3))
OR (allocation_units.container_id = partitions.partition_id AND type IN (2)))
INNER JOIN sys.objects
ON partitions.object_id = objects.object_id
INNER JOIN sys.indexes
ON objects.object_id = indexes.object_id
AND partitions.index_id = indexes.index_id
WHERE allocation_units.type IN (1,2,3)
AND objects.is_ms_shipped = 0
AND dm_os_buffer_descriptors.database_id = DB_ID()
GROUP BY indexes.name,
		 objects.name,
		 objects.type_desc
ORDER BY COUNT(*) DESC;

/*
Pour collecter le pourcentage de chaque table en mémoire, nous pouvons placer cette requête dans un CTE et comparer 
les pages en mémoire au total de chaque table:
Cette requête rejoint notre jeu de données précédent avec une requête sur sys.dm_db_partition_stats afin de comparer 
ce qui se trouve actuellement dans le cache du tampon et l’espace total utilisé par une table donnée. 
Les différentes opérations CAST à la fin aident à éviter la troncature et rendent le résultat final sous une forme facile à lire. 
Les résultats sur mon serveur local sont les suivants:
*/
WITH CTE_BUFFER_CACHE AS (
	SELECT
		objects.name AS object_name,
		objects.type_desc AS object_type_description,
		objects.object_id,
		COUNT(*) AS buffer_cache_pages,
		COUNT(*) * 8 / 1024  AS buffer_cache_used_MB
	FROM sys.dm_os_buffer_descriptors
	INNER JOIN sys.allocation_units
	ON allocation_units.allocation_unit_id = dm_os_buffer_descriptors.allocation_unit_id
	INNER JOIN sys.partitions
	ON ((allocation_units.container_id = partitions.hobt_id AND type IN (1,3))
	OR (allocation_units.container_id = partitions.partition_id AND type IN (2)))
	INNER JOIN sys.objects
	ON partitions.object_id = objects.object_id
	WHERE allocation_units.type IN (1,2,3)
	AND objects.is_ms_shipped = 0
	AND dm_os_buffer_descriptors.database_id = DB_ID()
	GROUP BY objects.name,
			 objects.type_desc,
			 objects.object_id)

/*
Cette requête peut être modifiée pour fournir le pourcentage d'un index utilisé, 
similaire à la manière dont nous avons collecté le pourcentage d'une table utilisée:
*/
SELECT
	PARTITION_STATS.name,
	CTE_BUFFER_CACHE.object_type_description,
	CTE_BUFFER_CACHE.buffer_cache_pages,
	CTE_BUFFER_CACHE.buffer_cache_used_MB,
	PARTITION_STATS.total_number_of_used_pages,
	PARTITION_STATS.total_number_of_used_pages * 8 / 1024 AS total_mb_used_by_object,
	CAST((CAST(CTE_BUFFER_CACHE.buffer_cache_pages AS DECIMAL) / CAST(PARTITION_STATS.total_number_of_used_pages AS DECIMAL) * 100) AS DECIMAL(5,2)) AS percent_of_pages_in_memory
FROM CTE_BUFFER_CACHE
INNER JOIN (
	SELECT 
		objects.name,
		objects.object_id,
		SUM(used_page_count) AS total_number_of_used_pages
	FROM sys.dm_db_partition_stats
	INNER JOIN sys.objects
	ON objects.object_id = dm_db_partition_stats.object_id
	WHERE objects.is_ms_shipped = 0
	GROUP BY objects.name, objects.object_id) PARTITION_STATS
ON PARTITION_STATS.object_id = CTE_BUFFER_CACHE.object_id
ORDER BY CAST(CTE_BUFFER_CACHE.buffer_cache_pages AS DECIMAL) / CAST(PARTITION_STATS.total_number_of_used_pages AS DECIMAL) DESC;
 
 --EXEC DBAtools..sp_BlitzCache


/*
Cela retourne une ligne par base de données indiquant l'agrégat d'espace libre par base de données, 
additionné sur toutes les pages du cache de la mémoire tampon pour cette base de données particulière:
*/
WITH CTE_BUFFER_CACHE AS
( SELECT
  databases.name AS database_name,
  COUNT(*) AS total_number_of_used_pages,
  CAST(COUNT(*) * 8 AS DECIMAL) / 1024 AS buffer_cache_total_MB,
  CAST(CAST(SUM(CAST(dm_os_buffer_descriptors.free_space_in_bytes AS BIGINT)) AS DECIMAL) / (1024 * 1024) AS DECIMAL(20,2))  AS buffer_cache_free_space_in_MB
 FROM sys.dm_os_buffer_descriptors
 INNER JOIN sys.databases
 ON databases.database_id = dm_os_buffer_descriptors.database_id
 GROUP BY databases.name)
SELECT
 *,
 CAST((buffer_cache_free_space_in_MB / NULLIF(buffer_cache_total_MB, 0)) * 100 AS DECIMAL(5,2)) AS buffer_cache_percent_free_space
FROM CTE_BUFFER_CACHE
ORDER BY buffer_cache_free_space_in_MB / NULLIF(buffer_cache_total_MB, 0) DESC

/*
Cela retourne une ligne par table ou vue indexée qui contient au moins une page dans le cache de la mémoire tampon, 
ordonnée par celles qui contiennent le plus de pages en mémoire en premier.
*/

SELECT
	indexes.name AS index_name,
	objects.name AS object_name,
	objects.type_desc AS object_type_description,
	COUNT(*) AS buffer_cache_pages,
	COUNT(*) * 8 / 1024  AS buffer_cache_used_MB,
	SUM(allocation_units.used_pages) AS pages_in_index,
	SUM(allocation_units.used_pages) * 8 /1024 AS total_index_size_MB,
	CAST((CAST(COUNT(*) AS DECIMAL) / CAST(SUM(allocation_units.used_pages) AS DECIMAL) * 100) AS DECIMAL(5,2)) AS percent_of_pages_in_memory
FROM sys.dm_os_buffer_descriptors
INNER JOIN sys.allocation_units
ON allocation_units.allocation_unit_id = dm_os_buffer_descriptors.allocation_unit_id
INNER JOIN sys.partitions
ON ((allocation_units.container_id = partitions.hobt_id AND type IN (1,3))
OR (allocation_units.container_id = partitions.partition_id AND type IN (2)))
INNER JOIN sys.objects
ON partitions.object_id = objects.object_id
INNER JOIN sys.indexes
ON objects.object_id = indexes.object_id
AND partitions.index_id = indexes.index_id
WHERE allocation_units.type IN (1,2,3)
AND objects.is_ms_shipped = 0
AND dm_os_buffer_descriptors.database_id = DB_ID()
GROUP BY indexes.name,
		 objects.name,
		 objects.type_desc
ORDER BY CAST((CAST(COUNT(*) AS DECIMAL) / CAST(SUM(allocation_units.used_pages) AS DECIMAL) * 100) AS DECIMAL(5,2)) DESC;


/*
Cette requête renvoie le nombre de pages et la taille des données en MB par DB :
*/

SELECT
    databases.name AS database_name,
	COUNT(*) AS buffer_cache_total_pages,
    SUM(CASE WHEN dm_os_buffer_descriptors.is_modified = 1
				THEN 1
				ELSE 0
		END) AS buffer_cache_dirty_pages,
    SUM(CASE WHEN dm_os_buffer_descriptors.is_modified = 1
				THEN 0
				ELSE 1
		END) AS buffer_cache_clean_pages,
    SUM(CASE WHEN dm_os_buffer_descriptors.is_modified = 1
				THEN 1
				ELSE 0
		END) * 8 / 1024 AS buffer_cache_dirty_page_MB,
    SUM(CASE WHEN dm_os_buffer_descriptors.is_modified = 1
				THEN 0
				ELSE 1
		END) * 8 / 1024 AS buffer_cache_clean_page_MB
FROM sys.dm_os_buffer_descriptors
INNER JOIN sys.databases
ON dm_os_buffer_descriptors.database_id = databases.database_id
GROUP BY databases.name;


/*
Cette requête renvoie le nombre de pages et la taille des données en MB par tABLES :
*/

SELECT
	indexes.name AS index_name,
	objects.name AS object_name,
	objects.type_desc AS object_type_description,
	COUNT(*) AS buffer_cache_total_pages,
    SUM(CASE WHEN dm_os_buffer_descriptors.is_modified = 1
				THEN 1
				ELSE 0
		END) AS buffer_cache_dirty_pages,
    SUM(CASE WHEN dm_os_buffer_descriptors.is_modified = 1
				THEN 0
				ELSE 1
		END) AS buffer_cache_clean_pages,
    SUM(CASE WHEN dm_os_buffer_descriptors.is_modified = 1
				THEN 1
				ELSE 0
		END) * 8 / 1024 AS buffer_cache_dirty_page_MB,
    SUM(CASE WHEN dm_os_buffer_descriptors.is_modified = 1
				THEN 0
				ELSE 1
		END) * 8 / 1024 AS buffer_cache_clean_page_MB
FROM sys.dm_os_buffer_descriptors
INNER JOIN sys.allocation_units
ON allocation_units.allocation_unit_id = dm_os_buffer_descriptors.allocation_unit_id
INNER JOIN sys.partitions
ON ((allocation_units.container_id = partitions.hobt_id AND type IN (1,3))
OR (allocation_units.container_id = partitions.partition_id AND type IN (2)))
INNER JOIN sys.objects
ON partitions.object_id = objects.object_id
INNER JOIN sys.indexes
ON objects.object_id = indexes.object_id
AND partitions.index_id = indexes.index_id
WHERE allocation_units.type IN (1,2,3)
AND objects.is_ms_shipped = 0
AND dm_os_buffer_descriptors.database_id = DB_ID()
GROUP BY indexes.name,
		 objects.name,
		 objects.type_desc
ORDER BY COUNT(*) DESC;