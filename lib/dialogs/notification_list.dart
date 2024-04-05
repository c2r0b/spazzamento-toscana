import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'notification_dialog.dart';
import '../services/notification.dart';

class NotificationList extends StatelessWidget {
  final List<NotificationModel> notifications;

  const NotificationList({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          var notification = notifications[index];
          Map<String, String?> payloadMap = notification.content!.payload!;
          String title = notification.content?.title ?? 'Errore titolo';
          return Dismissible(
            key: Key(notification.content!.id.toString()),
            onDismissed: (direction) async {
              await NotificationController.cancel(payloadMap['id']!);
              Navigator.pop(context);
              showPendingNotifications(
                  context); // Recursively refresh the list.
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              child: ListTile(
                title: Text(notification.content!.body ?? 'Errore notifica'),
                subtitle: Text(title,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary)),
              ),
            ),
          );
        },
      ),
    );
  }
}
