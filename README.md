# Spazzamento Toscana <img align="left" width="45" height="45" src="android/app/src/main/res/mipmap-xhdpi/ic_launcher.png" style="margin-right:15px" />
Mobile app to view street washing service info in Tuscany.  
Setup upcoming street cleaning notifications to avoid fines*.

[<img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg">](https://apps.apple.com/it/app/spazzamento-toscana/id6479202229)

## Description
This app is designed to provide the citizens of Tuscany with information about the street washing service.  

(*) You can setup notifications that remind you of upcoming street cleaning, altough checking the correct information on street signs is always recommended to make sure the information provided by the app is up to date.

[<img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/57/a1/54/57a1549a-71fb-0a9a-b3a6-95de5dc9ffa3/d88e13f7-1b53-49fd-8bff-df6d24c9ace2_Simulator_Screenshot_-_iPhone_15_Pro_Max_-_2024-03-29_at_18.06.17.png/230x0w.webp">](https://apps.apple.com/it/app/spazzamento-toscana/id6479202229)
[<img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/a0/61/62/a0616203-300b-e920-69e3-261bd6baa043/ec345880-431b-4d54-9504-b70ef80795fc_Simulator_Screenshot_-_iPhone_15_Pro_Max_-_2024-03-29_at_18.06.31.png/230x0w.webp">](https://apps.apple.com/it/app/spazzamento-toscana/id6479202229)

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

## Development
You need to create a `.env.py` file in the root directory of the project following the example below:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_key
SUPABASE_EMAIL=your_supabase_email
SUPABASE_PASSWORD=your_supabase_password
```
This file is used to store the Supabase credentials for the python upload script.  

You need to create a `.env.app` file in the root directory of the project following the example below, to store the Supabase URL for the Flutter app:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_anon_key
```

## License
The MIT license. Please see the [`LICENSE`](./LICENSE) file for more details.
