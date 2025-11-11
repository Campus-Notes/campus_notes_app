import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/services/auth_services.dart';
import '../../data/models/user_model.dart';

class AuthController extends ChangeNotifier {
  // --------------------------------------------------------------
  // Services
  // --------------------------------------------------------------
  final AuthService _authService;

  // --------------------------------------------------------------
  // UI state
  // --------------------------------------------------------------
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;
  bool _justLoggedIn = false;
  bool _justRegistered = false;
  bool _justLoggedOut = false;

  // --------------------------------------------------------------
  // Getters
  // --------------------------------------------------------------
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  bool get justLoggedIn => _justLoggedIn;
  bool get justRegistered => _justRegistered;
  bool get justLoggedOut => _justLoggedOut;

  // --------------------------------------------------------------
  // Constructor – inject services
  // --------------------------------------------------------------
  AuthController({AuthService? authService, String? baseUrl})
      : _authService = authService ?? AuthService(baseUrl: baseUrl ?? '') {
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
      _errorMessage = null;

      notifyListeners();
    });
  }

  // --------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------
  Future<void> _checkCurrentUser() async {
    final user = _authService.currentUser;
    _isLoggedIn = user != null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (!loading) _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // --------------------------------------------------------------
  // Login / Register / Logout
  // --------------------------------------------------------------
  Future<void> login(String email, String password) async {
    _setLoading(true);
    _justLoggedIn = false;

    final result = await _authService.login(email: email, password: password);

    if (result == null) {
      _isLoggedIn = true;
      _justLoggedIn = true;
    } else {
      _errorMessage = result;
    }

    _setLoading(false);
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String university,
    required String password,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _justRegistered = false;

    if (password != confirmPassword) {
      _errorMessage = 'Passwords do not match';
      _setLoading(false);
      return;
    }

    final result = await _authService.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      mobile: mobile,
      university: university,
      password: password,
    );

    if (result == null) {
      _isLoggedIn = true;
      _justRegistered = true;
    } else {
      _errorMessage = result;
    }

    _setLoading(false);
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _justLoggedIn = false;
    _justRegistered = false;
    _justLoggedOut = true;
    notifyListeners();
  }

  // --------------------------------------------------------------
  // Password-reset (Firebase only)
  // --------------------------------------------------------------
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);

    try {
      debugPrint('Firebase: sending reset link to $email');

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.trim(),
      );

      debugPrint('Firebase: reset link sent');
      _setLoading(false);
      return true;

    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase error: ${e.code} - ${e.message}');
      _errorMessage = _mapFirebaseError(e);
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Firebase UI token always returns true
  Future<bool> verifyResetToken(String token) async => true;

  // Confirm new password
  Future<bool> resetPassword(String code, String newPassword) async {
    _setLoading(true);

    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
      _setLoading(false);
      return true;

    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e);
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // --------------------------------------------------------------
  // Profile + bank
  // --------------------------------------------------------------
  Future<UserModel?> getCurrentUser() async =>
      await _authService.getCurrentUserData();

  Future<String?> updateProfile({
    required String firstName,
    required String lastName,
    required String mobile,
    required String university,
  }) async {
    _setLoading(true);

    final result = await _authService.updateProfile(
      firstName: firstName,
      lastName: lastName,
      mobile: mobile,
      university: university,
    );

    if (result != null) _errorMessage = result;
    _setLoading(false);
    return result;
  }

  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _setLoading(true);

    final result = await _authService.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    if (result != null) _errorMessage = result;

    _setLoading(false);
    return result;
  }

  Future<String?> updateBankDetails({
    String? upiId,
    String? bankAccountNumber,
    String? ifscCode,
  }) async {
    _setLoading(true);

    final result = await _authService.updateBankDetails(
      upiId: upiId,
      bankAccountNumber: bankAccountNumber,
      ifscCode: ifscCode,
    );

    if (result != null) _errorMessage = result;

    _setLoading(false);
    return result;
  }

  // --------------------------------------------------------------
  // Error mapping
  // --------------------------------------------------------------
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
