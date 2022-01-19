-- =============================================
-- Author:		DUPORT Thierry
-- Create date: 21/05/2008
-- Description:	migration login 2005 et 2008
-- 
--	Modification: TDU 18/03/2010
--				  TDU 22/03/2010 Mise en place de la génération du fichier script
--				  TDU 14/05/2010 Validation production
--				  TDU 15/11/2010 Optimisation
--				  TDU 18/11/2010 Ajout des Server Role
--				  TDU 22/12/2010 Optimisation pour Permission server
--
--	Correction	:	
--
-- =============================================
--        SQL-SERVER 2005 et 2008
-- =============================================
USE master
GO

if substring(convert(sysname, serverproperty('ProductVersion')),0,charindex('.',convert(sysname, serverproperty('ProductVersion'))))<9
begin
	print 'ATTENTION: la version n''est pas compatible!'
end

IF OBJECT_ID ('SP_hexadecimal2') IS NOT NULL
  DROP PROCEDURE SP_hexadecimal2
GO
CREATE PROCEDURE SP_hexadecimal2
    @binvalue varbinary(256),
    @hexvalue varchar (514) OUTPUT
AS
DECLARE @charvalue varchar (514)
DECLARE @i int
DECLARE @length int
DECLARE @hexstring char(16)

SELECT @charvalue = '0x'
SELECT @i = 1
SELECT @length = DATALENGTH (@binvalue)
SELECT @hexstring = '0123456789ABCDEF'

WHILE (@i <= @length)
BEGIN
	DECLARE @tempint int
	DECLARE @firstint int
	DECLARE @secondint int
	SELECT @tempint = CONVERT(int, SUBSTRING(@binvalue,@i,1))
	SELECT @firstint = FLOOR(@tempint/16)
	SELECT @secondint = @tempint - (@firstint*16)
	SELECT @charvalue = @charvalue +
		SUBSTRING(@hexstring, @firstint+1, 1) +
		SUBSTRING(@hexstring, @secondint+1, 1)
	SELECT @i = @i + 1
END

SELECT @hexvalue = @charvalue
GO

------------------------------------------------
-- =============================================
--        SQL-SERVER 2005 et 2008
-- =============================================
IF OBJECT_ID ('SP_FUSION_Revlogin') IS NOT NULL
  DROP PROCEDURE SP_FUSION_Revlogin
GO
CREATE PROCEDURE SP_FUSION_Revlogin @DB_Name sysname= NULL, @login_name sysname = NULL, @FUSION_DIRECTORIES  varchar(255)=''
AS
DECLARE @name sysname
DECLARE @type varchar (1)
DECLARE @hasaccess int
DECLARE @denylogin int
DECLARE @is_disabled int
DECLARE @PWD_varbinary  varbinary (256)
DECLARE @PWD_string  varchar (514)
DECLARE @SID_varbinary varbinary (85)
DECLARE @SID_string varchar (514)
DECLARE @tmpstr  varchar (1024)
DECLARE @is_policy_checked varchar (3)
DECLARE @is_expiration_checked varchar (3)
DECLARE @sysadmin bit, 
	@setupadmin bit,
	@serveradmin bit, 
	@securityadmin bit, 
	@processadmin bit, 
	@diskadmin bit, 
	@dbcreator bit, 
	@bulkadmin bit 
DECLARE @defaultdb sysname
DECLARE @defaultlanguage sysname
DECLARE @text_file nvarchar(250),@InstanceADMName varchar (50)
DECLARE @SQL nvarchar(1024)
DECLARE @Create_File bit
DECLARE @permission_name varchar(255)

SET NOCOUNT ON

-- Paramètre du fichier Migrate_Login.sql
set @InstanceADMName=@@servername
--


if @FUSION_DIRECTORIES<> ''
	set @Create_File =1

IF OBJECT_ID ('[tempdb].[dbo].[tmp_ini]') IS NULL
	CREATE TABLE [tempdb].[dbo].[tmp_ini](
	[script_txt] [varchar](1024) NULL
	) ON [PRIMARY]
