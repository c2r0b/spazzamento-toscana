import fitz
import json
import re
from utils.lib import clear_json_file, update_json_file, remove_duplicates, download_pdf, day_to_number

# clear content if exists, otherwise create it
clear_json_file('LUCCA')


def extract_info_external(s):
    # Define the regular expression pattern to extract the necessary information
    pattern = r"dalle ore (\d+:\d+) alle ore (\d+:\d+) del (\d+)° e (\d+)° (\w+)"

    # Match the pattern with the input string
    match = re.search(pattern, s)

    if not match:
        return None  # or raise an error, depending on how you want to handle it

    # Extract the captured groups
    start_time, end_time, first_week, second_week, day_name = match.groups()

    # Convert the extracted information into the desired format
    from_time = start_time
    to_time = end_time
    monthWeek = [int(first_week), int(second_week)]
    # Ensure the day name is uppercase for matching
    weekDay = [day_to_number(day_name.upper())]

    return {
        "from": from_time,
        "to": to_time,
        "monthWeek": monthWeek,
        "weekDay": weekDay
    }


def extract_schedule_external(s, shared_info):
    data = shared_info.copy()

    if 'nc. pari' in s:
        data['numberEven'] = True
        s = s.replace('lato nc. pari', '').replace('nc. pari', '')
    if 'nc. dispari' in s:
        data['numberOdd'] = True
        s = s.replace('lato nc. dispari', '').replace('nc. dispari', '')

    s = s.replace('ambo i lati', '')

    # remove \n, - and ; from location
    data['location'] = s.replace('\n', '').replace('-', '').replace(';', '').replace(r'\s\s', ' ').replace(
        ', ', '').replace(':', '').replace('\u2019', "'").split('COMUNE DI LUCCAUProtocollo')[0].strip()

    # remove starting "e " if present
    if data['location'].startswith('e '):
        data['location'] = data['location'][2:]

    if len(data['location']) > 1:
        # capitalize first letter of location
        data['location'] = data['location'][0].upper() + data['location'][1:]

    return data


def extract_data_from_pdf_external(pdf_data):
    # Open the PDF from bytes data
    doc = fitz.open(stream=pdf_data, filetype="pdf")
    text = ""
    for page in doc:
        text += page.get_text()

    text = re.split('O R D I N A', text)[1]
    text = re.split('Significa che:', text)[0]

    # Split the text into chunks based on numbered paragraphs
    # Split and remove the first element if it's empty
    chunks = re.split(r'\(\d+\)', text)[1:]

    # Initialize the data structure
    data = []

    for chunk in chunks:
        streets = re.split('•', chunk)

        # the first element is the shared information
        shared_info = extract_info_external(streets[0])

        # drop the first element
        streets = streets[1:]
        for street in streets:
            street_name = re.split(', ', street)[0].replace(
                '\n', '').strip().split(':')[0].split(' - ')[0]

            # remove the street name from the string
            street = street.replace(street_name, '')

            # get locality name
            locality = re.split('fraz. di ', street)
            if len(locality) > 1:
                locality = locality[1].split(':')[0].replace(
                    '\n', '').strip().split(';')[0]
                street = street.replace('fraz. di ' + locality, '')
            elif len(re.split('fraz. ', street)) > 1:
                locality = re.split('fraz. ', street)[1].split(
                    ':')[0].replace('\n', '').strip().split(';')[0]
                street = street.replace('fraz. ' + locality, '')
            else:
                locality = None

            schedule = []
            if len(re.split(r'\n[\s]+-', street)) > 1:
                street_parts = re.split('\n-', street)[1:]
                for part in street_parts:
                    schedule.append(
                        extract_schedule_external(part, shared_info))
            else:
                schedule = [extract_schedule_external(street, shared_info)]

            data.append({
                "street": street_name,
                "locality": 'LUCCA',
                "schedule": schedule
            })

    return remove_duplicates(data)


def extract_info_center(s):
    day_name = s.replace('\n', '').replace(
        '\s', '').replace(',', '').replace("'", '')

    # Map the Italian day names to weekday numbers (1 for Monday, ..., 7 for Sunday)
    day_name_to_number = {
        "LUNEDI": 1,
        "MARTEDI": 2,
        "MERCOLEDI": 3,
        "GIOVEDI": 4,
        "VENERDI": 5,
        "SABATO": 6,
        "DOMENICA": 7
    }

    # Convert the extracted information into the desired format
    # Ensure the day name is uppercase for matching
    weekDay = [day_name_to_number[day_name.upper()]]

    return {
        "monthWeek": 2,
        "weekDay": weekDay
    }


