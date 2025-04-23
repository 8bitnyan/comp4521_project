import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  Settings? _settings;
  bool _isLoading = false;
  String? _error;

  Settings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
}
