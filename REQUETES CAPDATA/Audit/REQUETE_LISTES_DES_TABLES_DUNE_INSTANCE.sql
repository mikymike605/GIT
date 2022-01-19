select TableName = convert(varchar(100),sysobjects.name)
    ,TotalRows = max(sysindexes.rows)
    ,GbData = (sum(convert(real,sysindexes.dpages)) * spt_values.low / 1048576)/1024
    ,GbTotal = (sum(convert(real,sysindexes.used)) * spt_values.low / 1048576 )/1024
from sysobjects join sysindexes on sysobjects.id = sysindexes.id
    join master.dbo.spt_values spt_values on spt_values.number = 1 and spt_values.type = 'E'
where sysobjects.type = 'U'
    and indid in (0,1,255)
group by sysobjects.name, spt_values.low
order by 4 desc

SELECT * FROM INFORMATION_SCHEMA.TABLES 

use SID_PRD;
go

;with db_file_cte as
(
    select
        name,
        type_desc,
        physical_name,
        size_mb = 
            convert(decimal(11, 2), size * 8.0 / 1024),
        space_used_mb = 
            convert(decimal(11, 2), fileproperty(name, 'spaceused') * 8.0 / 1024)
    from sys.database_files
)
select
    name,
    type_desc,
    physical_name,
    size_mb,
    space_used_mb,
    space_used_percent = 
        case size_mb
            when 0 then 0
            else convert(decimal(5, 2), space_used_mb / size_mb * 100)
        end
from db_file_cte;

--TICKET_UNIFIE_OLD	ODS	68	3258728067-----19/06 15:32
--TICKET_UNIFIE		ODS	68	85123610-----19/06 15:32
--TICKET_UNIFIE_OLD	ODS	68	3258728067
--TICKET_UNIFIE		ODS	68	180457734

SELECT 
    t.NAME AS TableName,
    s.Name AS SchemaName,
       MAX(NB_COL) NB_COLONNES,
    Max(p.rows) AS RowCounts,
    SUM(a.total_pages) * 8*1.00/1024/1024 AS TotalSpaceGO,--TotalSpaceKB, 
    SUM(a.used_pages) * 8*1.00/1024/1024 AS UsedSpaceGO,--UsedSpaceKB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8*1.00/1024/1024 AS UnusedSpaceGO
FROM sys.tables t
INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN sys.schemas s ON t.schema_id = s.schema_id
LEFT JOIN (SELECT TABLE_NAME, COUNT(*) NB_COL FROM INFORMATION_SCHEMA.COLUMNS GROUP BY TABLE_NAME) tab  on tab.table_name=t.NAME
WHERE t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
	and   t.NAME like 'F_PRODUCT_TIMESLOT'
GROUP BY t.Name, s.Name --, p.Rows,
ORDER BY 4 desc

--F_PRODUCT_TIMESLOT	DWH	39	306225522	222.399978637695	222.398551940917	0.001426696777
--F_PRODUCT_TIMESLOT	DWH	39	306225522	238.043159484863	238.041275024414	0.001884460449