def extract_schedule_center(s, shared_info):
    schedule = shared_info.copy()

    # Define the regular expression pattern to extract the necessary information
    pattern = r"dalle ore (\d+:\d+) alle ore (\d+:\d+) in ([\w\s]+)"

    # Match the pattern with the input string
    s = s.replace('\n', '').replace(';', '').replace(
        '  ', ' ').replace('ambo i lati', '')
    match = re.search(pattern, s.split(' –')[0])

    if not match:
        return None  # or raise an error, depending on how you want to handle it

    # Extract the captured groups
    start_time, end_time, street_name = match.groups()

    schedule['from'] = start_time
    schedule['to'] = end_time
    data = {
        "street": street_name,
        "locality": 'LUCCA',
        "schedule": []
    }

    # remove \n, - and ; from location
    schedule['location'] = s.split(' –')[1].replace('\n', '').replace('-', '').replace(';', '').replace(r'\s\s', ' ').replace(', ', '').replace(
        ':', '').replace('\u2019', "'").split('COMUNE DI LUCCAUProtocollo')[0].split('e in Via')[0].split('e Piazza')[0].split('e Corso')[0].strip()

    # remove starting "e " if present
    if schedule['location'].startswith('e '):
        schedule['location'] = schedule['location'][2:]

    if len(schedule['location']) > 1:
        # capitalize first letter of location
        schedule['location'] = schedule['location'][0].upper() + \
            schedule['location'][1:]

    data['schedule'] = [schedule]

    result = [data]

    # duplicate if more in the same entry
    if 'e in Via ' in s or 'e in Piazza ' in s or 'e Piazza' in s or 'e Corso' in s:
        second = data.copy()
        split_by = 'e in Via' if 'e in Via ' in s else 'e in Piazza' if 'e in Piazza ' in s else 'e Piazza' if 'e Piazza' in s else 'e Corso'
        to_add = 'Via' if 'e in Via ' in s else 'Piazza' if 'e in Piazza ' in s else 'Piazza' if 'e Piazza' in s else 'Corso'

        second['street'] = to_add + ' ' + \
            s.split(split_by)[1].split('–')[0].split('-')[0].strip()

        if 'tratto' in second['street']:
            second['schedule'][0]['location'] = 'tratto' + \
                second['street'].split('tratto')[1]
            # capitalize first letter of location
            second['schedule'][0]['location'] = second['schedule'][0]['location'][0].upper(
            ) + second['schedule'][0]['location'][1:]

        second['street'] = second['street'].split(' tratto ')[0].strip()

        # remove "in " if it starts with it
        if second['street'].startswith('in '):
            second['street'] = second['street'][3:]

        result.append(second)

    return result


def extract_data_from_pdf_center(pdf_data):
    # Open the PDF from bytes data
    doc = fitz.open(stream=pdf_data, filetype="pdf")
    text = ""
    for page in doc:
        text += page.get_text()

    text = re.split('O R D I N A', text)[1]
    text = re.split('Significa che:', text)[0]

    # Split the text into chunks based on numbered paragraphs
    # Split and remove the first element if it's empty
    chunks = re.split(r'\(\d+\)', text)[1:]

    # Initialize the data structure
    data = []

    for chunk in chunks:
        streets = re.split('•', chunk)

        # the first element is the shared information
        shared_info = extract_info_center(streets[0])

        # drop the first element
        streets = streets[1:]
        for street in streets:
            result = extract_schedule_center(street, shared_info)
            if result:
                for entry in result:
                    data.append(entry)

    return remove_duplicates(data)


pdf_url = "https://www.sistemaambientelucca.it/fileadmin/user_upload/azienda/spazzamento/ord_00324_24-02-2023.stamped.pdf"
pdf_data = download_pdf(pdf_url)
street_schedule = extract_data_from_pdf_center(pdf_data)

pdf_url = "https://www.sistemaambientelucca.it/fileadmin/user_upload/azienda/spazzamento/ord_00462_29-02-2024.pdf"
pdf_data = download_pdf(pdf_url)
street_schedule += extract_data_from_pdf_external(pdf_data)

update_json_file('LUCCA', street_schedule)
