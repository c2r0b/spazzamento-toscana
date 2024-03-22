import '../services/notification.dart';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'pages/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(
      url: 'https://ozdaupsjprogpcyqfuqf.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im96ZGF1cHNqcHJvZ3BjeXFmdXFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDk2NTE3MDgsImV4cCI6MjAyNTIyNzcwOH0.tu-ZyWjIBufjQI7GMxwzrWdJxdwKe4Eh9XJWqXEZCeQ',
    );

    await NotificationController.initialize();

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
