/*
USE [SID_PRD]
GO
DECLARE @shrink int 
set @shrink = 2400000
while @shrink >1086042
BEGIN
DBCC SHRINKFILE (N'SID_PRD_ODS_DATA' , @shrink)
set @shrink = @shrink - 100
END
*/

--DECLARE @shrink int set @shrink = 147033    while @shrink >43104 BEGIN DBCC SHRINKFILE ('SID_DEV_2' , @shrink) set @shrink = @shrink - 100 END   

--DECLARE @freespace int
-- SET @freespace = (SELECT  f.size / 128.0 -convert(int,fileproperty(f.name,'SpaceUsed'))/128.0 
--from  sys.database_files f with (nolock) 
--left outer join  sys.filegroups fg with (nolock) 
--on f.data_space_id = fg.data_space_id
--);

--SELECT  @freespace;

-- 12:07 =====> 1063700.625000
-- 


select  'DECLARE @shrink int set @shrink = '+cast(f.size/128 as varchar(50))+' 
	while @shrink >0 BEGIN DBCC SHRINKFILE ('''+f.name+''' , @shrink) set @shrink = @shrink - 1000 END --print '''+ f.name+'''; USE '+'['+DB_NAME()+']'+' DBCC SHRINKFILE (N''' + f.name+''',0) ;',
    f.type_desc as [Type]
    , f.name as [FileName]
    ,fg.name as [FileGroup]
    ,f.physical_name as [Path]
    ,f.size / 128 as [CurrentSizeGB]
    ,convert(int,fileproperty(f.name,'SpaceUsed'))/128 as SpaceUsed
	,f.size / 128 - convert(int,fileproperty(f.name,'SpaceUsed'))/128 as [FreeSpaceMb]
	--,f.size / 128.0 - convert(int,fileproperty(f.name,'SpaceUsed'))/128.0 -f.size / 128.0
	--,'DECLARE @shrink int set @shrink = '+cast(f.size/128 as varchar(50))+' 
	--while @shrink >'+cast(f.size/128 as varchar(50))+' BEGIN 
	--DBCC SHRINKFILE (N'+f.name+' , @shrink) 
	--set'+ f.size/128+''
from 
    sys.database_files f with (nolock) left outer join 
        sys.filegroups fg with (nolock) on
            f.data_space_id = fg.data_space_id
              --where f.type_desc not in ('LOG')
			  --where fg.name in ('SID_PRD_DWH_FG_1','SID_PRD_ODS_FG01')
			  GROUP BY f.size,f.physical_name ,fg.name,f.name,f.type_desc
			  --HAVING f.size / 128.0 - convert(int,fileproperty(f.name,'SpaceUsed'))/128.0 <100000 
			  --and  f.size / 128.0 - convert(int,fileproperty(f.name,'SpaceUsed'))/128.0 >1000
			  order by 8 desc 
option (recompile)



--					1061200.562500
--2347484.000000	1061203.437500
--2347484.000000	1061169.500000
--2347484.000000	1061103.250000
--2347484.000000	1061125.812500
--2347484.000000	1061128.062500
--2347484.000000	1060073.187500
--2347484.000000	1060026.750000
--2347484.000000	1057762.812500