import requests
import json

def load_config(config_file):
    with open(config_file, 'r') as file:
        return json.load(file)

def send_sms(config):
    url = "https://services.osb.pf/apisms-prod/api"
    params = {
        "action": "sendmessage",
        "username": config['identifiant'],
        "password": config['password'],
        "originator": config['provenance'],
        "recipient": config['number'],
        "messagetype": "SMS:TEXT",
        "messagedata": config['message_data']
    }
    
    auth = (config['auth_username'], config['auth_password'])

    response = requests.get(url, params=params, auth=auth)
    
    if response.status_code == 200:
        print('SMS sent successfully')
    else:
        print(f'Failed to send SMS: {response.status_code} - {response.text}')


config_file = 'c:/Users/ccism/Desktop/TestResquestSMS/config.json'
config = load_config(config_file)

send_sms(config)

