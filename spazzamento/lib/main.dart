import 'package:Spazzamento/services/notification.dart';
import 'package:Spazzamento/models/schedule_info.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'theme.dart';
import 'pages/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> onActionReceivedMethod(
    ReceivedAction receivedNotification) async {}

Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification) async {
  if (receivedNotification.payload != null) {
    // Parsing the payload data.
    Map<String, dynamic> payload = receivedNotification.payload!;
    ScheduleInfo schedule =
        ScheduleInfo.fromJson(jsonDecode(payload['schedule']));
    String currentAddress = payload['currentAddress'];
    int durationToSubtract = int.parse(payload['durationToSubtract']);

    // Parsing the payload data.
    NotificationController.activate(
        schedule, currentAddress, Duration(seconds: durationToSubtract));
  } else {
    print("Payload is null");
  }
}

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

    AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onNotificationDisplayedMethod: onNotificationDisplayedMethod);

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
