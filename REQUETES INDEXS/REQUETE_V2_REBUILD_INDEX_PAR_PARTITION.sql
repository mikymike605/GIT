

IF OBJECT_ID('tempdb..#work_to_do') IS NOT NULL 
        DROP TABLE tempdb..#work_to_do

/*
--Find out the disk size of an index:
USE [SID_PRD]
GO
SELECT
OBJECT_NAME(I.OBJECT_ID) AS TableName,
I.name AS IndexName,   
8 * SUM(AU.used_pages) AS 'Index size (KB)',
CAST(8 * SUM(AU.used_pages) / 1024.0 AS DECIMAL(18,2)) AS 'Index size (MB)',
CAST(8 * SUM(AU.used_pages) / 1024.0/1024.0 AS DECIMAL(18,2)) AS 'Index size (GB)'
,i.index_id,P.partition_number
FROM sys.indexes I
JOIN sys.partitions P ON P.OBJECT_ID = I.OBJECT_ID AND P.index_id = I.index_id
JOIN sys.allocation_units AU ON AU.container_id = P.partition_id
--WHERE OBJECT_NAME(I.OBJECT_ID) = 'MD8_TICKET'  
--and i.index_id in (2,23,39)
--and partition_number in (17)  
GROUP BY I.OBJECT_ID, I.name,i.index_id,p.partition_number
ORDER BY i.index_id,p.partition_number
*/


/*
  DECLARE @command1 NVARCHAR(4000);
  SET @command1='
select ''SELECT * FROM sys.dm_db_index_physical_stats (db_id(''''SID_PRD''''), OBJECT_ID(''''ODS.''+o.name+''''''),''+cast (i.index_id as varchar)+'',''+cast (partition_number as varchar)+'',''''limited'''') 
where avg_fragmentation_in_percent >30 union '' toto,i.index_id,p.partition_number
from sys.partitions p
inner join sys.objects o on o.object_id=p.object_id
inner join sys.indexes i on i.object_id=o.object_id and p.index_id=i.index_id
where o.name =''MD5_INVOICE_DETAIL''  --TICKET_UNIFIE, SEM_TICKET, MD5_INVOICE_DETAIL, F_PRODUCT_TIMESLOT,F_PRODUCT,MD5_INVOICE,MD5_PAYEMENT
and i.index_id >0
order by 2,3'
exec (@command1);
*/
BEGIN TRY
--BEGIN TRAN

-- Ensure a USE  statement has been executed first.

    SET NOCOUNT ON;

    DECLARE @objectid INT;
    DECLARE @indexid INT;
    DECLARE @partitioncount BIGINT;
    DECLARE @schemaname NVARCHAR(130);
    DECLARE @objectname NVARCHAR(130);
    DECLARE @indexname NVARCHAR(130);
    DECLARE @partitionnum BIGINT;
    DECLARE @partitions BIGINT;
    DECLARE @frag FLOAT;
    DECLARE @pagecount INT;
    DECLARE @command NVARCHAR(4000);
	DECLARE @Indexsize FLOAT;
	DECLARE @IndexsizeMB FLOAT;
	DECLARE @IndexsizeGB FLOAT;

    DECLARE @page_count_minimum SMALLINT
    SET @page_count_minimum = 1500

    DECLARE @fragmentation_minimum FLOAT
    SET @fragmentation_minimum = 30.0

-- Conditionally select tables and indexes from the sys.dm_db_index_physical_stats function
-- and convert object and index IDs to names.

    SELECT  i.object_id AS objectid ,
            i.index_id AS indexid ,
            p.partition_number AS partitionnum ,
            avg_fragmentation_in_percent AS frag ,
            page_count AS page_count,
			8 * SUM(AU.used_pages) AS 'Index size (KB)',
CAST(8 * SUM(AU.used_pages) / 1024.0 AS DECIMAL(18,2)) AS 'Index size (MB)',
CAST(8 * SUM(AU.used_pages) / 1024.0/1024.0 AS DECIMAL(18,2)) AS 'Index size (GB)'
    INTO    #work_to_do
   	FROM sys.indexes I
JOIN sys.partitions P ON P.OBJECT_ID = I.OBJECT_ID AND P.index_id = I.index_id
JOIN sys.allocation_units AU ON AU.container_id = P.partition_id
JOIN sys.dm_db_index_physical_stats(db_id('?'),NULL,NULL,NULL,NULL) ips
on ips.index_id=i.index_id and ips.partition_number=p.partition_number
    WHERE   avg_fragmentation_in_percent > @fragmentation_minimum
            AND i.index_id > 1
			and p.partition_number=1
            AND page_count > @page_count_minimum
			GROUP BY i.OBJECT_ID, i.index_id,p.partition_number,avg_fragmentation_in_percent,page_count

IF CURSOR_STATUS('global', 'partitions') >= -1
BEGIN
 PRINT 'partitions CURSOR DELETED' ;
    CLOSE partitions
    DEALLOCATE partitions
END
-- Declare the cursor for the list of partitions to be processed.
    DECLARE partitions CURSOR LOCAL
    FOR
        SELECT  *
        FROM    #work_to_do;

-- Open the cursor.
    OPEN partitions;

-- Loop through the partitions.
    WHILE ( 1 = 1 )
        BEGIN;
            FETCH NEXT
FROM partitions
INTO @objectid, @indexid, @partitionnum, @frag, @pagecount, @Indexsize,@IndexsizeMB,@IndexsizeGB;

            IF @@FETCH_STATUS < 0
                BREAK;

            SELECT  @objectname = QUOTENAME(o.name) ,
                    @schemaname = QUOTENAME(s.name)
            FROM    sys.objects AS o
                    JOIN sys.schemas AS s ON s.schema_id = o.schema_id
            WHERE   o.object_id = @objectid;

            SELECT  @indexname = QUOTENAME(name)
            FROM    sys.indexes
            WHERE   object_id = @objectid
                    AND index_id = @indexid;

            SELECT  @partitioncount = COUNT(*)
            FROM    sys.partitions
            WHERE   object_id = @objectid
                    AND index_id = @indexid;

            SET @command = N'ALTER INDEX ' + @indexname + N' ON '
                + @schemaname + N'.' + @objectname + N' REBUILD';

            IF @partitioncount > 0
                SET @command = @command + N' PARTITION='
                    + CAST(@partitionnum AS NVARCHAR(10)) +' WITH (SORT_IN_TEMPDB = OFF, ONLINE = ON)';
				
            --EXEC (@command);
            print (@command); --//uncomment for testing

            PRINT N'Rebuilding index ' + @indexname + ' on table '
                + @objectname;
            PRINT N'  Fragmentation: ' + CAST(@frag AS VARCHAR(15));
            PRINT N'  Page Count:    ' + CAST(@pagecount AS VARCHAR(15));
			PRINT N'  Index Size:    ' + CAST(@Indexsize AS VARCHAR(15));
			PRINT N'  Index SizeMB:    ' + CAST(@IndexsizeMB AS VARCHAR(15));
			PRINT N'  Index SizeGB:    ' + CAST(@IndexsizeGB AS VARCHAR(15));
            PRINT N' ';
        END;

-- Close and deallocate the cursor.
    CLOSE partitions;
    DEALLOCATE partitions;

-- Drop the temporary table.
    DROP TABLE #work_to_do;
--COMMIT TRAN

END TRY
BEGIN CATCH
--ROLLBACK TRAN
    PRINT 'ERROR ENCOUNTERED:' + ERROR_MESSAGE()
END CATCH