
import requests
import re
import json
import time
from utils.lib import clear_json_file, add_to_json_file, day_to_number

base_url = "https://sit.comune.arezzo.it//rifiuti_comunali/pub/app"

# clear content if exists, otherwise create itclear_json_file
clear_json_file('AREZZO')

# Function to parse the 'day' field and convert it into the desired format
def parse_day_field(day_field):
    if "TUTTI I GIORNI FERIALI" in day_field:
        return {"weekDay": [1, 2, 3, 4, 5, 6]}
    elif "TUTTI I GIORNI" in day_field:
        return {"weekDay": [1, 2, 3, 4, 5, 6, 7]}
    elif "TUTTI I" in day_field:
        days = day_field.split("TUTTI I ")[1].split("-")
        return {"weekDay": [day_to_number(day.strip()) for day in days]}
    elif "°" in day_field:
        # This will need to be adjusted based on the exact format of 'day' when it includes "°"
        week_numbers = [int(num) for num in day_field if num.isdigit()]
        days = day_field.split(" ")
        week_days = [day_to_number(day) for day in days]
        week_days = list(filter(None, week_days))
        return {
            "monthWeek": week_numbers,
            "weekDay": week_days
        }
    else:
        # Default case, needs to be adjusted based on possible values of 'day'
        return {}

# Function to convert date format from "dd/mmm" to "dd-mm"
def convert_date_format(date_str):
    months = {"gen": "01", "feb": "02", "mar": "03", "apr": "04", "mag": "05", "giu": "06",
              "lug": "07", "ago": "08", "set": "09", "ott": "10", "nov": "11", "dic": "12"}
    day, month = date_str.split("/")
    return f"{day}-{months[month]}"

# Function to update the JSON file with the new data for a street
def update_json_file(street_data, street_name, locality):
    add_to_json_file('AREZZO', {
        'street': street_name,
        'locality': locality,
        'schedule': street_data
    })

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
        parsed_entry = parse_day_field(entry['descrizione'])
        parsed_entry['source'] = entry['descrizione']
        parsed_entry['start'] = convert_date_format(entry['data_inizio'])
        parsed_entry['end'] = convert_date_format(entry['data_fine'])
        parsed_entry['morning'] = entry['mattino_pomeriggio'] == 'MATTINO' or 'MATTINO' in entry['descrizione']
        parsed_entry['afternoon'] = entry['mattino_pomeriggio'] == 'POMERIGGIO' or 'POMERIGGIO' in entry['descrizione']
        schedule.append(parsed_entry)

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
    print(street['denominazione_estesa'])
    time.sleep(0.1)
    street_schedule = get_cleaning_schedule(street)
    update_json_file(street_schedule, street['denominazione_estesa'], street['localita'])
