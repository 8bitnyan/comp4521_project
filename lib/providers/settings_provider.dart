import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  Settings? _settings;
  bool _isLoading = false;
  String? _error;

  static const String kFontSizeKey = 'font_size';
  static const String kLanguageKey = 'language';
  static const String kNotifyEventsKey = 'notify_events';
  static const String kNotifyFoodMenusKey = 'notify_food_menus';
  static const String kNotifyFacilitiesKey = 'notify_facilities';
  static const String kShowLocationKey = 'show_location';
  static const String kDefaultMapTypeKey = 'default_map_type';
  static const String kShareUsageDataKey = 'share_usage_data';

  bool _initialized = false;

  // Default values
  double _fontSize = 1.0; // 1.0 is the default (normal) font size
  String _language = 'en'; // Default language is English
  bool _notifyEvents = true;
  bool _notifyFoodMenus = true;
  bool _notifyFacilities = true;
  bool _showLocation = true;
  int _defaultMapType = 1; // 1 = Normal, 2 = Satellite, 3 = Hybrid, 4 = Terrain
  bool _shareUsageData = true;

  Settings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _initialized;
  double get fontSize => _fontSize;
  String get language => _language;
  bool get notifyEvents => _notifyEvents;
  bool get notifyFoodMenus => _notifyFoodMenus;
  bool get notifyFacilities => _notifyFacilities;
  bool get showLocation => _showLocation;
  int get defaultMapType => _defaultMapType;
  bool get shareUsageData => _shareUsageData;

  SettingsProvider() {
    // Use microtask to load settings asynchronously
    Future.microtask(() => _loadSettings());
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _fontSize = prefs.getDouble(kFontSizeKey) ?? 1.0;
      _language = prefs.getString(kLanguageKey) ?? 'en';
      _notifyEvents = prefs.getBool(kNotifyEventsKey) ?? true;
      _notifyFoodMenus = prefs.getBool(kNotifyFoodMenusKey) ?? true;
      _notifyFacilities = prefs.getBool(kNotifyFacilitiesKey) ?? true;
      _showLocation = prefs.getBool(kShowLocationKey) ?? true;
      _defaultMapType = prefs.getInt(kDefaultMapTypeKey) ?? 1;
      _shareUsageData = prefs.getBool(kShareUsageDataKey) ?? true;

      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> loadSettings(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _settings = await _settingsService.fetchSettings(userId);
    } catch (e) {
      _error = 'Failed to load settings: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(String userId, Settings newSettings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _settingsService.saveSettings(userId, newSettings);
      _settings = newSettings;
    } catch (e) {
      _error = 'Failed to save settings: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Setters with local storage
  Future<void> setFontSize(double size) async {
    if (_fontSize == size) return;
    _fontSize = size;
    _saveToPrefs(kFontSizeKey, size);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (_language == code) return;
    _language = code;
    _saveToPrefs(kLanguageKey, code);
    notifyListeners();
  }

  Future<void> setNotifyEvents(bool value) async {
    if (_notifyEvents == value) return;
    _notifyEvents = value;
    _saveToPrefs(kNotifyEventsKey, value);
    notifyListeners();
  }

  Future<void> setNotifyFoodMenus(bool value) async {
    if (_notifyFoodMenus == value) return;
    _notifyFoodMenus = value;
    _saveToPrefs(kNotifyFoodMenusKey, value);
    notifyListeners();
  }

  Future<void> setNotifyFacilities(bool value) async {
    if (_notifyFacilities == value) return;
    _notifyFacilities = value;
    _saveToPrefs(kNotifyFacilitiesKey, value);
    notifyListeners();
  }

  Future<void> setShowLocation(bool value) async {
    if (_showLocation == value) return;
    _showLocation = value;
    _saveToPrefs(kShowLocationKey, value);
    notifyListeners();
  }

  Future<void> setDefaultMapType(int type) async {
    if (_defaultMapType == type) return;
    _defaultMapType = type;
    _saveToPrefs(kDefaultMapTypeKey, type);
    notifyListeners();
  }

  Future<void> setShareUsageData(bool value) async {
    if (_shareUsageData == value) return;
    _shareUsageData = value;
    _saveToPrefs(kShareUsageDataKey, value);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _fontSize = 1.0;
    _language = 'en';
    _notifyEvents = true;
    _notifyFoodMenus = true;
    _notifyFacilities = true;
    _showLocation = true;
    _defaultMapType = 1;
    _shareUsageData = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all settings
    notifyListeners();
  }

  // Helper method to save to SharedPreferences
  Future<void> _saveToPrefs(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      }
    } catch (e) {
      debugPrint('Error saving setting $key: $e');
    }
  }
}
