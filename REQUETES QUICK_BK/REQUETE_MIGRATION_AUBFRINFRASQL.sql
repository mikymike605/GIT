select name 
,case 
when name in ('QoEMetrics','LcsCDR') then 'LYNC' 
when name in ('OperationsManager','OperationsManagerDW') then 'SCOM' 
when name in ('KAV','KAV2008') then 'KasperSky' 
when name in ('ReportServerSCCMTempDB','ReportServerSCCM') then 'SCCM'
when name in ('AdminSQL','DBAtools') then 'DBA'
when name in ('SNOWDB','SnowLicenseManager') then 'SnowSoftWare'
else '   ' end 
from sys.databases where database_id >6
order by 1 