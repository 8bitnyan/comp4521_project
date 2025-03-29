import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class ThemeProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoading = true;

  ThemeProvider() {
    _loadThemePreference();
  }

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    _isLoading = true;
    notifyListeners();

    final isDarkMode = await _settingsService.isDarkMode();
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

    _isLoading = false;
    notifyListeners();
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    final newMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _settingsService.setDarkMode(newMode == ThemeMode.dark);
    _themeMode = newMode;
    notifyListeners();
  }
}
