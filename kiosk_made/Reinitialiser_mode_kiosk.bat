@echo off

rem Remplacer par le chemin complet du profil utilisateur
set PROFILE_PATH=C:\Users\kiosk_user

rem Charger la ruche de registre
reg load "HKEY_USERS\TempHive" "%PROFILE_PATH%\NTUSER.DAT"

rem Réinitialiser le shell à explorer.exe pour kiosk_user
reg add "HKEY_USERS\TempHive\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d explorer.exe /f

rem Décharger la ruche de registre
reg unload "HKEY_USERS\TempHive"

echo Shell reinitialise a explorer.exe pour le profil %PROFILE_PATH%.
pause
