import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mock_data.dart';

/// Main function to run the mock data generator script
void main() async {
  try {
    // Initialize Flutter bindings
    WidgetsFlutterBinding.ensureInitialized();

    print('-' * 50);
    print('Starting mock data generator');
    print('-' * 50);

    // Initialize Supabase (same as in your main app)
    print('Initializing Supabase connection...');
    await Supabase.initialize(
      url: 'https://byhgngvrdzhhzedeqdsb.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ5aGduZ3ZyZHpoaHplZGVxZHNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU0MjAyNzAsImV4cCI6MjA2MDk5NjI3MH0.0LBPDXe-Wesm04EerxEZ88lLP8PUbM-KdMdFxNhyLa0',
    );
    print('Supabase initialized successfully!');

    // Create generator
    final generator = MockDataGenerator();

    // First check database access
    print('Checking database access...');
    final accessCheck = await generator.checkDatabaseAccess();
    print('Database access check results:');
    accessCheck.forEach((table, hasAccess) {
      print('  - $table: ${hasAccess ? 'Yes ✅' : 'No ❌'}');
    });

    if (accessCheck.values.any((canAccess) => !canAccess)) {
      print('ERROR: Cannot access one or more required tables.');
      print(
          'Please make sure all tables exist and you have proper permissions.');
      return;
    }

    // Insert the mock data
    print('-' * 50);
    print('Inserting mock data...');
    final results = await generator.insertAllMockData();

    // Print results
    print('-' * 50);
    print('Mock data insertion results:');
    results.forEach((dataType, success) {
      print('  - $dataType: ${success ? 'Success ✅' : 'Failed ❌'}');
    });

    final overall = results.values.every((success) => success);
    print('-' * 50);
    print('Final result: ${overall ? 'SUCCESS ✅' : 'FAILED ❌'}');
    print('-' * 50);
  } catch (e) {
    print('FATAL ERROR: $e');
  }
}
