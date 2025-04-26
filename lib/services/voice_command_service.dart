import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class VoiceCommandService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;
  String _lastWords = '';

  // Map of commands to their corresponding actions
  final Map<String, String> _navigationCommands = {
    'dashboard': '/dashboard',
    'events': '/events',
    'map': '/map',
    'settings': '/settings',
    'facilities': '/facilities',
    'food venues': '/venues',
    'venues': '/venues',
    'home': '/dashboard',
    'login': '/login',
    'sign up': '/signup',
    'accessibility': '/accessibility',
  };

  Future<void> initialize() async {
    // Initialize speech recognition
    _speechEnabled = await _speechToText.initialize();

    // Initialize text-to-speech
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  // Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  // Set speech pitch (0.5 to 2.0)
  Future<void> setSpeechPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

  // Start listening for voice input
  void startListening(BuildContext context, Function(String) onResult) {
    if (!_speechEnabled) {
      speak("Speech recognition not available");
      return;
    }

    _speechToText.listen(
      onResult: (SpeechRecognitionResult result) {
        _lastWords = result.recognizedWords;
        onResult(_lastWords);

        // If we have a final result, process the command
        if (result.finalResult) {
          processCommand(context, _lastWords);
        }
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );

    speak("Listening...");
  }

  // Stop listening
  void stopListening() {
    _speechToText.stop();
  }

  // Process the recognized voice command
  void processCommand(BuildContext context, String command) {
    command = command.toLowerCase().trim();

    // Check for navigation commands
    for (var entry in _navigationCommands.entries) {
      if (command.contains(entry.key)) {
        speak("Navigating to ${entry.key}");
        Navigator.of(context).pushNamed(entry.value);
        return;
      }
    }

    // Handle theme commands
    if (command.contains("dark mode") || command.contains("night mode")) {
      speak("Switching to dark mode");
      Provider.of<ThemeProvider>(context, listen: false)
          .setThemeMode(ThemeMode.dark);
      return;
    }

    if (command.contains("light mode")) {
      speak("Switching to light mode");
      Provider.of<ThemeProvider>(context, listen: false)
          .setThemeMode(ThemeMode.light);
      return;
    }

    if (command.contains("system theme") || command.contains("auto theme")) {
      speak("Switching to system theme mode");
      Provider.of<ThemeProvider>(context, listen: false)
          .setThemeMode(ThemeMode.system);
      return;
    }

    if (command.contains("back")) {
      speak("Going back");
      Navigator.of(context).pop();
      return;
    }

    if (command.contains("help")) {
      _provideHelp();
      return;
    }

    // If no command was recognized
    speak(
        "Command not recognized. Try again or say help for available commands.");
  }

  // Speak a message using text-to-speech
  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  // Provide help information about available voice commands
  void _provideHelp() {
    const String helpText =
        "Available commands include: navigate to dashboard, "
        "events, map, settings, facilities, venues, switch to dark mode, "
        "switch to light mode, switch to system theme, go back, and help.";
    speak(helpText);
  }

  // Check if speech recognition is currently active
  bool get isListening => _speechToText.isListening;

  // Get the last recognized words
  String get lastWords => _lastWords;

  // Check if speech recognition is available and initialized
  bool get speechEnabled => _speechEnabled;
}
