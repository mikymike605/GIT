select  'print '''+ f.name+'''; USE '+'['+DB_NAME()+']'+' DBCC SHRINKFILE (N''' + f.name+''',0) ;',
    f.type_desc as [Type]
    , f.name as [FileName]
    ,fg.name as [FileGroup]
    ,f.physical_name as [Path]
    ,f.size / 128.0 as [CurrentSizeGB]
    ,f.size / 128.0 - convert(int,fileproperty(f.name,'SpaceUsed'))/128.0 as [FreeSpaceMb]
from 
    sys.database_files f with (nolock) left outer join 
        sys.filegroups fg with (nolock) on
            f.data_space_id = fg.data_space_id
              --where f.type_desc not in ('LOG')
order by 7 desc 
option (recompile)

--2358784.625000	1 113 447.062500-----29/10/2018
--2358784.625000	1 167 717.437500-----30/10/2018
--2358784.625000	1 165 350.500000-----31/10/2018
--2358784.625000	1 153 707.125000-----06/11/2018
--2358784.625000	1 151 079.812500-----07/11/2018
--2358784.625000	1 151 363.312500-----08/11/2018
