# Automatisation-renew-certbot
Un script powershell pour automatiser les renouvellements des certifs

// TODO

----------

## Script de Configuration pour Kiosk Mode Intuiface

Ce script configure une session automatique pour un utilisateur spécifique (`kiosk_user`) et définit `IntuiFacePlayerApp.exe` comme shell à la place de l'explorateur Windows.

### Prérequis

1. **Création du compte utilisateur :**
   - Créez un compte utilisateur avec un nom d'utilisateur (`kiosk_user`) et un mot de passe sécurisé (`pass`).
   - Pour ce faire, ouvrez une console en tant qu'administrateur et utilisez la commande suivante :
     ```bash
     net user kiosk_user pass /add
     ```

2. **Récupération du SID de l'utilisateur :**
   - Connectez-vous avec le compte utilisateur `kiosk_user`.
   - Ouvrez une console (cmd) et tapez la commande suivante pour récupérer le SID :
     ```bash
     whoami /user
     ```
   - Notez le SID qui sera affiché, car vous devrez l'utiliser dans le script.

### Utilisation

1. **Modification du script :**
   - Ouvrez le fichier `.bat` et remplacez `S-1-5-21-XXXXX-XXXXX-XXXXX-XXXXX` par le SID que vous avez noté à l'étape précédente.
   - Modifiez les valeurs des variables `NAME` et `PASS` avec le nom d'utilisateur (`kiosk_user`) et le mot de passe que vous avez configuré.

2. **Exécution du script :**
   - Exécutez le script `.bat` en tant qu'administrateur pour que les modifications du registre soient appliquées.

### Script

```batch
@echo off

rem Remplacer S-1-5-21-XXXXX-XXXXX-XXXXX-XXXXX par le SID réel de kiosk_user - faire un whoami /user depuis le user qui fera kiosk
set SID=S-1-5-21-XXXXX-XXXXX-XXXXX-XXXXX
set NAME="kiosk_user"
set PASS="pass"
set AUTOADMINLOGON="1"

rem Configurer la connexion automatique pour le compte kiosk_user
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d %AUTOADMINLOGON% /f
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogonSID /t REG_SZ /d %SID% /f
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d %NAME% /f
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d %PASS% /f

rem Configurer Intuiface comme shell pour kiosk_user
reg add "HKEY_USERS\%SID%\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "C:\Program Files\IntuiLab\Intuiface\Player\IntuiFacePlayerApp.exe" /f

echo Configuration terminée, vous pouvez redémarrer.
pause
```
Remarque
Important : Ce script doit être exécuté en tant qu'administrateur pour que les modifications du registre soient appliquées.

Ce format guide l'utilisateur pas à pas, en commençant par la création du compte utilisateur, puis en récupérant le SID, en modifiant le script en conséquence, et enfin en l'exécutant. Cela permet d'éviter toute confusion et garantit que le script fonctionne correctement.

rust
Copier le code

En suivant ces étapes, l'utilisateur pourra configurer correctement l'environnement pour le mode Kiosk en utilisant le script fourni.
