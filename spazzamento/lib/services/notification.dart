import '../models/schedule_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> scheduleNotification(ScheduleInfo schedule, context,
    FlutterLocalNotificationsPlugin plugin) async {
  // User choice for when to be alerted
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Avvisami'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: const Text('24 ore prima'),
            onTap: () {
              Navigator.of(context).pop(); // Close the dialog
              activateNotification(
                  schedule, const Duration(days: 1), context, plugin);
            },
          ),
          ListTile(
            title: const Text('1 ora prima'),
            onTap: () {
              Navigator.of(context).pop(); // Close the dialog
              activateNotification(
                  schedule, const Duration(hours: 1), context, plugin);
            },
          ),
          ListTile(
            title: const Text('15 minuti prima'),
            onTap: () {
              Navigator.of(context).pop(); // Close the dialog
              activateNotification(
                  schedule, const Duration(minutes: 15), context, plugin);
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> activateNotification(
    ScheduleInfo schedule,
    Duration durationToSubtract,
    context,
    FlutterLocalNotificationsPlugin plugin) async {
  if (!schedule.weekDay!.isNotEmpty || schedule.from == null) {
    return;
  }

  int weekDay = schedule.weekDay![0];
  int hour = int.parse(schedule.from!.split(':')[0]);
  int minute = int.parse(schedule.from!.split(':')[1]);

  tz.initializeTimeZones(); // Initialize time zone package
  tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = _nextInstanceOfWeekDayWithEvenOdd(
      weekDay, hour, minute, schedule.dayEven, schedule.dayOdd, now);

  scheduledDate = scheduledDate.subtract(durationToSubtract);

  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('spazzamento_reminder_channel', 'Spazzamento',
          channelDescription: 'Notifiche per il giorno di spazzamento',
          importance: Importance.max,
          priority: Priority.high);
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  await plugin.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      'Spazzamento ${schedule.location} alle ${hour}:${minute}',
      'Ricordati di spostare l\'auto se necessario!',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);

  // Check pending notifications (for debugging)
  final List<PendingNotificationRequest> pendingNotificationRequests =
      await plugin.pendingNotificationRequests();
  for (var pendingNotificationRequest in pendingNotificationRequests) {
    print('NOTIFICA' + pendingNotificationRequest.title!);
  }
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Notifica attivata con successo'),
    ),
  );
}

tz.TZDateTime _nextInstanceOfWeekDayWithEvenOdd(int weekDay, int hour,
    int minute, bool? dayEven, bool? dayOdd, tz.TZDateTime now) {
  tz.TZDateTime scheduledDate =
      _nextInstanceOfWeekDay(weekDay, hour, minute, now);

  // Adjust for even/odd day scheduling
  while ((dayEven == true && scheduledDate.day.isOdd) ||
      (dayOdd == true && scheduledDate.day.isEven)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
    // Ensure the adjusted date still matches the specified weekday
    while (scheduledDate.weekday != weekDay) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
  }

  return scheduledDate;
}

tz.TZDateTime _nextInstanceOfWeekDay(
    int weekDay, int hour, int minute, tz.TZDateTime now) {
  tz.TZDateTime scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  while (scheduledDate.weekday != weekDay) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}
