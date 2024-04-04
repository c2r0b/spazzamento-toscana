import 'package:flutter/material.dart';

final ColorScheme lightColorScheme = ColorScheme.fromSwatch().copyWith(
  brightness: Brightness.light,
  primary: Colors.black,
  onPrimary: Colors.red, // Needed for contrast (e.g., text on primary color)
  secondary: const Color.fromRGBO(0, 128, 207, 1),
  onSecondary: Colors.black,
  tertiary: const Color.fromRGBO(1, 91, 147, 1),
  error: Colors.red, // Keep some contrast for error states
  onError: Colors.white,
  background: Colors.white,
  onBackground: Colors.black,
  surface: Colors.white,
  onSurface: Colors.black,
);

final ThemeData lightTheme = ThemeData(
  // Define other theme properties as needed
  colorScheme: lightColorScheme,
  useMaterial3: true, // If you're using Material 3

  // Set the divider color
  dividerColor: const Color.fromARGB(
      255, 225, 225, 225), // Replace with your desired color
);
