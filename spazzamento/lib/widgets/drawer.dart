import 'package:flutter/material.dart';
import '../constants.dart'; // Define constants like `howItWorks` and `privacyPolicy` here.

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
