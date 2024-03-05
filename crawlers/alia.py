import requests
import re
import json
import html
import time
from bs4 import BeautifulSoup
import urllib.request

base_url = "https://www.aliaserviziambientali.it/puliziastrade"

# Function to map Italian days to numerical representation (Monday=1, Sunday=7)
def map_weekday(day):
    days = {
        "Lunedi": 1,
        "Martedi": 2,
        "Mercoledi": 3,
        "Giovedi": 4,
        "Venerdi": 5,
        "Sabato": 6,
        "Domenica": 7
    }
    return days.get(day, 0)

# Function to extract time from the 'time' string
def extract_time(time_str):
    time_parts = time_str.split('alle')
    return time_parts[0].strip().replace('dalle ', ''), time_parts[1].strip()

# Function to update the JSON file with the new data for a street
def update_json_file(city, street_data, street_name):
    json_file_path = '../data.json'
    
    # Read the existing data
    with open(json_file_path, 'r') as file:
        data = json.load(file)
    
    # Find the FIRENZE entry and update its 'data' array
    for entry in data['data']:
        if entry['city'] == city:
            entry['data'].append({
                'street': street_name,
                'schedule': street_data
            })
            break
    
    # Write the updated data back to the JSON file
    with open(json_file_path, 'w') as file:
        json.dump(data, file, indent=4)

# Function to get cleaning schedule
def get_cleaning_schedule(street):
    # Get street parts
    url = f"{base_url}/main/get_tratti"
    data = {
        "id_strada": street['id_strada']
    }
    try:
        response = requests.post(url, data=data)
        response.raise_for_status()  # This will raise an exception for HTTP error codes
    except requests.RequestException as e:
        print(f"Request failed: {e}")
    parts = response.json()

    if not parts:
        parts = [{'tratto': ''}]

    schedule = []
    for p in parts:
        if type(p['tratto']) is not str:
            tratto = html.unescape(p['tratto'])
        else:
            tratto = p['tratto']

        tratto = tratto.replace('&#039;', "'")
        print(tratto)
        
        url = f"{base_url}/pulizie/calcola_data"
        data = {
            "id_strada": street['id_strada'],
            "trattostrada": tratto,
            "tipo_strada": street['tipo_strada'],
            "civico": "",
            "comune": "FIRENZE"
        }
        try:
            response = requests.post(url, data=data)
            response.raise_for_status()  # This will raise an exception for HTTP error codes
        except requests.RequestException as e:
            print(f"Request failed: {e}")

        # of the response html, get the third <center> tag content
        response = response.text

        # get last center tag
        response = response.split('<center>')[-1]
        response = response.split('<\/center>')[0]
        data = response.split(' dalle')
        
        if len(data) < 2:
            continue

        # Now process 'day' and 'time'
        day_info = data[0]
        time_info = data[1]

        # Initialize the new structure
        new_entry = {
            'location': tratto,
        }

        # Parse and transform 'day' field
        if "Ogni" in day_info:  # Handle even and odd days scenario
            if "dispari" in day_info:
                new_entry['dayOdd'] = True
            elif "pari" in day_info:
                new_entry['dayEven'] = True
            new_entry['weekDay'] = map_weekday(day_info.split(' ')[1])
        else:
            week_match = re.search(r'(\d+)&ordm', day_info)
            if week_match:
                new_entry['monthWeek'] = int(week_match.group(1))
            week_day = day_info.split(' ')[-2]
            new_entry['weekDay'] = map_weekday(week_day)

        # Parse and transform 'time' field
        from_time, to_time = extract_time(time_info)
        new_entry['from'] = from_time
        new_entry['to'] = to_time

        schedule.append(new_entry)

    return schedule

def update_city(city):
    # List of streets to scrape
    # Navigate to the page
    url = f"{base_url}/main/get_indirizzi"
    data = {
        "comune": city
    }

    # Send a GET request to the URL
    try:
        response = requests.post(url, data=data)
        response.raise_for_status()  # This will raise an exception for HTTP error codes
    except requests.RequestException as e:
        print(f"Request failed: {e}")

    streets = response.json()

    # clear json file array first
    json_file_path = '../data.json'
    with open(json_file_path, 'r') as file:
        data = json.load(file)
        found = False
        for entry in data['data']:
            if entry['city'] == city:
                entry['data'] = []
                found = True
                break

        if not found:
            data['data'].append({
                'city': city,
                'data': []
            })
        
        with open(json_file_path, 'w') as file:
            json.dump(data, file, indent=4)

    for street in streets:
        time.sleep(0.5)
        print(city + ' - ' + street['nome'])
        street_schedule = get_cleaning_schedule(street)
        update_json_file(city, street_schedule, street['nome'])

# get list of cities
fp = urllib.request.urlopen(base_url)
content = fp.read()
html = content.decode("utf8")
fp.close()

# Parse the HTML content
soup = BeautifulSoup(html, 'html.parser')

cities = []

# Find the select element by its name or ID (assuming 'comune' is the ID or name)
select_element = soup.find('select', {'name': 'comune'}) or soup.find('select', {'id': 'comune'})

# Extract all the option values within the select element
if select_element:
    options = select_element.find_all('option')
    for option in options:
        # Assuming the city names are the text of the options
        city = option.text.strip()
        if city:  # Make sure it's not an empty string
            cities.append(city)

for city in cities:
    update_city(city)