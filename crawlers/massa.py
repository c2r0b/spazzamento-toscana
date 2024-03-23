import fitz
import re
from utils.lib import clear_json_file, update_json_file, remove_duplicates, download_pdf, day_to_number

# clear content if exists, otherwise create it
clear_json_file('MASSA')


def extract_data_from_pdf(pdf_data):
    # Open the PDF from bytes data
    doc = fitz.open(stream=pdf_data, filetype="pdf")
    text = ""
    for page in doc:
        text += page.get_text()

    text = re.split('Allo scopo di consentire', text)[1]
    text = re.split('Il presente provvedimento', text)[0]

    # Get paragraphs
    time_p, streets_p = re.split('spazzamento ect.:', text)

    # Get time
    time_p = re.split(r'con \n*orario ', time_p)[1]
    time_p = re.split(',', time_p)[0]
    from_time, to_time = re.split('-', time_p)

    # Get streets data
    pattern = r"(LUNED[IÌ]’?|MARTED[IÌ]’?|MERCOLED[IÌ]’?|GIOVED[IÌ]’?|VENERD[IÌ]’?|SABATO|DOMENICA)\s*:\s?"
    days = re.split(pattern, streets_p, flags=re.IGNORECASE)

    # Check if the first element is an empty string and remove it
    if days[0].strip() == '':
        days = days[1:]

    data = []
    i = 0
    while i < len(days):
        weekday = day_to_number(days[i])
        streets = re.split(r'\)-\s*(?=Via|Piazza)', days[i+1])
        for street in streets:
            street = street.replace('\n', '')

            if '(' in street:
                street_name, side = street.split('(', 1)
                side = side.split(')')[0].strip()
            else:
                street_name = street
                side = ''

            if street_name == '':
                continue

            data.append({
                "street": street_name,
                "locality": "Massa-Carrara",
                "schedule": [
                    {
                        "from": from_time,
                        "to": to_time,
                        "weekDay": weekday,
                        "location": side
                    }
                ]
            })
        i += 2

    return remove_duplicates(data)


# MASSA
pdf_url = "https://storico.comune.massa.ms.it/sites/default/files/ordinanzasostaauto.pdf"
pdf_data = download_pdf(pdf_url)
street_schedule = extract_data_from_pdf(pdf_data)

# MARINA DI MASSA
pdf_url = "https://storico.comune.massa.ms.it/sites/default/files/ordinanzasostaauto1.pdf"
pdf_data = download_pdf(pdf_url)
street_schedule += extract_data_from_pdf(pdf_data)

update_json_file('MASSA', street_schedule)
