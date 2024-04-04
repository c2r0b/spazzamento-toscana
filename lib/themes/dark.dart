import 'package:flutter/material.dart';

final ColorScheme darkColorScheme = ColorScheme.fromSwatch().copyWith(
  brightness: Brightness.dark,
  primary: Colors.white,
  onPrimary: Colors.red, // Needed for contrast (e.g., text on primary color)
  secondary: const Color.fromRGBO(0, 128, 207, 1),
  onSecondary: Colors.black,
  tertiary: const Color.fromRGBO(1, 91, 147, 1),
  error: Colors.red, // Keep some contrast for error states
  onError: Colors.white,
  background: Colors.black,
  onBackground: Colors.white,
  surface: const Color.fromARGB(255, 0, 16, 26),
  onSurface: Colors.white,
);

final ThemeData darkTheme = ThemeData(
  // Define other theme properties as needed
  colorScheme: darkColorScheme,
  useMaterial3: true, // If you're using Material 3

  // Set the divider color
  dividerColor:
      const Color.fromARGB(255, 0, 28, 45), // Replace with your desired color
);
