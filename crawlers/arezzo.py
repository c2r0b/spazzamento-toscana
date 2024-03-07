import requests
import re
import json
import time

base_url = "https://sit.comune.arezzo.it//rifiuti_comunali/pub/app"

# clear json file array first
json_file_path = '../data.json'
with open(json_file_path, 'r') as file:
    data = json.load(file)
    found = False
    for entry in data['data']:
        if entry['city'] == 'AREZZO':
            entry['data'] = []
            found = True
            break

    if not found:
        data['data'].append({
            'city': 'AREZZO',
            'data': []
        })
    
    with open(json_file_path, 'w') as file:
        json.dump(data, file, indent=4)

# Function to update the JSON file with the new data for a street
def update_json_file(city, street_data, street_name, locality):
    json_file_path = '../data.json'
    
    # Read the existing data
    with open(json_file_path, 'r') as file:
        data = json.load(file)
    
    # Find the AREZZO entry and update its 'data' array
    for entry in data['data']:
        if entry['city'] == city:
            entry['data'].append({
                'street': street_name,
                'locality': locality,
                'schedule': street_data
            })
            break
    
    # Write the updated data back to the JSON file
    with open(json_file_path, 'w') as file:
        json.dump(data, file, indent=4)

# Function to get cleaning schedule
def get_cleaning_schedule(street):
    # Get street parts
    url = f"{base_url}/get_spazzamenti_toponimo_json.php?codice={street['codice']}"
    
    try:
        response = requests.get(url)
        response.raise_for_status()  # This will raise an exception for HTTP error codes
    except requests.RequestException as e:
        print(f"Request failed: {e}")
        
    # remove leadeing and trailing parenthesis
    # read calendar as json
    text = response.text
    text = text[1:-1]
    calendar = json.loads(text)['dati_calendario']

    schedule = []
    for entry in calendar:
        schedule.append({
            'day': entry['descrizione'],
            'start': entry['data_inizio'],
            'end': entry['data_fine'],
            'morning': entry['mattino_pomeriggio'] == 'MATTINO',
            'afternoon': entry['mattino_pomeriggio'] == 'POMERIGGIO'
        })

    return schedule


url = f"{base_url}/get_toponimi_json.php?term=%20"

# Send a GET request to the URL
try:
    response = requests.get(url)
    response.raise_for_status()  # This will raise an exception for HTTP error codes
except requests.RequestException as e:
    print(f"Request failed: {e}")

# remove leadeing and trailing parenthesis
# read streets as json
text = response.text
text = text[1:-1]
streets = json.loads(text)

# for each street
i = 0
for street in streets:
    print(street)
    time.sleep(0.1)
    street_schedule = get_cleaning_schedule(street)
    update_json_file('AREZZO', street_schedule, street['denominazione_estesa'], street['localita'])
    exit()
