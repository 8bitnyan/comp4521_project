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

  Future<Settings> fetchSettings(String userId) async {
    try {
      final response = await _supabase
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // No settings found, create default settings
        final defaultSettings = Settings(
          darkMode: false,
          notificationsEnabled: true,
        );

        await _supabase.from('user_settings').insert({
          'user_id': userId,
          ...defaultSettings.toJson(),
        });

        return defaultSettings;
      }

      return Settings.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load settings: $e');
    }
  }

  Future<void> saveSettings(String userId, Settings settings) async {
    try {
      // Prepare data for saving
      final data = {
        'user_id': userId,
        ...settings.toJson(),
      };

      // Check if settings exist
      final existing = await _supabase
          .from('user_settings')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existing == null) {
        // Create new settings
        await _supabase.from('user_settings').insert(data);
      } else {
        // Update existing settings
        await _supabase
            .from('user_settings')
            .update(data)
            .eq('user_id', userId);
      }
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  Future<void> deleteSettings(String userId) async {
    try {
      await _supabase.from('user_settings').delete().eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to delete settings: $e');
    }
  }
}
