@echo off
set instance=

set connection=%computername%
if "%instance%" NEQ "" (
	set connection=%connection%\%instance%
)
certutil -decode pwd.txt password.txt && set /p pwd= < password.txt && del password.txt
sqlcmd.exe -U maintenance -P %pwd% -S %connection% -i "Update Statistics.sql"
:: TODO - Gestion d'erreur

goto :eof