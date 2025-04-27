import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/map_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/camera_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'School Guide App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: themeProvider.themeMode,
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/map': (context) => const MapScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/camera': (context) => const CameraScreen(),
          },
        );
      },
    );
  }
}
