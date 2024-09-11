@echo off

rem Remplacer S-1-5-21-XXXXX-XXXXX-XXXXX-XXXXX par le SID réel de kiosk_user - faire un whoami /user depuis le user qui fera kiosk
set SID=S-1-5-21-XXXXX-XXXXX-XXXXX-XXXXX
set NAME="kiosk_user"
set PASS="password"
set AUTOADMINLOGON="1"

rem Configurer la connexion automatique pour le compte kiosk_user
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d %AUTOADMINLOGON% /f
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogonSID /t REG_SZ /d %SID% /f
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d %NAME% /f
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d %PASS% /f

rem Configurer Intuiface comme shell pour kiosk_user
reg add "HKEY_USERS\%SID%\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "C:\Program Files\IntuiLab\Intuiface\Player\IntuiFacePlayerApp.exe" /f

echo Configureration est terminé, vous pouvez redémarrer.
pause
