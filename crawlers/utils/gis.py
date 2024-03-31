import requests
import json
from concurrent.futures import ThreadPoolExecutor
from utils.lib import clear_json_file, update_json_file, day_to_number, merge_equal_schedules, merge_weekday_schedules

# Function to parse the 'day' field and convert it into the desired format


def parse_day_field(day_field):
    # replace "PRIMO"/"PRIMA" with "1°", "SECONDO"/"SECONDA" with "2°", etc.
    day_field = day_field.replace("PRIMO", "1°").replace("PRIMA", "1°").replace("SECONDO", "2°").replace(
        "SECONDA", "2°").replace("TERZO", "3°").replace("TERZA", "3°").replace("QUARTO", "4°").replace("QUARTA", "4°")

    if "TUTTI I GIORNI FERIALI" in day_field:
        return {"weekDay": [1, 2, 3, 4, 5, 6]}
    elif "TUTTI I GIORNI" in day_field:
        return {"weekDay": [1, 2, 3, 4, 5, 6, 7]}
    elif "TUTTI I" in day_field:
        days = day_field.split("TUTTI I ")[1].split(' ')[0].split("-")
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

# Function to get cleaning schedule


def get_cleaning_schedule(street, base_url):
    # Get street parts
    url = f"{
        base_url}/get_spazzamenti_toponimo_json.php?codice={street['codice']}"

    try:
        response = requests.get(url)
        response.raise_for_status()  # This will raise an exception for HTTP error codes
    except requests.RequestException as e:
        print(f"Request failed: {e}")

    # remove leadeing and trailing parenthesis
    # read calendar as json
    text = response.text[1:-1]
    calendar = json.loads(text)['dati_calendario']

    schedule = []
    for entry in calendar:
        parsed_entry = parse_day_field(entry['descrizione'])
        parsed_entry['start'] = convert_date_format(entry['data_inizio'])
        parsed_entry['end'] = convert_date_format(entry['data_fine'])
        parsed_entry['morning'] = entry['mattino_pomeriggio'] == 'Mattino' or 'Mattino' in entry['descrizione']
        parsed_entry['afternoon'] = entry['mattino_pomeriggio'] == 'Pomeriggio' or 'Pomeriggio' in entry['descrizione']
        schedule.append(parsed_entry)

    # Merge equal schedules
    schedule = merge_equal_schedules(schedule)

    # Merge schedules with only different weekdays
    schedule = merge_weekday_schedules(schedule)

    return schedule

# Function to get cleaning schedule for a street


def fetch_street_schedule(street, base_url):
    print(street['denominazione_estesa'])
    street_schedule = get_cleaning_schedule(street, base_url)
    return {
        'street': street['denominazione_estesa'],
        'locality': street['localita'],
        'schedule': street_schedule
    }

# Function to fetch and process all streets


def fetch_all_streets(streets, base_url):
    with ThreadPoolExecutor(max_workers=10) as executor:
        # Using list comprehension to map executor.submit to each street
        # This will return futures
        futures = [executor.submit(fetch_street_schedule, street, base_url)
                   for street in streets]
        # Collecting results as they complete
        results = [future.result() for future in futures]
    return results


def fetch_gis(city, base_url):
    # clear content if exists, otherwise create itclear_json_file
    clear_json_file(city)

    url = f"{base_url}/get_toponimi_json.php?term=%20"

    # Send a GET request to the URL
    try:
        response = requests.get(url)
        response.raise_for_status()  # This will raise an exception for HTTP error codes
    except requests.RequestException as e:
        print(f"Request failed: {e}")
        exit()

    text = response.text[1:-1]  # Remove leading and trailing parenthesis
    streets = json.loads(text)

    # Fetch schedules for all streets in parallel
    data = fetch_all_streets(streets, base_url)

    # Update JSON file once all data is collected
    update_json_file(city, data)
