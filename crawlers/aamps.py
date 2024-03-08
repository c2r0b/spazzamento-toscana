import ast
import re
import requests
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import json
import os

# Path to the WebDriver executable
driver_path = "/usr/local/Caskroom/chromedriver/122.0.6261.94/chromedriver-mac-x64/chromedriver"

# Print the path to the WebDriver executable
print(driver_path)

# Initialize the WebDriver
service = Service(executable_path=driver_path)

# Pass the Service object when creating the instance of Chrome
driver = webdriver.Chrome(service=service)

base_url = "https://servizi.aamps.livorno.it/Servizi"

# Function to update the JSON file with the new data for a street
def update_json_file(street_data, street_name):
    json_file_path = '../data.json'
    
    # Read the existing data
    with open(json_file_path, 'r') as file:
        data = json.load(file)
    
    # Find the LIVORNO entry and update its 'data' array
    for entry in data['data']:
        if entry['city'] == 'LIVORNO':
            entry['data'].append({
                'street': street_name,
                'schedule': street_data
            })
            break
    
    # Write the updated data back to the JSON file
    with open(json_file_path, 'w') as file:
        json.dump(data, file, indent=4)

allowed_img_src = [
    'https://servizi.aamps.livorno.it/Servizi/img/spazzamento-combinato.png',
    'https://servizi.aamps.livorno.it/Servizi/img/spazzamento-meccanizzato-con-regolazione-sosta.png'
];

def transform_data(original_data):
    day_mapping = {"Lun": 1, "Mar": 2, "Mer": 3, "Gio": 4, "Ven": 5, "Sab": 6, "Dom": 7, "LUNEDI": 1, "MARTEDI": 2, "MERCOLEDI": 3, "GIOVEDI": 4, "VENERDI": 5, "SABATO": 6, "DOMENICA": 7, "Lunedi": 1, "Martedi": 2, "Mercoledi": 3, "Giovedi": 4, "Venerdi": 5, "Sabato": 6, "Domenica": 7, "Lunedì": 1, "Martedì": 2, "Mercoledì": 3, "Giovedì": 4, "Venerdì": 5, "Luned\u00ec": 1, "Marted\u00ec": 2, "Mercoled\u00ec": 3, "Gioved\u00ec": 4, "Venerd\u00ec": 5}
    transformed_data = []
    entries = [];

    # make two entries
    if "civici pari" in original_data["day"] and "civici dispari" in original_data["day"]:
        # separate the part of the text that contains civici pari/dispari from the rest (whichever comes first)
        index = min(original_data["day"].index("civici pari"), original_data["day"].index("civici dispari"))

        # check if "civil pari" is before "civici dispari"
        if original_data["day"].index("civici pari") < original_data["day"].index("civici dispari"):
            entries.append(original_data["day"][:index] + " civici pari")
            entries.append(original_data["day"][index:].replace("civici pari", ""))
        else:
            entries.append(original_data["day"][:index] + " civici dispari")
            entries.append(original_data["day"][index:].replace("civici dispari", ""))
    else:
        entries.append(original_data["day"])

    for entry in entries:
        new_entry = {
            "location": original_data["location"],
            "from": original_data["time"].split("-")[0],
            "to": original_data["time"].split("-")[1]
        }
        # Handle weekdays and special cases
        if "ESTIVO" in entry:
            new_entry["summerOnly"] = True
        
        if "civici pari" in entry:
            new_entry["numberEven"] = True
        elif "civici dispari" in entry:
            new_entry["numberOdd"] = True
        
        if " PARI" in entry:
            new_entry["dayEven"] = True
        elif "DISPARI" in entry:
            new_entry["dayOdd"] = True
        
        new_entry_week_day = []

        data = entry.replace(" + ", " ").split(" ")
        for portion in data:
            if portion in day_mapping:
                new_entry_week_day.append(day_mapping[portion])
            
        new_entry["weekDay"] = new_entry_week_day if len(new_entry_week_day) > 1 else new_entry_week_day[0]

        transformed_data.append(new_entry)
    
    return transformed_data