ELSE
	TRUNCATE TABLE [tempdb].[dbo].[tmp_ini]

 
IF (@login_name IS NULL and @DB_Name IS NULL)
BEGIN
	DECLARE login_curs CURSOR FOR    
      SELECT p.sid, p.name, p.type, p.is_disabled, p.default_database_name, p.default_language_name, l.hasaccess, l.denylogin, sysadmin, setupadmin, securityadmin , serveradmin , processadmin ,diskadmin ,dbcreator , bulkadmin 
      FROM sys.server_principals p 
      LEFT JOIN sys.syslogins l
      ON ( l.name = p.name ) 
      WHERE p.type IN ( 'S', 'G', 'U' ) 
      AND p.name <> 'sa' 
      AND p.name<>'BUILTIN\Administrators' 
      AND p.name<>'NT AUTHORITY\SYSTEM'
      ORDER BY p.name
      
END
ELSE  
BEGIN
	IF (@login_name IS NOT NULL)
	BEGIN
		DECLARE login_curs CURSOR FOR
		  SELECT p.sid, p.name, p.type, p.is_disabled, p.default_database_name, p.default_language_name, l.hasaccess, l.denylogin, sysadmin, setupadmin, securityadmin , serveradmin , processadmin ,diskadmin ,dbcreator , bulkadmin 
		  FROM sys.server_principals p 
		  LEFT JOIN sys.syslogins l
		  ON ( l.name = p.name ) 
		  WHERE p.type IN ( 'S', 'G', 'U' ) AND p.name = @login_name
	END
	ELSE
	BEGIN
			SET @SQL='DECLARE login_curs CURSOR FOR
				SELECT p.sid, p.name, p.type, p.is_disabled, p.default_database_name, p.default_language_name, l.hasaccess, l.denylogin, l.sysadmin, 
						  l.setupadmin, l.securityadmin, l.serveradmin, l.processadmin, l.diskadmin, l.dbcreator, l.bulkadmin
				FROM sys.server_principals AS p 
				INNER JOIN ['+@DB_Name+'].sys.sysusers AS t 
				ON p.sid = t.sid 
				LEFT OUTER JOIN sys.syslogins AS l 
				ON l.sid = p.sid
				WHERE     (p.type IN (''S'', ''G'', ''U'')) 
				AND (p.name <> ''sa'') 
				AND (p.name <> ''BUILTIN\Administrators'') 
				AND (p.name <> ''NT AUTHORITY\SYSTEM'')
				ORDER BY p.name'
			EXECUTE sp_executesql @SQL
	END
END
      
OPEN login_curs

FETCH NEXT FROM login_curs INTO @SID_varbinary, @name, @type, @is_disabled, @defaultdb, @defaultlanguage, @hasaccess, @denylogin, @sysadmin, @setupadmin, @securityadmin , @serveradmin , @processadmin , @diskadmin , @dbcreator , @bulkadmin 

IF (@@fetch_status = -1)
BEGIN
	PRINT 'No login(s) found.'
	CLOSE login_curs
	DEALLOCATE login_curs
	RETURN -1
END

SET @tmpstr = '/* SP_FUSION_Revlogin script '
PRINT @tmpstr
if @Create_File=1
	INSERT INTO [tempdb].[dbo].[tmp_ini] ([script_txt]) VALUES (@tmpstr)
	
SET @tmpstr = '** Generated ' + CONVERT (varchar, GETDATE()) + ' on ' + @@SERVERNAME + ' */'
PRINT @tmpstr
if @Create_File=1
	INSERT INTO [tempdb].[dbo].[tmp_ini] ([script_txt]) VALUES (@tmpstr)

SET @tmpstr = ''
PRINT @tmpstr
if @Create_File=1
	INSERT INTO [tempdb].[dbo].[tmp_ini] ([script_txt]) VALUES (@tmpstr)

WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @tmpstr =''
		
		PRINT @tmpstr
		
		if @Create_File=1
			INSERT INTO [tempdb].[dbo].[tmp_ini] ([script_txt]) VALUES (@tmpstr)
		
		SET @tmpstr = '-- Login: ' + @name
		PRINT @tmpstr
		if @Create_File=1
			INSERT INTO [tempdb].[dbo].[tmp_ini] ([script_txt]) VALUES (@tmpstr)

		IF (@type IN ( 'G', 'U'))
		BEGIN -- NT authenticated account/group
			SET @tmpstr = 'CREATE LOGIN ' + QUOTENAME( @name ) + ' FROM WINDOWS WITH DEFAULT_DATABASE = [' + @defaultdb + ']'
		END
		ELSE 
		BEGIN -- SQL Server authentication
			-- obtain password and sid
            SET @PWD_varbinary = CAST( LOGINPROPERTY( @name, 'PasswordHash' ) AS varbinary (256) )
			EXEC SP_hexadecimal2 @PWD_varbinary, @PWD_string OUT
			EXEC SP_hexadecimal2 @SID_varbinary,@SID_string OUT
 
			-- obtain password policy state
			SELECT @is_policy_checked = CASE is_policy_checked WHEN 1 THEN 'ON' WHEN 0 THEN 'OFF' ELSE NULL END FROM sys.sql_logins WHERE name = @name
			SELECT @is_expiration_checked = CASE is_expiration_checked WHEN 1 THEN 'ON' WHEN 0 THEN 'OFF' ELSE NULL END FROM sys.sql_logins WHERE name = @name
			
            SET @tmpstr = 'CREATE LOGIN ' + QUOTENAME( @name ) + ' WITH PASSWORD = ' + @PWD_string + ' HASHED, SID = ' + @SID_string + ', DEFAULT_DATABASE = [' + @defaultdb + '], DEFAULT_LANGUAGE=['+@defaultlanguage+'] '

			IF ( @is_policy_checked IS NOT NULL )
			BEGIN
			  SET @tmpstr = @tmpstr + ', CHECK_POLICY = ' + @is_policy_checked
			END
			
			IF ( @is_expiration_checked IS NOT NULL )
			BEGIN
			  SET @tmpstr = @tmpstr + ', CHECK_EXPIRATION = ' + @is_expiration_checked
			END
		END
    
		IF (@denylogin = 1)
		BEGIN -- login is denied access
		  SET @tmpstr = @tmpstr + '; DENY CONNECT SQL TO ' + QUOTENAME( @name )
		END
		ELSE IF (@hasaccess = 0)
		BEGIN -- login exists but does not have access
		  SET @tmpstr = @tmpstr + '; REVOKE CONNECT SQL TO ' + QUOTENAME( @name )
		END
	    
		IF (@is_disabled = 1)
		BEGIN -- login is disabled
		  SET @tmpstr = @tmpstr + '; ALTER LOGIN ' + QUOTENAME( @name ) + ' DISABLE'
		END
		
		PRINT @tmpstr
		if @Create_File=1
			INSERT INTO [tempdb].[dbo].[tmp_ini] ([script_txt]) VALUES (@tmpstr)
			
		
		-- Server role
		if @sysadmin= 1
		begin
			SET @tmpstr = 'EXEC sp_addsrvrolemember @loginame = N''' + @name + ''', @rolename = N''sysadmin'''
			PRINT @tmpstr
			if @Create_File=1
				INSERT INTO [tempdb].[dbo].[tmp_ini] ([script_txt]) VALUES (@tmpstr)
		end
			
		if @setupadmin= 1 
		begin
			SET @tmpstr = 'EXEC sp_addsrvrolemember @loginame = N''' + @name + ''', @rolename = N''setupadmin'''
			PRINT @tmpstr
			if @Create_File=1
				INSERT INTO [tempdb].[dbo].[tmp_ini] ([script_txt]) VALUES (@tmpstr)
		end

		if @securityadmin= 1
		begin
			SET @tmpstr = 'EXEC sp_addsrvrolemember @loginame = N''' + @name + ''', @rolename = N''securityadmin'''
			PRINT @tmpstr
			if @Create_File=1
				INSERT INTO [tempdb].[dbo].[tmp_ini] ([script_txt]) VALUES (@tmpstr)
		end

		if @serveradmin= 1
		begin
			SET @tmpstr = 'EXEC sp_addsrvrolemember @loginame = N''' + @name + ''', @rolename = N''serveradmin'''
			PRINT @tmpstr
			if @Create_File=1
				INSERT INTO [tempdb].[dbo].[tmp_ini] ([script_txt]) VALUES (@tmpstr)
		end

		if @processadmin= 1
		begin
			SET @tmpstr = 'EXEC sp_addsrvrolemember @loginame = N''' + @name + ''', @rolename = N''processadmin'''
			PRINT @tmpstr
			if @Create_File=1
				INSERT INTO [tempdb].[dbo].[tmp_ini] ([script_txt]) VALUES (@tmpstr)
		end

		if @diskadmin= 1
		begin
			SET @tmpstr = 'EXEC sp_addsrvrolemember @loginame = N''' + @name + ''', @rolename = N''diskadmin'''
			PRINT @tmpstr
			if @Create_File=1
				INSERT INTO [tempdb].[dbo].[tmp_ini] ([script_txt]) VALUES (@tmpstr)
		end

		if @dbcreator= 1
		begin
			SET @tmpstr = 'EXEC sp_addsrvrolemember @loginame = N''' + @name + ''', @rolename = N''dbcreator'''
			PRINT @tmpstr
			if @Create_File=1
				INSERT INTO [tempdb].[dbo].[tmp_ini] ([script_txt]) VALUES (@tmpstr)
		end

		if @bulkadmin = 1
		begin
			SET @tmpstr = 'EXEC sp_addsrvrolemember @loginame = N''' + @name + ''', @rolename = N''bulkadmin'''
			PRINT @tmpstr
			if @Create_File=1
				INSERT INTO [tempdb].[dbo].[tmp_ini] ([script_txt]) VALUES (@tmpstr)
		end

		-- Permission Server
		DECLARE CRS_LOGIN_RIGHT CURSOR FOR 
		SELECT Srv.permission_name
		FROM sys.server_principals Princ
		INNER JOIN sys.server_permissions Srv on Princ.principal_id = Srv.grantee_principal_id
		WHERE rtrim(ltrim(Princ.name)) like @name
		AND Princ.is_disabled=0
		
		OPEN CRS_LOGIN_RIGHT

		FETCH NEXT FROM CRS_LOGIN_RIGHT
		INTO @permission_name
		
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			if @permission_name<>'CONNECT SQL'
			begin
				SET @tmpstr = 'GRANT '+@permission_name+ ' TO '+QUOTENAME( @name )
				PRINT @tmpstr
				if @Create_File=1
					INSERT INTO [tempdb].[dbo].[tmp_ini] ([script_txt]) VALUES (@tmpstr)
			end
			
			FETCH NEXT FROM CRS_LOGIN_RIGHT
			INTO @permission_name
		END
		
		CLOSE CRS_LOGIN_RIGHT
		DEALLOCATE CRS_LOGIN_RIGHT
	
	END
	
	FETCH NEXT FROM login_curs INTO @SID_varbinary, @name, @type, @is_disabled, @defaultdb, @defaultlanguage, @hasaccess, @denylogin, @sysadmin, @setupadmin, @securityadmin , @serveradmin , @processadmin , @diskadmin , @dbcreator , @bulkadmin 
