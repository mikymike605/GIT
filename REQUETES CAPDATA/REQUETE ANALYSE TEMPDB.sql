   dbcc shrinkdatabase (tempdb, 0) 
   
   /*==========================================
   SEULEMENT LES PAGES NON UTILISE EN FIN DE FICHIER
   ==========================================*/
   dbcc shrinkdatabase (tempdb, TRANCATEONLY) 
   
   /*==========================================
   ANALYSE UTILISATION TEMPDB (SESSION OUVERTE)
   ==========================================*/
   
   declare @t table (spid int,dbid int,objid int, indid int,type varchar(50),ressource varchar(50),status varchar(50),mode varchar(50))
insert into @T exec sp_lock


select * from master..sysprocesses where spid in (select distinct spid from @t where db_name(dbid)='tempdb')
GO


select * from @T where db_name(dbid)='tempdb'

   /*==========================================
   ANALYSE TRANSACTION OUVERTE TEMPDB (TRANSACTION OUVERTE)
   ==========================================*/
   
   dbcc opentran (tempdb)

	SELECT * FROM sys.sysprocesses where spid >50



