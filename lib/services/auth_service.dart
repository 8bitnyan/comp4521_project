import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart' as model;

class AuthService {
  final _supabase = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  model.User? _userFromSupabase(AuthResponse response) {
    final supaUser = response.user;
    if (supaUser == null) return null;

    return model.User(
      id: supaUser.id,
      email: supaUser.email ?? '',
      name: supaUser.userMetadata?['name'] as String? ?? '',
    );
  }

  Future<model.User?> getCurrentUser() async {
    final supaUser = _supabase.auth.currentUser;
    if (supaUser == null) return null;

    return model.User(
      id: supaUser.id,
      email: supaUser.email ?? '',
      name: supaUser.userMetadata?['name'] as String? ?? '',
    );
  }

  Future<model.User?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return _userFromSupabase(response);
    } on AuthException catch (_) {
      // Pass the error up to be handled by the provider
      rethrow;
    }
  }

  Future<model.User?> signUp(String email, String password, String name) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      return _userFromSupabase(response);
    } on AuthException catch (_) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> updateUserProfile(String name) async {
    await _supabase.auth.updateUser(UserAttributes(data: {'name': name}));
  }
}
