import 'package:flutter/material.dart';

class ThemeService {
  // Light theme
  static ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
        ),
      ),
      cardTheme: const CardTheme(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    );
  }

  // Dark theme
  static ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
        ),
      ),
      cardTheme: const CardTheme(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}
