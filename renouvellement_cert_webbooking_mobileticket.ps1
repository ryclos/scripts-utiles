# Définir les chemins et les mots de passe
$certbotPathExe = "C:\Program Files\Certbot\bin\certbot.exe"
$opensslPath = "C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
$keytoolPath = "C:\Program Files (x86)\KeyStore Explorer\jre\bin\keytool.exe"
$liveDir = "C:\Certbot\live\rdv-entreprises.ccism.pf"
$pfxDir = "C:\Certbot\qmatic"
$pfxPath = "$pfxDir\domain.pfx"
$jksPath = "C:\Qmatic\QmaticWebBooking\Conf\security\keystore.jks"
$password = "changeit"
# Chemin du dossier de l'application MOBILE TICKET où les certificats doivent être accessibles
$appCertPath = "C:\Qmatic\mobile-ticket-2.7.1\sslcert"
$certbotPath = "C:\Certbot\live\rdv-entreprises.ccism.pf"

# Vérifier si les exécutables existent
if (-not (Test-Path $certbotPathExe) -or -not (Test-Path $opensslPath) -or -not (Test-Path $keytoolPath)) {
    throw "Certbot, OpenSSL ou Keytool introuvables. Veuillez vérifier les chemins d'accès."
}

# Créer le répertoire pfxDir s'il n'existe pas
if (-not (Test-Path $pfxDir)) {
    New-Item -ItemType Directory -Path $pfxDir | Out-Null
}

# Stop le Web Booking (sur le port 80)
Stop-Service -Name "QmaticWebBooking"

# Renouveler le certificat
Write-Host "Renouvellement du certificat..."
& $certbotPathExe renew

# Vérifier si le renouvellement a réussi
if ($LastExitCode -ne 0) {
    Write-Host "Erreur lors du renouvellement du certificat."
    exit $LastExitCode
}

# Convertir le certificat en fichier PKCS12
Write-Host "Conversion du certificat en PKCS12..."
& $opensslPath pkcs12 -export -in "$liveDir\cert.pem" -inkey "$liveDir\privkey.pem" -out $pfxPath -password pass:$password -name orchestra

# Vérifier si la conversion a réussi
if ($LastExitCode -ne 0) {
    Write-Host "Erreur lors de la conversion du certificat en PKCS12."
    exit $LastExitCode
}

# Importer le fichier PKCS12 dans un keystore JKS
Write-Host "Importation dans le keystore JKS..."
& $keytoolPath -importkeystore -srckeystore $pfxPath -srcstoretype pkcs12 -srcstorepass $password -srcalias orchestra -destkeystore $jksPath -deststoretype jks -deststorepass $password -noprompt

# Vérifier si l'importation a réussi
if ($LastExitCode -ne 0) {
    Write-Host "Erreur lors de l'importation du PKCS12 dans le keystore JKS."
    exit $LastExitCode
}

# Redémarrer le service Tomcat
Write-Host "Redémarrage du service Tomcat..."
# Start le Web Booking (sur le port 80)
Start-Service -Name "QmaticWebBooking"

# Vérifier si le redémarrage a réussi
if ($LastExitCode -ne 0) {
    Write-Host "Erreur lors du redémarrage du service Tomcat."
    exit $LastExitCode
}

# MISE A JOUR CERTIFICAT SSL DU MOBILE TICKET

# Assurez-vous que le dossier de l'application existe
New-Item -ItemType Directory -Force -Path $appCertPath

# Supprimer les anciens fichiers pour que les nouveaux soient pris en comptes
Remove-Item "$appCertPath\server.crt"
Remove-Item "$appCertPath\server.key"

# Créer un lien symbolique pour le certificat public (fullchain.pem)
New-Item -ItemType SymbolicLink -Path "$appCertPath\server.crt" -Target "$certbotPath\fullchain.pem"

# Créer un lien symbolique pour la clé privée (privkey.pem)
New-Item -ItemType SymbolicLink -Path "$appCertPath\server.key" -Target "$certbotPath\privkey.pem"

# Redémarrer le service Qmatic Mobile Ticket
Write-Host "Redémarrage du service Qmatic Mobile Ticket..."
Restart-Service "QP_MT"

# Vérifier si le redémarrage du Qmatic Mobile Ticket a réussi
if ($LastExitCode -ne 0) {
    Write-Host "Erreur lors du redémarrage du service Qmatic Mobile Ticket."
    exit $LastExitCode
}

Write-Host "`nLe processus de renouvellement du site web rdv et du mobile web ticket rdv avec les configurations des certificats est terminé avec succès."

