-- definir la base concerné
USE IZIBOX
GO 
-- Rattache les user d'une base recharger au login disponible sur le serveur
declare @name varchar(255)
select @name=''
 
/*select @name = min(name) from dbo.sysusers 
where islogin =1 
and sid is not null
and name not in ('dbo','guest')*/
 
SELECT @name=min(l.name)
FROM   dbo.sysusers AS u INNER JOIN
       master..syslogins AS l ON u.name = l.name --COLLATE Latin1_General_CI_AS
 
while @name is not null
begin
 
 print 'login: ' +  @name
 EXEC sp_change_users_login 'Auto_Fix', @name,null
 
 /*select @name=min(name) from dbo.sysusers
 where islogin =1 
 and sid is not null
 and name not in ('dbo','guest')
 and name >@name*/
 
 SELECT @name=min(l.name)
 FROM   dbo.sysusers AS u INNER JOIN
         master..syslogins AS l ON u.name = l.name  COLLATE Latin1_General_CI_AS
 WHERE  l.name>@name
end
 
select name, sid, createdate, updatedate from dbo.sysusers where sid is not null and name not in ('dbo','guest')
 
 