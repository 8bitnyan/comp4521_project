import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/settings_model.dart';

class SettingsService {
  final _supabase = Supabase.instance.client;

  // Keys for SharedPreferences
  static const String _themeKey = 'theme_mode';
  static const String _notificationsKey = 'notifications_enabled';

  // Get theme settings (light/dark)
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  // Save theme settings
  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }

  // Get notification settings
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  // Save notification settings
  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }

  Future<Settings?> fetchSettings(String userId) async {
    final response = await _supabase
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .single();
    if (response == null) return null;
    return Settings.fromJson(response);
  }

  Future<void> saveSettings(String userId, Settings settings) async {
    // Upsert: insert or update if exists
    await _supabase.from('user_settings').upsert({
      'user_id': userId,
      ...settings.toJson(),
    });
  }
}
