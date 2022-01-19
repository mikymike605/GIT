-------Pour effectuer une sauvegarde complète dans le même 
-------dossier de toutes les bases de données utilisateur en mode simple. 
-------C'est un cas où vous voudrez utiliser le paramètre @suppress_quotename, 
-------sinon vous vous retrouverez avec des fichiers nommés [database_name] .bak.

EXEC sp_foreachdb
@command = N'BACKUP DATABASE [?]
TO DISK = ''\\AUBFRM83T040\Share_SQL\?.bak''
WITH INIT, COMPRESSION;',
@user_only = 1,
@recovery_model_desc = N'SIMPLE',
@suppress_quotename = 1;

-------Pour rechercher toutes les bases de données correspondant 
-------au motif de nom 'Company%' pour les objets correspondant au 
-------motif de nom '% foo%'. Placer dans une table #temp de sorte 
-------que le résultat est un ensemble de résultats unique au lieu 
-------du nombre de bases de données qui correspondent au modèle de nommage.
CREATE TABLE #x(n SYSNAME);
EXEC sp_foreachdb
@command = N'INSERT #x SELECT name
FROM ?.sys.objects
WHERE name LIKE N''%foo%'';',
@name_pattern = N'Company%';

-------Pour désactiver auto_shrink pour toutes les bases de données où il est activé:
SELECT * FROM #x;
DROP TABLE #x;
EXEC sp_foreachdb
@command = N'ALTER DATABASE ? SET AUTO_SHRINK OFF;',
@is_auto_shrink_on = 1;

-------Pour trouver la dernière date / heure de 
-------l'objet créé pour chaque base de données dans 
-------un ensemble défini (dans ce cas, trois bases de données 
-------que je connais existent).
EXEC sp_foreachdb
@command = N'SELECT N''?'', MAX(create_date) FROM ?.sys.objects;',
@database_list = 'master,model,msdb';

-------Pour réinitialiser le service broker 
-------pour chaque base de données 
-------après avoir testé une application, par exemple:
EXEC sp_foreachdb
@command = N'ALTER DATABASE ? SET NEW_BROKER;',
@is_broker_enabled = 1;