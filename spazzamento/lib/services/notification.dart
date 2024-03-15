import '../models/schedule_info.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationController {
  static Future<bool?>? requesPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      return AwesomeNotifications().requestPermissionToSendNotifications();
    }
    return true;
  }

  static Future<void> schedule(ScheduleInfo schedule, String currentAddress,
      context, Function refresh) async {
    await requesPermission();
    // User choice for when to be alerted
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Avvisami'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: const Text('12 ore prima'),
              onTap: () async {
                Navigator.of(context).pop(); // Close the dialog
                await activate(
                    schedule, currentAddress, const Duration(hours: 12));
                whenScheduled(context);
                refresh();
              },
            ),
            ListTile(
              title: const Text('1 ora prima'),
              onTap: () async {
                Navigator.of(context).pop(); // Close the dialog
                await activate(
                    schedule, currentAddress, const Duration(hours: 1));
                whenScheduled(context);
                refresh();
              },
            ),
            ListTile(
              title: const Text('15 minuti prima'),
              onTap: () async {
                Navigator.of(context).pop(); // Close the dialog
                await activate(
                    schedule, currentAddress, const Duration(minutes: 15));
                whenScheduled(context);
                refresh();
              },
            ),
          ],
        ),
      ),
    );
  }

  static void whenScheduled(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifica attivata con successo'),
      ),
    );
  }

  static String buildSuffix(ScheduleInfo schedule) {
    if (schedule.numberEven == true) {
      return ' (civici pari)';
    }
    if (schedule.numberOdd == true) {
      return ' (civici dispari)';
    }
    return '';
  }

  static Future<void> activate(ScheduleInfo schedule, String currentAddress,
      Duration durationToSubtract) async {
    if (!schedule.weekDay!.isNotEmpty || schedule.from == null) {
      return;
    }

    int weekDay = schedule.weekDay![0];
    int hour = int.parse(schedule.from!.split(':')[0]);
    int minute = int.parse(schedule.from!.split(':')[1]);

    tz.initializeTimeZones();
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = _nextInstanceOfWeekDayWithEvenOdd(
        weekDay, hour, minute, schedule.dayEven, schedule.dayOdd, now);

    scheduledDate = scheduledDate.subtract(durationToSubtract);

    String suffix = buildSuffix(schedule);
    String description = currentAddress;

    Map<String, String> payloadMap = {
      'schedule':
          jsonEncode(schedule.toJson()), // Ensure you have a toJson method
      'currentAddress': currentAddress,
      'date': scheduledDate.toString(),
      'durationToSubtract': durationToSubtract.inSeconds
          .toString(), // Store duration in a unit (e.g., seconds)
    };

    // Use the correct scheduleDate considering the subtraction
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
        channelKey: 'spazzamento_reminder_channel',
        title:
            'Spazzamento alle ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $suffix',
        body: description,
        notificationLayout: NotificationLayout.Default,
        payload: payloadMap,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledDate),
      actionButtons: [
        NotificationActionButton(
          key: 'OPEN',
          label: 'Apri',
        ),
      ],
    );
  }

  static tz.TZDateTime _nextInstanceOfWeekDayWithEvenOdd(int weekDay, int hour,
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

  static tz.TZDateTime _nextInstanceOfWeekDay(
      int weekDay, int hour, int minute, tz.TZDateTime now) {
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduledDate.weekday != weekDay) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<NotificationModel?> fromId(String id) async {
    List<NotificationModel> activeNotifications =
        await AwesomeNotifications().listScheduledNotifications();

    for (NotificationModel notification in activeNotifications) {
      if (notification.content?.payload == null) {
        continue;
      }
      final schedule = jsonDecode(notification.content!.payload!['schedule']!)
          as Map<String, dynamic>;
      if (schedule['id'] == id) {
        return notification;
      }
    }
    return null;
  }

  static Future<bool> isActive(String id) async {
    NotificationModel? notification = await fromId(id);
    return notification != null;
  }

  static Future<void> cancel(String id) async {
    NotificationModel? notification = await fromId(id);
    if (notification != null) {
      await AwesomeNotifications().cancel(notification.content!.id!);
    }
  }
}