END
   
CLOSE login_curs
DEALLOCATE login_curs

-- génération du fichier Migrate_Login.sql
SET @tmpstr = ''
PRINT @tmpstr
if @Create_File=1
	INSERT INTO [tempdb].[dbo].[tmp_ini] ([script_txt]) VALUES (@tmpstr)
	
SET @tmpstr = '-- End Script'
PRINT @tmpstr
if @Create_File=1
	INSERT INTO [tempdb].[dbo].[tmp_ini] ([script_txt]) VALUES (@tmpstr)

if @Create_File=1
begin

	--SELECT * from [tempdb].[dbo].[tmp_ini]
	
	set @text_file = @FUSION_DIRECTORIES + '\'+replace(CAST(serverproperty('servername') as varchar),'\','-')+'_Login_'+replace(replace(replace(convert(varchar,getdate(),121),'.','-'),' ','-'),':','-')+'.sql'
PRINT @text_file
    set @SQL='exec master.[dbo].xp_cmdshell ''bcp "tempdb.dbo.tmp_ini" out "'+@text_file+'" -c -T -S"'+@InstanceADMName+'"'''
    --print @SQL
    EXECUTE sp_executesql @SQL
    if @@ERROR=0
		PRINT 'Fichier déposé : '+@text_file
    
end

