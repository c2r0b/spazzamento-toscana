import '../services/notification.dart';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'pages/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env.app");

  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_KEY']!,
    );
  } catch (error) {
    print('Error initializing the API connection: $error');
  }

  try {
    await NotificationController.initialize();
  } catch (error) {
    print('Error initializing the notification service: $error');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spazzamento',
      theme: themeData,
      home: const HomePage(title: 'Spazzamento'),
      debugShowCheckedModeBanner: false,
    );
  }
}
