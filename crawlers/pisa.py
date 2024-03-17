import fitz
import json
import re
from utils.lib import clear_json_file, update_json_file, remove_duplicates, download_pdf

# clear content if exists, otherwise create it
clear_json_file('PISA')

def extract_info(input_str):
    # Initialize the dictionary
    result = {
        "monthWeek": [],
        "weekDay": None,
        "from": "",
        "to": "",
        "location": "",
        "rightSide": False,
        "leftSide": False,
        "internalSide": False,
        "externalSide": False
    }

    # Determine the side based on the starting letter
    if input_str.startswith('D'):
      result["rightSide"] = True
    elif input_str.startswith('S'):
      result["leftSide"] = True
    elif input_str.startswith('INTER'):
      result["internalSide"] = True
    elif input_str.startswith('ESTER'):
      result["externalSide"] = True

    # Extract the week numbers and weekday
    week_day_mapping = {
        "LUNEDÌ": 1,
        "MARTEDÌ": 2,
        "MERCOLEDÌ": 3,
        "GIOVEDÌ": 4,
        "VENERDÌ": 5,
        "SABATO": 6,
        "DOMENICA": 7
    }
    week_days = re.findall(r'\d+°', input_str)
    result['monthWeek'] = [int(w.strip('°')) for w in week_days]

    for day, num in week_day_mapping.items():
        if day in input_str:
            result['weekDay'] = num
            break

    # Extract the time and location
    time_location = re.search(r'(\d+\.\d+)\/(\d+\.\d+) (.+)', input_str)
    if time_location:
        result['from'] = time_location.group(1).replace('.', ':')
        result['to'] = time_location.group(2).replace('.', ':')
        result['location'] = time_location.group(3)

    return result

def extract_schedule(street):
    street_name = street.split('\n')[0].strip()

    if not street_name.startswith('PIAZZA'):
      street_name = 'Via ' + street_name
    
    schedules = street.split('\n')[1:].strip()

    result = {
      "street": street_name,
      "schedule": []
    }
    for schedule in schedules:
        data = extract_info(schedule)
        result["schedule"].append(data)

    return result

def extract_data_from_pdf(pdf_data):
    # Open the PDF from bytes data
    doc = fitz.open(stream=pdf_data, filetype="pdf")
    text = ""
    for page in doc:
        text += page.get_text()
    
    text = re.split('MEZZOGIORNO', text)[1]
    text = re.split('DISPONE', text)[0]
    
    # Split the text into chunks based on numbered paragraphs
    chunks = re.split(r'\(\d+\)', text)[1:]  # Split and remove the first element if it's empty
    
    # Initialize the data structure
    data = []

    for chunk in chunks:
        streets = re.split('•', chunk)[1:]

        for street in streets:
            result = extract_schedule(street)
            if result:
                for entry in result:
                    data.append(entry)

    return remove_duplicates(data)

pdf_url = "https://www.comune.pisa.it/sites/default/files/2013_05_13_11_22_29.pdf"
pdf_data = download_pdf(pdf_url)
street_schedule = extract_data_from_pdf(pdf_data)

update_json_file('PISA', street_schedule)
