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
      debugShowCheckedModeBanner: false,
    );
  }
}
