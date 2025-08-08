import 'package:flutter/material.dart';

final Color customBlue = Color.fromARGB(255, 58, 91, 182); // Color(0xFF007ACC);

class AppThemes {
  // light theme
  static final light = ThemeData(
    primaryColor: customBlue,
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: customBlue,
      primary: customBlue,
      brightness: Brightness.light,
      surface: Colors.white,
    ),
    cardColor: Colors.white,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: customBlue,
      unselectedItemColor: Colors.grey,
    ),
  );

  // dark theme
  static final dark = ThemeData(
    primaryColor: customBlue,
    scaffoldBackgroundColor: Color(0xFF121212),
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: customBlue,
      primary: customBlue,
      brightness: Brightness.dark,
      surface: Color(0xFF121212),
    ),
    cardColor: Color(0xFF1E1E1E),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: customBlue,
      unselectedItemColor: Colors.grey,
    ),
  );
}
