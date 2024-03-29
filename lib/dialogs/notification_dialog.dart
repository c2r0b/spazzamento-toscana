import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'notification_list.dart';
import '../services/notification.dart';

Future<void> showPendingNotifications(BuildContext context) async {
  if (!context.mounted) return;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Notifiche'),
        content: FutureBuilder<List<NotificationModel>>(
          future: NotificationController.listUnique(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                width: 60, // Define a specific width
                height:
                    60, // Define a specific height to maintain the aspect ratio
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              var notifications = snapshot.data ?? [];
              return notifications.isNotEmpty
                  ? NotificationList(notifications: notifications)
                  : const Text('Nessuna notifica programmata');
            } else {
              return const Text('Nessun dato disponibile');
            }
          },
        ),
        actionsAlignment: MainAxisAlignment.center, // Centers the actions
        actions: <Widget>[
          TextButton(
            child: const Text('Chiudi'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
