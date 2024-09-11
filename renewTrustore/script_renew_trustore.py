import subprocess
import configparser
import os

def import_certificate(config_path):
    config = configparser.ConfigParser()
    config.read(config_path)
    
    fullchain_pem = config['Paths']['fullchain_pem']
    truststore_paths = [config['Paths']['truststore_path_1'], config['Paths']['truststore_path_2']]
    alias = config['Certificate']['alias']
    storepass = config['Certificate']['storepass']
    
    # Vérifier que le fichier fullchain.pem existe
    if not os.path.exists(fullchain_pem):
        print(f"Le fichier {fullchain_pem} est introuvable.")
        return

    for truststore_path in truststore_paths:
        if not os.path.exists(truststore_path):
            print(f"Le fichier truststore {truststore_path} est introuvable.")
            continue

        # Commande pour importer le certificat dans le truststore
        command = [
            'keytool', '-importcert', '-alias', alias, '-file', fullchain_pem, 
            '-keystore', truststore_path, '-storepass', storepass, '-noprompt'
        ]
        
        try:
            subprocess.run(command, check=True)
            print(f"Le certificat {alias} a été importé avec succès dans {truststore_path}.")
        except subprocess.CalledProcessError as e:
            print(f"Erreur lors de l'importation du certificat dans {truststore_path} : {e}")

if __name__ == "__main__":
    import_certificate('config.ini')

