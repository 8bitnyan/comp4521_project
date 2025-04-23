import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart' as model;
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  StreamSubscription? _authSubscription;

  model.User? _user;
  bool _isLoading = false;
  String _error = '';
  bool _isInitialized = false;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check for existing session
      _user = await _authService.getCurrentUser();

      // Listen for auth state changes
      _authSubscription = _authService.authStateChanges.listen((event) {
        if (event.event == AuthChangeEvent.signedIn) {
          _handleSignedIn(event.session);
        } else if (event.event == AuthChangeEvent.signedOut) {
          _user = null;
          notifyListeners();
        }
      });
    } catch (e) {
      _error = 'Failed to initialize auth: ${e.toString()}';
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  void _handleSignedIn(Session? session) async {
    if (session != null) {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    }
  }

  // Getters
  model.User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isInitialized => _isInitialized;

  // Login method
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Signup method
  Future<bool> signUp(String email, String password, String name) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final user = await _authService.signUp(email, password, name);

      // For email confirmation flow, user might be null initially
      if (user != null) {
        _user = user;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to send reset instructions: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
