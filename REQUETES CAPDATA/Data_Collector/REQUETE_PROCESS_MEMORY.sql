/****** Script for SelectTopNRows command from SSMS  ******/
SELECT distinct s.instance_name,  S.[snapshot_id],*
  FROM [MDW].[snapshots].[sql_process_and_system_memory] z
  inner join [MDW].[core].[snapshots] s
  on z.snapshot_id=s.snapshot_id
  where s.instance_name like 'AUBFRMU%'

  /****** Script for SelectTopNRows command from SSMS  ******/
SELECT distinct s.instance_name,  S.[snapshot_id],*
  FROM [MDW].[snapshots].[sql_process_and_system_memory] z
  inner join [MDW].[core].[snapshots] s
  on z.snapshot_id=s.snapshot_id
  where s.instance_name like 'AUBFRMG%'