# Function to get cleaning schedule
def get_cleaning_schedule(street_name):
    # Construct the URL for the specific street, assuming the website has a predictable URL structure
    # This may need to be updated to reflect the actual website structure
    url = f"{base_url}/ajax.php?opzione=cercacivico&via={street_name}"
    
    # Send a GET request to the URL
    response = requests.get(url)

    # Extract the JSON data from the response
    data = response.json()

    # Get one address per street (data does not differentiate between different addresses on the same street, so we just take the first one)
    civico = None
    for d in data:
        if d['ECEZVA']:
          civico = d['ECEZVA']
          break
    
    if not civico:
        return None

    # if not a number, skip
    if not civico.isdigit():
        return None

    # get all ECEZVA fields frome each json array element
    driver.get("https://servizi.aamps.livorno.it/Servizi/index.php")
    
    js_script = f"$('#address').val(\"{street_name}\");$('#addressscelto').val(\"{street_name}\");$('#civico').val('{civico}');$('#cerca').click();"
    driver.execute_script(js_script)

    # Wait for the table to appear or for any specific element that indicates the page has loaded the relevant data
    wait = WebDriverWait(driver, 100)  # Wait for up to 10 seconds
    element_present = EC.presence_of_element_located((By.CSS_SELECTOR, '#griglia_tabella_spazzamento tbody tr'))  # Replace 'some-class' with a relevant class name that indicates the dropdown is loaded or the page has updated
    wait.until(element_present)
    time.sleep(2)

    # Find the submit button and click it
    # Replace 'button_id_or_name' with the actual ID or name of the submit button
    submit_button = driver.find_element(By.NAME, 'floating_panel_spazzamento_open')
    submit_button.click()

    # Extract the schedule
    # Replace 'result_element_selector' with the actual selector to find the schedule information
    rows = driver.find_element(By.CSS_SELECTOR, '#griglia_tabella_spazzamento').find_elements(By.TAG_NAME, 'tr')
    
    schedule = []
    for row in rows:
        cells = row.find_elements(By.TAG_NAME, 'td')
        data = [cell.text for cell in cells]
        if data.__len__() > 2:
            # ignore rows for manual cleaning
            img_src = cells[0].find_element(By.TAG_NAME, 'img').get_attribute('src')
            if img_src in allowed_img_src:
                original_data = {
                    'location': data[1],
                    'day': data[2],
                    'time': data[3]
                }
                data = transform_data(original_data)
                for entry in data:
                    schedule.append(entry)
    return schedule

# List of streets to scrape
# Navigate to the page
driver.get(f"{base_url}/index.php")

# Wait for the page to load completely
WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.TAG_NAME, "body")))

# Get the page source
page_source = driver.page_source

# Use a regular expression to find the 'listaindirizzi' variable
# This pattern assumes that the array is formatted exactly like in your example
match = re.search(r"var listaindirizzi = (\[.*?\]);", page_source)

streets = []
if match:
    # Extract the group which contains the JSON array
    json_array = match.group(1)
    json_array = re.sub(r"(?<!\\)'", '"', json_array)
    
    # Convert this JSON array into a Python list
    # Using json.loads to handle string conversion including handling of escaped characters
    try:
        # Safely evaluate the string to convert it to a Python list
        streets = ast.literal_eval(json_array.replace('\\', ''))
    except ValueError as e:
        print(f"Error converting JavaScript array to Python list: {e}")
        streets = []

# Dictionary to hold the schedules
schedules = {}

# clear json file array first
json_file_path = '../data.json'
with open(json_file_path, 'r') as file:
    data = json.load(file)
    for entry in data['data']:
        if entry['city'] == 'LIVORNO':
            entry['data'] = []
            break
    
    with open(json_file_path, 'w') as file:
        json.dump(data, file, indent=4)

for street in streets:
    time.sleep(1)
    print(street)
    street_schedule = get_cleaning_schedule(street)
    update_json_file(street_schedule, street)

# Close the WebDriver
driver.quit()
