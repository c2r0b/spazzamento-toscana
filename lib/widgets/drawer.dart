import 'package:flutter/material.dart';
import '../constants.dart';
import '../dialogs/notification_dialog.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.only(top: 40, left: 5),
        children: [
          ListTile(
            title: const Text('Come funziona'),
            leading: Icon(Icons.help_outline,
                color: Theme.of(context).colorScheme.primary),
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
            leading: Icon(Icons.notifications_active_outlined,
                color: Theme.of(context).colorScheme.primary),
            onTap: () {
              Navigator.pop(
                  context); // Close the drawer before showing the dialog
              showPendingNotifications(context);
            },
          ),
          // Segnalazione di un problema
          ListTile(
            title: const Text('Segnala un problema'),
            leading: Icon(Icons.report_problem_outlined,
                color: Theme.of(context).colorScheme.primary),
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
            leading: Icon(Icons.privacy_tip_outlined,
                color: Theme.of(context).colorScheme.primary),
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
