import json
import requests
from io import BytesIO

# function to get the file name from the city


def get_json_file_path(city):
    return f'./data/{city.lower().replace("_", "")}.json'

# clear content if exists, otherwise create it


def clear_json_file(city):
    with open(get_json_file_path(city), 'w') as file:
        json.dump({"city": city.upper(), "data": []}, file, indent=4)

# Function to update the JSON file with the new data for the streets


def update_json_file(city, data):
    # Read the existing data
    with open(get_json_file_path(city), 'r') as file:
        file_data = json.load(file)

    file_data['data'] = data

    # Write the updated data back to the JSON file
    with open(get_json_file_path(city), 'w') as file:
        json.dump(file_data, file, indent=4)

# Function to add the new data for a street to the JSON file


def add_to_json_file(city, data):
    # Read the existing data
    with open(get_json_file_path(city), 'r') as file:
        file_data = json.load(file)

    file_data['data'].append(data)

    # Write the updated data back to the JSON file
    with open(get_json_file_path(city), 'w') as file:
        json.dump(file_data, file, indent=4)

# Function to map the Italian day names to weekday numbers (1 for Monday, ..., 7 for Sunday)


def day_to_number(day):
    days = {"LUN": 1, "MAR": 2, "MER": 3, "GIO": 4, "VEN": 5, "SAB": 6, "DOM": 7, "LUNEDI": 1, "MARTEDI": 2, "MERCOLEDI": 3, "GIOVEDI": 4, "VENERDI": 5, "SABATO": 6, "SABATI": 6, "DOMENICA": 7, "DOMENICHE": 7, "Lunedi": 1, "Martedi": 2,
            "Mercoledi": 3, "Giovedi": 4, "Venerdi": 5, "Sabato": 6, "Domenica": 7, "LUN.": 1, "MAR.": 2, "MER.": 3, "GIO.": 4, "VEN.": 5, "SAB.": 6, "DOM.": 7, "LUNED\u00cc": 1, "MARTED\u00cc": 2, "MERCOLED\u00cc": 3, "GIOVED\u00cc": 4, "VENERD\u00cc": 5, "lunedì": 1, "martedì": 2, "mercoledì": 3, "giovedì": 4, "venerdì": 5, "sabato": 6, "domenica": 7}
    return days.get(day, None)

# Function to remove duplicate entries from the data


def remove_duplicates(data):
    merged_data = []

    while data:
        # Pop the first element
        current = data.pop(0)

        # Initialize a list to store indices for removal
        to_remove = []

        # Compare with the rest of the list
        for i, item in enumerate(data):
            if current['street'] == item['street'] and current['locality'] == item['locality']:
                current['schedule'] += item['schedule']  # Merge schedules
                to_remove.append(i)  # Mark for removal

        # Remove merged items from the end to avoid index shifting
        for i in reversed(to_remove):
            data.pop(i)

        # Add the merged item to the new list
        merged_data.append(current)

    # Now merged_data contains the merged entries
    return merged_data

# Function to download a PDF file from a URL


def download_pdf(url):
    response = requests.get(url)
    response.raise_for_status()
    return BytesIO(response.content)


def roman_to_int(s):
    """
    :type s: str
    :rtype: int
    """
    roman = {'I': 1, 'V': 5, 'X': 10, 'L': 50, 'C': 100, 'D': 500,
             'M': 1000, 'IV': 4, 'IX': 9, 'XL': 40, 'XC': 90, 'CD': 400, 'CM': 900}
    i = 0
    num = 0
    while i < len(s):
        if i+1 < len(s) and s[i:i+2] in roman:
            num += roman[s[i:i+2]]
            i += 2
        else:
            # print(i)
            num += roman[s[i]]
            i += 1
    return num
