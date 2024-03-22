import 'package:flutter/material.dart';

final ColorScheme colorScheme = ColorScheme.fromSwatch().copyWith(
  brightness: Brightness.light,
  primary: const Color.fromRGBO(0, 41, 67, 1.0),
  onPrimary: Colors.red, // Needed for contrast (e.g., text on primary color)
  secondary: const Color.fromRGBO(0, 41, 67, 1.0),
  onSecondary: Colors.black,
  error: Colors.red, // Keep some contrast for error states
  onError: Colors.white,
  background: Colors.white,
  onBackground: Colors.black,
  surface: Colors.white,
  onSurface: Colors.black,
);

final ThemeData themeData = ThemeData(
  // Define other theme properties as needed
  colorScheme: colorScheme,
  useMaterial3: true, // If you're using Material 3

  // Set the divider color
  dividerColor: const Color.fromARGB(
      255, 225, 225, 225), // Replace with your desired color
);
