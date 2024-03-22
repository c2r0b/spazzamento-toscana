import json
import os
from supabase import create_client, Client
from dotenv import load_dotenv

# get Supabase URL and Key from .env
load_dotenv()

url: str = os.getenv("SUPABASE_URL")
key: str = os.getenv("SUPABASE_KEY")
supabase: Client = create_client(url, key)

# authenticate with Supabase
auth_response = supabase.auth.sign_in_with_password({
    "email": os.getenv("SUPABASE_EMAIL"),
    "password": os.getenv("SUPABASE_PASSWORD")
})

# Make sure to capture and use the token from the auth response
access_token = auth_response.session.access_token

if not access_token:
    print("Authentication failed or token not available")
    exit()

directory = './data'

# Prepare a list of rows to insert
rows_to_upsert = {}

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

                if data['city'] == '' or street['street'] == '' or county == '':
                    continue

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
