select subject, name, start_date, expiry_date FROM sys.certificates


DROP CERTIFICATE cert1 



CREATE CERTIFICATE cert1 WITH SUBJECT = 'ITMYtl!9',

EXPIRY_DATE = '01/01/2050', START_DATE = '04/07/2021'



SELECT name, subject, expiry_date, start_date  

FROM sys.certificates

WHERE name = 'cert1'

--Check for the backup
 
SELECT 
 b.database_name,
    key_algorithm,
    encryptor_thumbprint,
    encryptor_type,
	b.media_set_id,
    is_encrypted, 
	type,
    is_compressed,
	bf.physical_device_name
	 FROM msdb.dbo.backupset b
INNER JOIN msdb.dbo.backupmediaset m ON b.media_set_id = m.media_set_id
INNER JOIN msdb.dbo.backupmediafamily bf on bf.media_set_id=b.media_set_id
WHERE database_name = 'SQLShack'
ORDER BY b.backup_start_date  DESC


-- SOURCE
USE master
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ITMYtl!9'

CREATE CERTIFICATE cert1 
WITH SUBJECT ='Backup Encryption Certificate For MT4SASSQL004 and MT4SASSQL005'
,EXPIRY_DATE = '20991231'

SELECT * FROM master.sys.certificates

-- VERIFIER LA SAUVEGARDE DU CERTIFICAT
select pvt_key_last_backup_date, * 
from master.sys.certificates 
where name = 'cert1'
   
BACKUP CERTIFICATE cert1 TO FILE = 'G:\bases\mssql\backup\keysenc\MyCert.cer'
WITH PRIVATE KEY(
                FILE='G:\bases\mssql\backup\keysenc\MyCert.pvk', 
                ENCRYPTION BY PASSWORD ='ITMYtl!9'
                --,DECRYPTION BY PASSWORD = 'ITMYtl!9VkiK3))!)'
)

BACKUP MASTER KEY TO FILE = 'C:\Share_SQL\master_key' ENCRYPTION BY PASSWORD = 'ITMYtl!9'




BACKUP DATABASE DBATools
   TO DISK = 'C:\Share_SQL\DBATools.bak'
   WITH ENCRYPTION(
      ALGORITHM = AES_256, 
      SERVER CERTIFICATE = cert1
)



-- DESTINATAIRE
/*
DROP CERTIFICATE cert1
DROP MASTER KEY 
*/
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ITMYtl!9PWD2'

CREATE CERTIFICATE  cert1
FROM FILE = 'C:\Share_SQL\MyCert.cer'
WITH PRIVATE KEY (FILE = 'C:\Share_SQL\MyCert.pvk',DECRYPTION BY PASSWORD = 'ITMYtl!9'); 

USE master;

GO

-- Create master key 

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'qTZ8kfNKfNbkcnY.qK@@OsPcD1hXW:';

-- Create certificate    There are two "CERT1", It is suggested that each machine be given a different name to distinguish it 

CREATE CERTIFICATE CERT1 WITH SUBJECT = 'CERT1', START_DATE = '2017-01-01',EXPIRY_DATE = '2099-12-30';

-- Back up the certificate you just created to a file   There are also two CERT1 To change 

BACKUP CERTIFICATE CERT1 TO FILE = 'C:\Share_SQL\CERT1.cer';

-- Create endpoint , Set to certificate validation   The second line here is 1 individual CERT1 To change 

CREATE ENDPOINT [group0_endpoint] AUTHORIZATION [sa] STATE=STARTED AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL)

 FOR DATA_MIRRORING (ROLE = ALL,AUTHENTICATION = CERTIFICATE CERT1, ENCRYPTION = REQUIRED ALGORITHM AES)

GO