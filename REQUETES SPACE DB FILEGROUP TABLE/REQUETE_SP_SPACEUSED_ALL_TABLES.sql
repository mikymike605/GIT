USE MD8_ARCH
GO
create table #TableStatistics (tablename varchar(500), rowcnt varchar(50), reserved varchar(50), data varchar(50), index_size varchar(50), unused varchar(50))
exec sp_MSforeachtable 
   'insert into #TableStatistics EXEC sp_spaceused ''?'' '
select * from #TableStatistics
--where tablename not like '%V_%'
    order by 2 desc
drop table #TableStatistics

USE SID_PRD
GO
create table #TableStatistics (tablename varchar(500), rowcnt varchar(50), reserved varchar(50), data varchar(50), index_size varchar(50), unused varchar(50))
exec sp_MSforeachtable 
   'insert into #TableStatistics EXEC sp_spaceused ''?'' '
select * from #TableStatistics
    order by 1 
drop table #TableStatistics

181 462 224 KB