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
    wait = WebDriverWait(driver, 10)  # Wait for up to 10 seconds
    element_present = EC.presence_of_element_located((By.CSS_SELECTOR, '#griglia_tabella_spazzamento tbody tr'))  # Replace 'some-class' with a relevant class name that indicates the dropdown is loaded or the page has updated
    wait.until(element_present)
    time.sleep(1)  # Wait an additional 2 seconds to ensure the page has fully loaded

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
            if cells[0].find_element(By.TAG_NAME, 'img').get_attribute('src') == 'img/spazzamento-combinato.png':
                schedule.append({
                    'location': data[1],
                    'day': data[2],
                    'time': data[3]
                })

    exit();
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
    print(street)
    street_schedule = get_cleaning_schedule(street)
    update_json_file(street_schedule, street)

# Close the WebDriver
driver.quit()
