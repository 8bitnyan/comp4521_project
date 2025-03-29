import 'dart:async';
import '../models/user_model.dart';

class AuthService {
  // This is a simple mock implementation. In a real app, you would connect to a backend service.
  Future<User?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock validation - in a real app, you would validate against a backend
    if (email == 'test@example.com' && password == 'password') {
      return User(
        id: '1',
        email: email,
        name: 'Test User',
      );
    }

    return null; // Return null if authentication fails
  }

  Future<void> logout() async {
    // In a real app, you would clear tokens, notify backend, etc.
    await Future.delayed(const Duration(milliseconds: 500));
    return;
  }
}
