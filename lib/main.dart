import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/facility_provider.dart';
import 'providers/food_venue_provider.dart';
import 'providers/voice_command_provider.dart';
import 'services/theme_service.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/events_screen.dart';
import 'screens/map_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/facilities_screen.dart';
import 'screens/food_venues_screen.dart';
import 'screens/accessibility_screen.dart';
import 'screens/camera_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration (API keys)
  await AppConfig.initialize();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: 'https://byhgngvrdzhhzedeqdsb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ5aGduZ3ZyZHpoaHplZGVxZHNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU0MjAyNzAsImV4cCI6MjA2MDk5NjI3MH0.0LBPDXe-Wesm04EerxEZ88lLP8PUbM-KdMdFxNhyLa0',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => FacilityProvider()),
        ChangeNotifierProvider(create: (_) => FoodVenueProvider()),
        ChangeNotifierProvider(create: (_) => VoiceCommandProvider()),
        // Add other providers here as needed
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'HKUST School Guide',
            theme: ThemeService.getLightTheme(),
            darkTheme: ThemeService.getDarkTheme(),
            themeMode: ThemeProvider().themeMode,
            home: const AuthGate(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignUpScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/events': (context) => const EventsScreen(),
              '/map': (context) {
                // Wrap the MapScreen with error handling
                return Builder(
                  builder: (context) {
                    try {
                      return const MapScreen();
                    } catch (e) {
                      // If MapScreen crashes during creation, show fallback UI
                      print("CRITICAL ERROR - Map screen crashed: $e");
                      return Scaffold(
                        appBar: AppBar(
                          title: const Text('Campus Map (Error)'),
                        ),
                        body: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              const Text(
                                'Map failed to load',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  'Error: $e',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Go Back'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
              '/settings': (context) => const SettingsScreen(),
              '/facilities': (context) => const FacilitiesScreen(),
              '/venues': (context) => const FoodVenuesScreen(),
              '/accessibility': (context) => const AccessibilityScreen(),
              '/camera': (context) => const CameraScreen(),
            },
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ko'),
            ],
            locale: Locale(settingsProvider.language),
          );
        },
      ),
    ),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading spinner until auth state is determined
        if (!authProvider.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Redirect based on authentication state
        if (authProvider.isAuthenticated) {
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
