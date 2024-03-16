import '../models/schedule_info.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationController {
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
    if (!schedule.weekDay!.isNotEmpty || schedule.from == null) {
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
    };

    List<int?> restrictedDays = [];

    // Define restrictedDays based on dayEven or dayOdd values
    if (schedule.dayEven == true) {
      restrictedDays = List.generate(31, (index) => index + 1)
          .where((element) => element % 2 == 0)
          .toList();
    } else if (schedule.dayOdd == true) {
      restrictedDays = List.generate(31, (index) => index + 1)
          .where((element) => element % 2 != 0)
          .toList();
    }

    if (restrictedDays.isEmpty) {
      restrictedDays.add(0); // Ensure it executes at least once
    }

    // Ensure monthWeek is not null
    // defaulting to [0] if necessary to ensure it executes at least once
    List<int?> monthWeek = [];
    if (schedule.monthWeek.isNotEmpty) {
      monthWeek = schedule.monthWeek;
    } else {
      monthWeek.add(0);
    }

    // Calculate the number of notifications to schedule
    int numberOfNotifications = monthWeek.length *
        schedule.weekDay!.length *
        restrictedDays.length; // Number of notifications to schedule

    int currentNumberOfNotifications =
        await listAll().then((value) => value.length);

    if (currentNumberOfNotifications + numberOfNotifications > 64) {
      throw Exception('Too many notifications scheduled');
    }

    List<Future> notificationFutures = [];

    for (var monthweek in monthWeek) {
      for (var weekday in schedule.weekDay!) {
        for (var day in restrictedDays) {
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
                  day: day == 0 ? null : day,
                  hour: hour,
                  minute: minute,
                  weekOfMonth: monthweek == 0 ? null : monthweek));

          notificationFutures.add(future);

          // Throttle the creation to avoid overloading
          if (notificationFutures.length >= 10) {
            // Adjust this number based on performance
            await Future.wait(notificationFutures);
            notificationFutures.clear();
          }
        }
      }
    }

    // Wait for any remaining futures
    if (notificationFutures.isNotEmpty) {
      await Future.wait(notificationFutures);
    }
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
