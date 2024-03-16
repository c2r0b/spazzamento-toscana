import 'package:flutter/material.dart';
import 'theme.dart';
import 'pages/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(
      url: 'https://ozdaupsjprogpcyqfuqf.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im96ZGF1cHNqcHJvZ3BjeXFmdXFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDk2NTE3MDgsImV4cCI6MjAyNTIyNzcwOH0.tu-ZyWjIBufjQI7GMxwzrWdJxdwKe4Eh9XJWqXEZCeQ',
    );

    await AwesomeNotifications().initialize(
      // Set the icon to null if you want to use the default app icon
      'resource://drawable/ic_launcher',
      [
        NotificationChannel(
            channelKey: 'spazzamento_reminder_channel',
            channelName: 'Spazzamento',
            channelDescription: 'Notifiche per il giorno di spazzamento',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: Colors.white)
      ],
    );

    runApp(const MyApp());
  } catch (error) {
    print('Error initializing the app: $error');
    // Handle initialization error (perhaps show an error screen)
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spazzamento',
      theme: themeData,
      home: const HomePage(title: 'Spazzamento'),
    );
  }
}
