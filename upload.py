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
            row = {
                'city': entry['city'],
                'street': street['street'],
                'schedule': json.dumps({ 'data': street['schedule'] })
            }
            rows_to_upsert.append(row)
    
    # Perform a multi-insert for all prepared rows
    if rows_to_upsert:
        supabase.table('data').upsert(rows_to_upsert).execute()

print ("DONE!")