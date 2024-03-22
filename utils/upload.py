import json
import os
from supabase import create_client, Client

url: str = "https://ozdaupsjprogpcyqfuqf.supabase.co"
key: str = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im96ZGF1cHNqcHJvZ3BjeXFmdXFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDk2NTE3MDgsImV4cCI6MjAyNTIyNzcwOH0.tu-ZyWjIBufjQI7GMxwzrWdJxdwKe4Eh9XJWqXEZCeQ"
supabase: Client = create_client(url, key)

# Prepare a list of rows to insert
rows_to_upsert = {}

directory = './data'

# loop read all json files in the data folder
# for each file, insert the data into the supabase table
for filename in os.listdir(directory):
    # Construct the full path to the file
    filepath = os.path.join(directory, filename)

    # Check if it's a file
    if os.path.isfile(filepath):
        # Open and read the file
        with open(filepath, 'r') as file:
            data = json.load(file)
            for street in data['data']:
                county = data['city']
                if 'locality' in street and street['locality']:
                    county = street['locality']

                if 'street' not in street or street['street'] == None:
                    continue

                # Construct a unique key for each row - adjust this based on your unique constraints
                unique_key = f"{data['city']}_{street['street']}_{county}"

                # Update the dictionary only if the key is not present
                if unique_key not in rows_to_upsert:
                    rows_to_upsert[unique_key] = {
                        'region': 'TOSCANA',
                        'city': data['city'],
                        'street': street['street'],
                        'county': county,
                        'schedule': json.dumps({'data': street['schedule']})
                    }

# Convert the dictionary values to a list for upserting
unique_rows_to_upsert = list(rows_to_upsert.values())

# Perform a multi-insert for all prepared rows
if unique_rows_to_upsert:
    supabase.table('data').upsert(unique_rows_to_upsert).execute()

print("> Upload completed <")
