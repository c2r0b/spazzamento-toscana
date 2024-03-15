import json
from supabase import create_client, Client

url: str = "https://ozdaupsjprogpcyqfuqf.supabase.co"
key: str = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im96ZGF1cHNqcHJvZ3BjeXFmdXFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDk2NTE3MDgsImV4cCI6MjAyNTIyNzcwOH0.tu-ZyWjIBufjQI7GMxwzrWdJxdwKe4Eh9XJWqXEZCeQ"
supabase: Client = create_client(url, key)

# fetch file data.json for data to insert
with open('data.json', 'r') as file:
    data = json.load(file)

    # Prepare a list of rows to insert
    rows_to_upsert = {}
    for entry in data['data']:
        for street in entry['data']:
            county = entry['city']
            if 'locality' in street and street['locality']:
                county = street['locality']

            if 'street' not in street or street['street'] == None:
                continue

            # Construct a unique key for each row - adjust this based on your unique constraints
            unique_key = f"{entry['city']}_{street['street']}_{county}"
            
            # Update the dictionary only if the key is not present
            if unique_key not in rows_to_upsert:
                rows_to_upsert[unique_key] = {
                    'region': 'TOSCANA',
                    'city': entry['city'],
                    'street': street['street'],
                    'county': county,
                    'schedule': json.dumps({ 'data': street['schedule'] })
                }

    # Convert the dictionary values to a list for upserting
    unique_rows_to_upsert = list(rows_to_upsert.values())
    
    # Perform a multi-insert for all prepared rows
    if unique_rows_to_upsert:
        supabase.table('data').upsert(unique_rows_to_upsert).execute()

print ("DONE!")