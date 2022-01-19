--1. Avec la dmv sys.dm_server_registry : à partir de la version 2012 de SQL Server

Select value_name AS [Name],value_data AS [Port Number]
From sys.dm_server_registry
Where registry_key like '%IPALL%' and
(value_name ='TcpPort' OR value_name = 'TcpDynamicPorts');

--2. Avec la procédure stockée étendue xp_instance_regread

DECLARE       @portNumber   NVARCHAR(10), @dynamicportNumber NVARCHAR(10)
EXEC   xp_instance_regread
@rootkey    = 'HKEY_LOCAL_MACHINE',
@key        = 'Software\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IpAll',
@value_name = 'TcpPort',
@value      = @portNumber OUTPUT
EXEC   xp_instance_regread
@rootkey    = 'HKEY_LOCAL_MACHINE',
@key        = 'Software\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IpAll',
@value_name = 'TcpDynamicPorts',
@value      = @dynamicportNumber OUTPUT
SELECT [Port Number] = @portNumber,[Dynamic Port Number]=@dynamicportNumber;

--3. En lisant le journal d'erreurs

EXEC xp_readerrorlog 0
                   , 1
                   , N'Server is listening on'
                   , N'any';

--4. En regardant sur quel port sont les sessions connectées

SELECT DISTINCT local_tcp_port
FROM   sys.dm_exec_connections
WHERE  net_transport = 'TCP';

Bonne administration SQL Server !