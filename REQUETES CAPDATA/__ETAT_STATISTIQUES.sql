SET NOCOUNT ON
-- Table de resultat
DECLARE @TResult TABLE (Base_name varchar(250),Table_name varchar(250),Index_name varchar(255),Update_date datetime,PercentModifiedRows bigint)
-- variables de travail
DECLARE @NomTable VARCHAR(255)
DECLARE @NomBase VARCHAR(255)
DECLARE @cmd varchar(5000)
-- Boucle sur chaque base de l instance
DECLARE vendor_cursor CURSOR FOR	SELECT name FROM master..sysdatabases 
									WHERE name not in ('master','msdb','model','tempdb','AdminSQL')
OPEN vendor_cursor
FETCH NEXT FROM vendor_cursor INTO @NomBase
WHILE @@FETCH_STATUS = 0
	BEGIN
				SET @cmd='USE ['+@NomBase+'] SELECT '''+@NomBase+''' AS Base_name,'
				SET @cmd=@cmd+'	LEFT(CAST(USER_NAME(uid)+''.''+o.name AS sysname),30) AS Table_name,'
				SET @cmd=@cmd+'	LEFT(i.name,30) AS Index_name,'
				SET @cmd=@cmd+'	STATS_DATE(o.id, i.indid) as StatsUpdated,'
				SET @cmd=@cmd+'	ISNULL(CAST(rowmodctr/CAST(NULLIF(rowcnt,0) AS INT)*100 AS INT),0) AS PercentModifiedRows'
				SET @cmd=@cmd+' FROM ['+@NomBase+'].dbo.sysobjects o INNER JOIN ['+@NomBase+'].dbo.sysindexes i ON (o.id=i.id)'
				SET @cmd=@cmd+' WHERE OBJECTPROPERTY(o.id, ''IsUserTable'')=1'
				SET @cmd=@cmd+' AND i.indid BETWEEN 0 AND 254'
				--SET @CMD=@CMD+' AND o.name = '''+@NomTable+''''
				print @cmd
				INSERT INTO @TResult (Base_name,Table_name,Index_name,Update_date,PercentModifiedRows) EXEC(@cmd)
	FETCH NEXT FROM vendor_cursor INTO @NomBase
	END 
CLOSE vendor_cursor
DEALLOCATE vendor_cursor

SELECT  Base_name+'.'+Table_name+'.'+Index_name
,Update_date
,PercentModifiedRows 
	
FROM @TResult
WHERE Base_name IS NOT NULL AND  Table_name IS NOT NULL AND  Index_name IS NOT NULL AND Update_date IS NOT NULL
AND PercentModifiedRows > 80
---order by Base_name,Table_name,Index_name
order by 2,3 desc