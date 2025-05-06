import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class for storing API keys and other configuration values
class AppConfig {
  /// Initialize the app configuration
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // If .env file is not found, use default values (for development only)
      print('Warning: .env file not found. Using default values.');
    }
  }

  /// Get the Google Maps API key
  static String get googleMapsApiKey {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ??
        'AIzaSyCAjnCtA7VNOUHOhIAK-wQ80f04QeQDrkQ'; // Placeholder for builds without .env
  }
}
