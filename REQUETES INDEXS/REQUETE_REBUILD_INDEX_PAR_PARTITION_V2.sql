DECLARE @TableName NVARCHAR(500);
DECLARE @SQLIndex NVARCHAR(MAX);
DECLARE @RowCount INT;
DECLARE @Counter INT;

DECLARE @IndexAnalysis TABLE
    (
      AnalysisID INT IDENTITY(1, 1)
                     NOT NULL
                     PRIMARY KEY ,
      TableName NVARCHAR(500) ,
      SQLText NVARCHAR(MAX) ,
      IndexDepth INT ,
      AvgFragmentationInPercent FLOAT ,
      FragmentCount BIGINT ,
      AvgFragmentSizeInPages FLOAT ,
      PageCount BIGINT
    )

BEGIN
    INSERT  INTO @IndexAnalysis
            SELECT  [objects].name ,
                    'ALTER INDEX [' + [indexes].name + '] ON ['
                    + [schemas].name + '].[' + [objects].name + '] '
                    + ( CASE WHEN (   [dm_db_index_physical_stats].avg_fragmentation_in_percent >= 20
                                    AND [dm_db_index_physical_stats].avg_fragmentation_in_percent < 30
                                  ) THEN 'REORGANIZE'
                             WHEN [dm_db_index_physical_stats].avg_fragmentation_in_percent > = 30
                             THEN 'REBUILD PARTITION='
                    + CAST(partition_number AS NVARCHAR(10)) +' WITH (SORT_IN_TEMPDB = OFF, ONLINE = ON)'
                        END ) AS zSQL ,
                    [dm_db_index_physical_stats].index_depth ,
                    [dm_db_index_physical_stats].avg_fragmentation_in_percent ,
                    [dm_db_index_physical_stats].fragment_count ,
                    [dm_db_index_physical_stats].avg_fragment_size_in_pages ,
                    [dm_db_index_physical_stats].page_count
            FROM    [sys].[dm_db_index_physical_stats](DB_ID(), NULL, NULL,
                                                       NULL, 'LIMITED') AS   [dm_db_index_physical_stats]
                    INNER JOIN [sys].[objects] AS [objects] ON (   [dm_db_index_physical_stats].[object_id] = [objects].[object_id] )
                    INNER JOIN [sys].[schemas] AS [schemas] ON ( [objects].[schema_id]  = [schemas].[schema_id] )
                    INNER JOIN [sys].[indexes] AS [indexes] ON (  [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
                                                          AND  [dm_db_index_physical_stats].index_id = [indexes].index_id
                                                          )
            WHERE   index_type_desc <> 'HEAP'
                    AND [dm_db_index_physical_stats].avg_fragmentation_in_percent > 20
					AND [dm_db_index_physical_stats].page_count >1250
					--and [dm_db_index_physical_stats].index_id>1
END

SELECT  @RowCount = COUNT(AnalysisID)
FROM    @IndexAnalysis

SET @Counter = 1
WHILE @Counter <= @RowCount 
    BEGIN

        SELECT  @SQLIndex = SQLText
        FROM    @IndexAnalysis
        WHERE   AnalysisID = @Counter

        --EXECUTE sp_executesql @SQLIndex
		PRINT (@SQLIndex)
			 PRINT N'Rebuilding index ' + @SQLIndex + ' on table '
	                + @TableName;
            --PRINT N'  Fragmentation: ' + CAST(@frag AS VARCHAR(15));
            --PRINT N'  Page Count:    ' + CAST(@pagecount AS VARCHAR(15));
            --PRINT N' ';
        SET @Counter = @Counter + 1
    
    END