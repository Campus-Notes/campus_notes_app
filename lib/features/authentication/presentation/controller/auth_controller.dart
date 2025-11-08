import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Simulate login process
      await Future.delayed(const Duration(seconds: 2));
      
      // Simple validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }
      
      if (!email.contains('@')) {
        throw Exception('Please enter a valid email');
      }
      
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }
      
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> register(String email, String password, String confirmPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Simulate registration process
      await Future.delayed(const Duration(seconds: 2));
      
      // Simple validation
      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        throw Exception('All fields are required');
      }
      
      if (!email.contains('@')) {
        throw Exception('Please enter a valid email');
      }
      
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }
      
      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }
      
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void logout() {
    _isLoggedIn = false;
    _error = null;
    notifyListeners();
  }
}