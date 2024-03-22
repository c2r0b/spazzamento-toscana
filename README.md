# Spazzamento Toscana
Flutter app for the management of the street washing service info in Tuscany.

## Description
This app is designed to provide the citizens of Tuscany with information about the street washing service in their area. 

## Features
- [x] Search for the street washing service in a specific municipality
- [x] Receive notifications when the service is about to start in the selected municipality
- [x] View the days and times when the service is active in the selected municipality

## Technologies
- [Flutter](https://flutter.dev/): app development
- [Supabase](https://supabase.io/): database
- [Python](https://www.python.org/): data scraping

## Data source
The python script `run.py` is used to scrape the data from the official websites of the Tuscany region. The data is then stored in json files inside the `data` folder.  
The same script is used to upload the data to the Supabase database.

## Environment variables
You need to create a `.env` file in the root directory of the project following the example below:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_key
SUPABASE_EMAIL=your_supabase_email
SUPABASE_PASSWORD=your_supabase_password
```

## License
© 2024 Spazzamento Toscana by [c2r0b](https://github.com/c2r0b)