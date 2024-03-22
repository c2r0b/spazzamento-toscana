import fitz
import json
import re
from utils.lib import clear_json_file, update_json_file, remove_duplicates, download_pdf, day_to_number, roman_to_int

# clear content if exists, otherwise create it
clear_json_file('CARRARA')


def extract_data_from_pdf(pdf_data):
    # Open the PDF from bytes data
    text = ""
    doc = fitz.open(stream=pdf_data, filetype="pdf")
    for page in doc:
        text += page.get_text()

    text = text.split('\n')

    data = []
    # Iterate over the lines in the PDF with an index i, starting from line 2
    i = 6
    while i < len(text) - 4:
        line = text[i]
        from_time, to_time = text[i + 2].split(' - ')
        month_week, week_day = text[i + 3].split(' ', 1)

        data.append({
            "street": line,
            "locality": "CARRARA",
            "schedule": [{
                "from": from_time,
                "to": to_time,
                "location": text[i + 1],
                "weekDay": day_to_number(week_day),
                "monthWeek": roman_to_int(month_week)
            }]
        })
        i += 4

    return remove_duplicates(data)


pdf_url = "https://www.nausicaacarrara.it/2019/wp-content/uploads/2024/01/Calendario-spazzamento-Carrara-Centro.pdf"
pdf_data = download_pdf(pdf_url)
street_schedule = extract_data_from_pdf(pdf_data)

update_json_file('CARRARA', street_schedule)
