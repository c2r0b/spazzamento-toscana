import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
            title: Text(AppLocalizations.of(context)!.howItWorks),
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
                        Text(AppLocalizations.of(context)!.howItWorksText),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context)!.close),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.scheduledNotifications),
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
            title: Text(AppLocalizations.of(context)!.reportIssue),
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
                        Text(AppLocalizations.of(context)!.reportIssueText(
                            'segnalazioni@spazzamentotoscana.it')),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context)!.close),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.privacyPolicy),
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
                        Text(AppLocalizations.of(context)!.privacyPolicyText),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context)!.close),
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
