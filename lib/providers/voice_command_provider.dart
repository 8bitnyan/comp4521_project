import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/voice_command_service.dart';

class VoiceCommandProvider extends ChangeNotifier {
  final VoiceCommandService _voiceCommandService = VoiceCommandService();
  bool _isInitialized = false;
  String _currentText = '';
  bool _isListening = false;
  double _speechRate = 0.5;
  double _speechPitch = 1.0;
  bool _voiceCommandsEnabled = true;

  static const String _speechRateKey = 'speech_rate';
  static const String _speechPitchKey = 'speech_pitch';
  static const String _voiceCommandsEnabledKey = 'voice_commands_enabled';

  VoiceCommandProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _speechRate = prefs.getDouble(_speechRateKey) ?? 0.5;
    _speechPitch = prefs.getDouble(_speechPitchKey) ?? 1.0;
    _voiceCommandsEnabled = prefs.getBool(_voiceCommandsEnabledKey) ?? true;

    await _initializeService();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_speechRateKey, _speechRate);
    await prefs.setDouble(_speechPitchKey, _speechPitch);
    await prefs.setBool(_voiceCommandsEnabledKey, _voiceCommandsEnabled);
  }

  Future<void> _initializeService() async {
    await _voiceCommandService.initialize();
    await _voiceCommandService.setSpeechRate(_speechRate);
    await _voiceCommandService.setSpeechPitch(_speechPitch);
    _isInitialized = true;
    notifyListeners();
  }

  void startListening(BuildContext context) {
    if (!_isInitialized || !_voiceCommandsEnabled) return;

    _isListening = true;
    notifyListeners();

    _voiceCommandService.startListening(context, (text) {
      _currentText = text;
      notifyListeners();
    });
  }

  void stopListening() {
    if (!_isInitialized) return;

    _voiceCommandService.stopListening();
    _isListening = false;
    notifyListeners();
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) return;
    await _voiceCommandService.speak(text);
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _voiceCommandService.setSpeechRate(rate);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSpeechPitch(double pitch) async {
    _speechPitch = pitch;
    await _voiceCommandService.setSpeechPitch(pitch);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setVoiceCommandsEnabled(bool enabled) async {
    _voiceCommandsEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  String get currentText => _currentText;
  double get speechRate => _speechRate;
  double get speechPitch => _speechPitch;
  bool get voiceCommandsEnabled => _voiceCommandsEnabled;
}
