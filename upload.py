import json
from supabase import create_client, Client

url: str = "https://ozdaupsjprogpcyqfuqf.supabase.co"
key: str = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im96ZGF1cHNqcHJvZ3BjeXFmdXFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDk2NTE3MDgsImV4cCI6MjAyNTIyNzcwOH0.tu-ZyWjIBufjQI7GMxwzrWdJxdwKe4Eh9XJWqXEZCeQ"
supabase: Client = create_client(url, key)

# fetch file data.json for data to insert
with open('data.json', 'r') as file:
    data = json.load(file)

    # Prepare a list of rows to insert
    rows_to_upsert = []
    for entry in data['data']:
        for street in entry['data']:
            county = entry['city']
            if 'locality' in street and street['locality']:
                county = street['locality']
            
            if 'street' not in street or street['street'] == None:
                continue

            row = {
                'region': 'TOSCANA',
                'city': entry['city'],
                'street': street['street'],
                'county': county,
                'schedule': json.dumps({ 'data': street['schedule'] })
            }
            rows_to_upsert.append(row)
    
    # Perform a multi-insert for all prepared rows
    if rows_to_upsert:
        supabase.table('data').upsert(rows_to_upsert, ignore_duplicates=True).execute()

print ("DONE!")