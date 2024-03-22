import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/schedule_info.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationController {
  static Future<void> initialize() async {
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

    // listen for notification events
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: onNotificationActionReceivedMethod);
  }

  static Future<void> onNotificationActionReceivedMethod(
      ReceivedNotification receivedNotification) async {
    if (receivedNotification.payload != null) {
      // Parsing the payload data.
      Map<String, dynamic> payload = receivedNotification.payload!;
      Map<String, dynamic> json = jsonDecode(payload['schedule']);
      ScheduleInfo schedule = ScheduleInfo.fromJson(
          json['city'], json['county'], json['street'], json);
      String address = payload['address'];
      int hoursToSubtract = int.parse(payload['hoursToSubtract']);

      // Parsing the payload data.
      NotificationController.activate(schedule, address, hoursToSubtract);
    }
  }

  static int getLimit() {
    if (Platform.isAndroid) {
      return 500;
    }
    return 64;
  }

  static Future<void> checkLimitExceeded(int numberOfNotifications) async {
    int currentNumberOfNotifications =
        await listAll().then((value) => value.length);
    if (currentNumberOfNotifications + numberOfNotifications > getLimit()) {
      throw Exception('Too many notifications scheduled');
    }
  }

  static Future<bool?>? requesPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      return AwesomeNotifications().requestPermissionToSendNotifications();
    }
    return true;
  }

  static String buildSuffix(ScheduleInfo schedule) {
    if (schedule.location != null && schedule.location!.isNotEmpty) {
      return ' (${schedule.location})';
    }
    if (schedule.numberEven == true) {
      return ' (civici pari)';
    }
    if (schedule.numberOdd == true) {
      return ' (civici dispari)';
    }
    return '';
  }

  static Future<void> activate(
      ScheduleInfo schedule, String currentAddress, int hoursToSubtract) async {
    if (!schedule.weekDay.isNotEmpty || schedule.from == null) {
      return;
    }

    int daysToSubtract = 0;
    int hourToDisplay = int.parse(schedule.from!.split(':')[0]);
    int hour = hourToDisplay - hoursToSubtract;
    int minute = int.parse(schedule.from!.split(':')[1]);

    if (hour < 0) {
      hour = 24 + hour;
      daysToSubtract = 1;
    }

    String suffix = buildSuffix(schedule);
    String description = currentAddress;

    Map<String, String> payloadMap = {
      'id': schedule.id,
      'address': currentAddress,
      'schedule': jsonEncode(schedule.toJson()),
      'hoursToSubtract': hoursToSubtract.toString(),
    };

    if (schedule.monthWeek.isEmpty &&
        schedule.dayEven == null &&
        schedule.dayOdd == null) {
      await scheduleRepeatNotification(schedule, hourToDisplay, hour, minute,
          suffix, description, payloadMap, daysToSubtract);
      return;
    }

    await scheduleSingleNotification(schedule, hourToDisplay, hour, minute,
        suffix, description, payloadMap, daysToSubtract);
  }

  static DateTime getNextNotificationDate(
      List<int?> monthWeek, List<int?> weekday, bool? dayEven, bool? dayOdd) {
    DateTime currentDate = DateTime.now();
    while (true) {
      // Check if the current date's week of the month matches any in monthWeek
      int weekOfMonth =
          ((currentDate.day + 7 - currentDate.weekday) / 7).ceil();
      bool isWeekOfMonthValid =
          monthWeek.isEmpty || monthWeek.contains(weekOfMonth);

      // Check if the current date's weekday matches any in weekday
      bool isWeekdayValid =
          weekday.isEmpty || weekday.contains(currentDate.weekday);

      // Check if the current date matches the even/odd criteria
      bool isDayEvenOddValid = true;
      if (dayEven != null && dayEven) {
        isDayEvenOddValid = currentDate.day % 2 == 0;
      } else if (dayOdd != null && dayOdd) {
        isDayEvenOddValid = currentDate.day % 2 != 0;
      }

      // If all criteria match, return the current date
      if (isWeekOfMonthValid && isWeekdayValid && isDayEvenOddValid) {
        return currentDate;
      }

      // Increment the date by one day and repeat the checks
      currentDate = currentDate.add(const Duration(days: 1));
    }
  }

  static Future<void> scheduleRepeatNotification(
      ScheduleInfo schedule,
      int hourToDisplay,
      int hour,
      int minute,
      String suffix,
      String description,
      Map<String, String> payloadMap,
      int daysToSubtract) async {
    List<int?> restrictedDays = [];

    // Ensure monthWeek is not null
    // defaulting to [0] if necessary to ensure it executes at least once
    // TODO: not currently supported by awesome_notifications
    /*List<int?> monthWeek = [];
    if (schedule.monthWeek.isNotEmpty) {
      monthWeek = schedule.monthWeek;
    } else {
      monthWeek.add(0);
    }*/

    // Calculate the number of notifications to schedule
    int
        numberOfNotifications = /*monthWeek.length */ // TODO: not currently supported by awesome_notifications
        schedule.weekDay.length *
            restrictedDays.length; // Number of notifications to schedule

    await checkLimitExceeded(numberOfNotifications);

    List<Future> notificationFutures = [];

    // TODO: not currently supported by awesome_notifications
    //for (var monthweek in monthWeek) {
    for (var weekday in schedule.weekDay) {
      var future = AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
            channelKey: 'spazzamento_reminder_channel',
            title:
                'Spazzamento alle ${hourToDisplay.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $suffix',
            body: description,
            notificationLayout: NotificationLayout.Default,
            payload: payloadMap,
          ),
          schedule: NotificationCalendar(
            allowWhileIdle: true,
            preciseAlarm: true,
            repeats: true,
            weekday: weekday - daysToSubtract,
            hour: hour,
            minute: minute,

            // TODO: not currently supported by awesome_notifications
            //weekOfMonth: monthweek == 0 ? null : monthweek
          ));

      notificationFutures.add(future);

      // Throttle the creation to avoid overloading
      if (notificationFutures.length >= 10) {
        // Adjust this number based on performance
        await Future.wait(notificationFutures);
        notificationFutures.clear();
      }
      //}
    }

    // Wait for any remaining futures
    if (notificationFutures.isNotEmpty) {
      await Future.wait(notificationFutures);
    }
  }

  static Future<void> scheduleSingleNotification(
      ScheduleInfo schedule,
      int hourToDisplay,
      int hour,
      int minute,
      String suffix,
      String description,
      Map<String, String> payloadMap,
      int daysToSubtract) async {
    DateTime date = getNextNotificationDate(
      schedule.monthWeek,
      schedule.weekDay,
      schedule.dayEven,
      schedule.dayOdd,
    ).subtract(Duration(days: daysToSubtract));

    await checkLimitExceeded(1);

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
          channelKey: 'spazzamento_reminder_channel',
          title:
              'Spazzamento alle ${hourToDisplay.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $suffix',
          body: description,
          notificationLayout: NotificationLayout.Default,
          payload: payloadMap,
        ),
        schedule: NotificationCalendar(
            allowWhileIdle: true,
            preciseAlarm: true,
            repeats: false,
            day: date.day,
            month: date.month,
            year: date.year,
            hour: hour,
            minute: minute),
        actionButtons: [
          // button to reschedule the notification
          NotificationActionButton(
            key: 'reschedule',
            label: 'Ripeti la prossima volta',
          ),
        ]);
  }

  static Future<List<NotificationModel>> listAll() async {
    return await AwesomeNotifications().listScheduledNotifications();
  }

  static Future<List<NotificationModel>> listUnique() async {
    List<NotificationModel> activeNotifications = await listAll();

    // get the first for each equal payload id
    List<NotificationModel> uniqueNotifications = [];
    for (NotificationModel notification in activeNotifications) {
      if (notification.content?.payload == null) {
        continue;
      }
      bool isUnique = true;
      for (NotificationModel uniqueNotification in uniqueNotifications) {
        if (notification.content!.payload!['id'] ==
            uniqueNotification.content!.payload!['id']) {
          isUnique = false;
          break;
        }
      }
      if (isUnique) {
        uniqueNotifications.add(notification);
      }
    }
    return uniqueNotifications;
  }

  static Future<List<NotificationModel>> fromPayloadId(String payloadId) async {
    List<NotificationModel> activeNotifications = await listAll();
    List<NotificationModel> notifications = [];

    for (NotificationModel notification in activeNotifications) {
      if (notification.content?.payload == null) {
        continue;
      }
      if (notification.content!.payload!['id'] == payloadId) {
        notifications.add(notification);
      }
    }
    return notifications;
  }

  static Future<bool> isActive(String payloadId) async {
    List<NotificationModel> notifications = await fromPayloadId(payloadId);
    return notifications.isNotEmpty;
  }

  static Future<void> cancel(String payloadId) async {
    List<NotificationModel> notifications = await fromPayloadId(payloadId);
    for (NotificationModel notification in notifications) {
      await AwesomeNotifications().cancel(notification.content!.id!);
    }
  }
}
