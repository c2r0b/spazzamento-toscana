import requests
import re
import html
import time
from bs4 import BeautifulSoup
import urllib.request
from utils.lib import clear_json_file, add_to_json_file, day_to_number

base_url = "https://www.aliaserviziambientali.it/puliziastrade"

# Function to extract time from the 'time' string


def extract_time(time_str):
    time_parts = time_str.split('alle')
    return time_parts[0].strip().replace('dalle ', ''), time_parts[1].strip()

# Function to update the JSON file with the new data for a street


def update_json_file(city, street_data, street_name):
    add_to_json_file(city, {
        'street': street_name.strip(),
        'schedule': street_data
    })

# Function to get cleaning schedule


def get_cleaning_schedule(street):
    # Get street parts
    url = f"{base_url}/main/get_tratti"
    data = {
        "id_strada": street['id_strada']
    }
    try:
        response = requests.post(url, data=data, timeout=20)
        response.raise_for_status()  # This will raise an exception for HTTP error codes
        parts = response.json()
        if not parts:
            parts = [{'tratto': ''}]
    except requests.RequestException as e:
        print(f"Request failed: {e}")
        return []

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
            response = requests.post(url, data=data, timeout=20)
            response.raise_for_status()  # This will raise an exception for HTTP error codes
        except requests.RequestException as e:
            print(f"Request failed: {e}")
            continue

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
        else:
            # Handle multiple week numbers
            week_matches = re.findall(r'(\d+)&ordm', day_info)
            if week_matches:
                new_entry['monthWeek'] = [int(match)
                                          for match in week_matches]

        # Iterate over each word and try to convert it to a day number
        new_entry['weekDay'] = []
        for word in day_info.split():
            day_num = day_to_number(word)
            if day_num is not None:
                new_entry['weekDay'].append(day_num)
                break

        # Parse and transform 'time' field
        from_time, to_time = extract_time(time_info)
        new_entry['from'] = from_time.replace('.', ':')
        new_entry['to'] = to_time.replace('.', ':')

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
        response = requests.post(url, data=data, timeout=20)
        response.raise_for_status()  # This will raise an exception for HTTP error codes
    except requests.RequestException as e:
        print(f"Request failed: {e}")

    streets = response.json()

    # clear content if exists, otherwise create it
    clear_json_file(city)

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
select_element = soup.find('select', {'name': 'comune'}) or soup.find(
    'select', {'id': 'comune'})

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
