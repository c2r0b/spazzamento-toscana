import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import '../constants.dart';
import '../services/notification.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  void _showPendingNotifications(BuildContext context) async {
    List<NotificationModel> pendingNotifications =
        await NotificationController.listUnique();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifiche'),
        content: pendingNotifications.isNotEmpty
            ? SizedBox(
                width: double
                    .maxFinite, // Makes the alert dialog take up the full width
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pendingNotifications.length,
                  itemBuilder: (BuildContext context, int index) {
                    var notification = pendingNotifications[index];
                    Map<String, String?> payloadMap =
                        notification.content!.payload!;
                    String title =
                        notification.content?.title ?? 'Errore titolo';
                    return Dismissible(
                      key: Key(notification.content!.id.toString()),
                      onDismissed: (direction) async {
                        // Cancel the notification
                        await NotificationController.cancel(payloadMap['id']!);
                        // Optionally, refresh the list or give feedback to the user
                        Navigator.pop(context);
                        _showPendingNotifications(context); // Refresh the list
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        child: ListTile(
                          title: RichText(
                              text: TextSpan(
                            text:
                                notification.content!.body ?? 'Errore notifica',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          )),
                          subtitle: Text(title),
                        ),
                      ),
                    );
                  },
                ),
              )
            : const Text('Nessuna notifica programmata'),
        actions: <Widget>[
          TextButton(
            child: const Text('Chiudi'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //FlutterLocalNotificationsPlugin plugin =FlutterLocalNotificationsPlugin(); // Initialize the plugin

    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Text('Spazzamento Toscana'),
          ),
          ListTile(
            title: const Text('Come funziona'),
            leading: const Icon(Icons.help_outline),
            onTap: () {
              Navigator.pop(context);
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(howItWorks),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Chiudi'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Notifiche programmate'),
            leading: const Icon(Icons.notifications_active_outlined),
            onTap: () {
              Navigator.pop(
                  context); // Close the drawer before showing the dialog
              _showPendingNotifications(context);
            },
          ),
          // Segnalazione di un problema
          ListTile(
            title: const Text('Segnala un problema'),
            leading: const Icon(Icons.report_problem_outlined),
            onTap: () {
              Navigator.pop(context);
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(contacts),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Chiudi'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Rispetto della privacy'),
            leading: const Icon(Icons.privacy_tip_outlined),
            onTap: () {
              Navigator.pop(context);
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(privacyPolicy),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Chiudi'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
