# Définir les chemins et les mots de passe
$certbotPathExe = "C:\Program Files (x86)\Certbot\bin\certbot.exe"
$opensslPath = "C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
$keytoolPath = "C:\Program Files (x86)\KeyStore Explorer\jre\bin\keytool.exe"
$liveDir = "C:\Certbot\live\entreprises.ccism.pf"
$pfxDir = "C:\Certbot\qmatic"
$pfxPath = "$pfxDir\domain.pfx"
$jksPathBi = "C:\qmatic\bi\conf\security\keystore.jks"
$jksPathOrchestra = "C:\qmatic\orchestra\system\conf\security\keystore.jks"
$jksPathApi = "C:\qmatic\APIGateway\conf\keystore.jks"
$password = "changeit"
$QmaticBI = "QPBusinessintelligence"
$QmaticPlatform = "QP"
$QmaticAPIGateway = "QP_API_GW"
$listenaddress = "10.0.0.5"
$listenport = 80
$connectport = 8080
$connectaddress = "10.0.0.5"

# Liste des chemins à vérifier
$pathsToCheck = @($certbotPathExe, $opensslPath, $keytoolPath, $liveDir, "$liveDir\privkey.pem", "$liveDir\cert.pem")

# Vérifier si les chemins existent
foreach ($path in $pathsToCheck) {
    if (-not (Test-Path $path)) {
        throw "Le chemin spécifié n'existe pas : $path`nVeuillez vérifier que le chemin est correctement attribué."
    }
}

# Créer le répertoire pfxDir s'il n'existe pas
if (-not (Test-Path $pfxDir)) {
    New-Item -ItemType Directory -Path $pfxDir | Out-Null
}

try {
    # Enlève la redirection du port 80 sur le port 8080
    Write-Host "Suppression de la redirection du port 80 sur le port 8080..."
    netsh interface portproxy delete v4tov4 listenaddress=$listenaddress listenport=$listenport

    # Renouveler le certificat
    Write-Host "Renouvellement du certificat..."
    & $certbotPathExe renew

    # Vérifier si le renouvellement a réussi
    if ($LastExitCode -ne 0) {
        throw "Erreur lors du renouvellement du certificat."
    }

    # Remet la redirection du port 80 sur le port 8080
    Write-Host "Réactivation de la redirection du port 80 sur le port 8080..."
    netsh interface portproxy add v4tov4 listenaddress=$listenaddress listenport=$listenport connectaddress=$connectaddress connectport=$connectport

    # Convertir le certificat en fichier PKCS12
    Write-Host "Conversion du certificat en PKCS12..."
    & $opensslPath pkcs12 -export -in "$liveDir\cert.pem" -inkey "$liveDir\privkey.pem" -out $pfxPath -password pass:$password -name orchestra

    # Vérifier si la conversion a réussi
    if ($LastExitCode -ne 0) {
        throw "Erreur lors de la conversion du certificat en PKCS12."
    }

    $keystores = @($jksPathBi, $jksPathOrchestra, $jksPathApi)
    # Importer le fichier PKCS12 dans les keystores JKS
    foreach ($keystore in $keystores) {
        Write-Host "Importation dans le keystore JKS à $keystore..."
        & $keytoolPath -importkeystore -srckeystore $pfxPath -srcstoretype pkcs12 -srcstorepass $password -srcalias orchestra -destkeystore $keystore -deststoretype jks -deststorepass $password -noprompt

        # Vérifier si l'importation a réussi
        if ($LastExitCode -ne 0) {
            throw "Erreur lors de l'importation du PKCS12 dans le keystore JKS à $keystore."
        }

        ## NOUVELLE METHODE POUR LE PKCS12 EN SPLIT ##
        # # Migrer le keystore JKS vers le format PKCS12
        # Write-Host "Migration du keystore JKS vers le format PKCS12 à $keystore..."
        # & $keytoolPath -importkeystore -srckeystore $keystore -destkeystore $keystore -deststoretype pkcs12 -srcstorepass $password -deststorepass $password -noprompt

        # # Vérifier si la migration a réussi
        # if ($LastExitCode -ne 0) {
        #     throw "Erreur lors de la migration du keystore JKS vers le format PKCS12 à $keystore."
        # }
    }

    ## NOUVELLE METHODE POUR LE PKCS12 EN FULL ##
    # Importer le fichier PKCS12 dans les keystores JKS et les migrer vers PKCS12
    # foreach ($jksPath in $jksPaths) {
    #     Write-Host "Importation et migration dans le keystore PKCS12 à $jksPath..."
    #     & $keytoolPath -importkeystore -srckeystore $pfxPath -srcstoretype pkcs12 -srcstorepass $password -srcalias orchestra -destkeystore $jksPath -deststoretype pkcs12 -deststorepass $password -noprompt

    #     # Vérifier si l'importation a réussi
    #     if ($LastExitCode -ne 0) {
    #         throw "Erreur lors de l'importation et de la migration du PKCS12 dans le keystore à $jksPath."
    #     }
    # }

    # Redémarrer les services pour que les nouveaux certificats soient pris en compte
    $services = @($QmaticBI, $QmaticPlatform, $QmaticAPIGateway)
    foreach ($service in $services) {
        Write-Host "Redémarrage du service $service..."
        Restart-Service -Name $service

        # Vérifier si le redémarrage a réussi
        if ($LastExitCode -ne 0) {
            throw "Erreur lors du redémarrage du service $service."
        }

        # Attendre 10 secondes avant de redémarrer le prochain service pour des raisons de sécurité afin que le service précédent soit bien démarrer
        Start-Sleep -Seconds 10
    }

    Write-Host "`nLe processus de renouvellement et de configuration du certificat est terminé avec succès."

    # Se connecter à Azure et redémarrer la VM
    # Write-Host "Connexion à Azure..."
    # Connect-AzAccount

    # Write-Host "Redémarrage de la VM Azure $vmName..."
    # Restart-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

    # if ($LastExitCode -ne 0) {
    #     throw "Erreur lors du redémarrage de la VM Azure $vmName."
    # }
}
catch {
    Write-Host "Une erreur est survenue: $_"
    exit 1
}