# Guide de Compilation du Script Python en `.exe`, et pour la configuration du `config.ini`

## Introduction

Ce document fournit des instructions pour compiler le script Python `script_renew_truststore.py` en un fichier exécutable Windows `.exe` à l'aide de PyInstaller. Vous trouverez également des informations sur la manière de configurer et d'exécuter le programme.

## Prérequis

Avant de commencer, assurez-vous d'avoir installé les outils suivants :

- **Python** (version 3.x recommandée)
- **PyInstaller** (pour compiler le script Python en `.exe`)

## Installation des Prérequis

1. **Installer Python**

   Téléchargez et installez Python depuis [le site officiel](https://www.python.org/downloads/).

2. **Installer PyInstaller**

   Ouvrez une invite de commandes et exécutez la commande suivante pour installer PyInstaller via `pip` :

   ```bash
   pip install pyinstaller
   ```

## Préparation

1. **Créer un fichier de configuration**

   Créez un fichier nommé `config.ini` dans le même répertoire que votre script Python avec le contenu suivant :

   ```ini
   [Paths]
   fullchain_pem = C:\Certbot\live\entreprises.ccism.pf\fullchain.pem
   truststore_path_1 = C:\qmatic\APIGateway\conf\truststore.jks
   truststore_path_2 = C:\qmatic\bi\conf\security\truststore.jks

   [Certificate]
   alias = orchestra
   storepass = changeit
   ```

   Assurez-vous que les chemins et les paramètres sont corrects pour votre environnement.

2. **Préparer le script Python**

   Assurez-vous que le script `script_renew_truststore.py` est prêt et fonctionne correctement.

## Compilation

1. **Naviguer vers le répertoire du script**

   Ouvrez une invite de commandes et changez le répertoire de travail vers le répertoire contenant votre script `script_renew_truststore.py` :

   ```bash
   cd C:\Users\ccism\Desktop\RENEW_TRUSTORE
   ```

2. **Compiler le script en `.exe`**

   Utilisez PyInstaller pour compiler le script en un exécutable `.exe` :

   ```bash
   pyinstaller --onefile script_renew_truststore.py
   ```

   Cette commande générera un fichier exécutable `.exe` dans le sous-répertoire `dist` du répertoire courant.

## Exécution

1. **Localiser l'exécutable**

   Après compilation, l'exécutable sera situé dans le dossier `dist` :

   ```bash
   dist\script_renew_truststore.exe
   ```

2. **Exécuter le programme**

   Placez le fichier `config.ini` dans le même répertoire que l'exécutable ou assurez-vous qu'il est accessible. Ensuite, vous pouvez exécuter l'exécutable :

   ```bash
   script_renew_truststore.exe
   ```

   L'exécutable lira le fichier `config.ini` et importera les certificats dans les truststores spécifiés.

   ⚠️ __*Actuellement l'executable est mis en raccourcis sur le bureau, et dans le dossier `dist` il y a le raccourci du fichier config.*__

## Dépannage

- **Le fichier `config.ini` n'est pas trouvé** : Assurez-vous que le fichier est dans le même répertoire que l'exécutable ou que le chemin est correct.
- **Erreur lors de l'importation du certificat** : Vérifiez que les chemins dans `config.ini` sont corrects et que les fichiers nécessaires existent.

## Aide

Pour toute question ou problème, veuillez contacter l'administrateur Système.

```

### Explication des Sections

- **Introduction** : Présente brièvement ce que le README couvre.
- **Prérequis** : Liste les outils nécessaires et comment les installer.
- **Préparation** : Explique la création du fichier de configuration et la vérification du script Python.
- **Compilation** : Détaille les étapes pour compiler le script en un fichier `.exe`.
- **Exécution** : Donne des instructions pour exécuter le programme compilé.
- **Dépannage** : Propose des solutions pour les problèmes courants.
- **Aide** : Indique où obtenir de l'aide si nécessaire.

Avec ces instructions dans le `README.md`, toute personne pourra suivre les étapes pour compiler et exécuter le script Python en `.exe` de manière autonome.
