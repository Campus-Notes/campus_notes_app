import 'package:flutter/material.dart';
import '../../data/services/auth_services.dart';
// features/authentication/presentation/controller/auth_controller.dart
// features/authentication/presentation/controller/auth_controller.dart

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  bool _justLoggedIn = false;
  bool _justRegistered = false; // ← NEW
  bool _justLoggedOut = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get justLoggedIn => _justLoggedIn;
  bool get justRegistered => _justRegistered; 
  bool get justLoggedOut => _justLoggedOut;

  AuthController() {
    _checkCurrentUser();
    _authService.authStateChanges.listen((user) {
      final wasLoggedIn = _isLoggedIn;
      _isLoggedIn = user != null;
      
      if (wasLoggedIn && user == null) {
        _justLoggedOut = true;
      } else {
        _justLoggedOut = false;
      }
      
      _justLoggedIn = false;
      _justRegistered = false;
      _error = null;
      notifyListeners();
    });
  }

  Future<void> _checkCurrentUser() async {
    final user = _authService.currentUser;
    _isLoggedIn = user != null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearLogoutState() {
    _justLoggedOut = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    _justLoggedIn = false;
    notifyListeners();

    final result = await _authService.login(email: email, password: password);
    if (result == null) {
      _isLoggedIn = true;
      _justLoggedIn = true;
    } else {
      _error = result;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(String name, String email, String password, String confirmPassword) async {
    _isLoading = true;
    _error = null;
    _justRegistered = false; 
    notifyListeners();

    if (password != confirmPassword) {
      _error = 'Passwords do not match';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final result = await _authService.register(name: name, email: email, password: password);
    if (result == null) {
      _isLoggedIn = true;
      _justRegistered = true; 
    } else {
      _error = result;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _justLoggedIn = false;
    _justRegistered = false;
    _justLoggedOut = true;
    notifyListeners();
  }
}