DROP TABLE [tempdb].[dbo].[tmp_ini]
--

RETURN 0
GO

-- =============================================
--        SQL-SERVER 2005 et 2008
-- =============================================
--Remarque Ce script crée deux procédures stockées dans la base de données master. 
--Ces deux procédures stockées sont appelées SP_hexadecimal2 et SP_FUSION_Revlogin


EXEC SP_FUSION_Revlogin  @FUSION_DIRECTORIES='C:\Install'



IF OBJECT_ID ('SP_hexadecimal2') IS NOT NULL
  DROP PROCEDURE SP_hexadecimal2
GO
IF OBJECT_ID ('SP_FUSION_Revlogin') IS NOT NULL
  DROP PROCEDURE SP_FUSION_Revlogin
GO




-- =============================================
--        TRANSFERT PROXI & CREDENTIAL
-- =============================================

-- creates credential CatalogApplicationCredential  
USE msdb;  
GO

CREATE CREDENTIAL CatalogApplicationCredential WITH IDENTITY = 'NEOFED\srvdba', SECRET = 'QSfd88-(';  
GO  

-- creates proxy "Catalog application proxy" and assigns the credential 'CatalogApplicationCredential' to it
EXEC dbo.sp_add_proxy  
    @proxy_name = 'Catalog application proxy',  
    @enabled = 1,  
    @description = 'Maintenance tasks on catalog application.',  
    @credential_name = 'CatalogApplicationCredential' ;  
GO
  
-- grants the proxy "Catalog application proxy" access to the Operating System (CmdExec) subsystem.  
EXEC dbo.sp_grant_proxy_to_subsystem  
    @proxy_name = N'Catalog application proxy',  
    @subsystem_id = 3 ;  
GO


-- Get the credentials from sys.credentials, the password is unknown
SELECT 'CREATE CREDENTIAL '+[name]+' WITH IDENTITY='''+[credential_identity]+''',SECRET=''QSfd88-('''
FROM [sys].[credentials]
ORDER BY [name]


-- Get the proxies from sp_help_proxy and sys.credentials
CREATE TABLE #Info ([proxy_id] INT, [name] SYSNAME, [credential_identity] SYSNAME, [enabled] TINYINT, [description] NVARCHAR(1024), [user_sid] VARBINARY(85), [credential_id] INT, [credential_identity_exists] INT)

INSERT INTO #Info 
EXEC sp_help_proxy

SELECT 'EXEC dbo.sp_add_proxy @proxy_name='''+[i].[name]+''',@enabled='+CAST([enabled] AS VARCHAR)+',@description='+(CASE WHEN [description] IS NULL THEN 'NULL' ELSE ''''+[description]+'''' END)+',@credential_name='''+[c].[name]+''''
FROM #Info [i]
INNER JOIN [sys].[credentials] [c] ON [c].[credential_id] = [i].[credential_id]

DROP TABLE #Info


-- Get the proxy authorizations from sp_enum_proxy_for_subsystem
CREATE TABLE #Info2([subsystem_id] INT, [subsystem_name] SYSNAME, [proxy_id] INT, [proxy_name] SYSNAME)

INSERT INTO #Info2 EXEC sp_enum_proxy_for_subsystem
SELECT 'EXEC dbo.sp_grant_proxy_to_subsystem @proxy_name=N'''+[proxy_name]+''',@subsystem_id='+CAST([subsystem_id] AS VARCHAR) 
FROM #Info2

DROP TABLE #Info2








