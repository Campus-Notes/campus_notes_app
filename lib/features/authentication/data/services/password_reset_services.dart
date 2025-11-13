import 'dart:convert';
import 'package:http/http.dart' as http;

class PasswordResetService {
  final String baseUrl;

  PasswordResetService({required this.baseUrl});

  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': data['message'] ?? 'Email sent'};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to send email',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyResetToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify-reset-token/$token'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Token valid'};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Invalid/expired token',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'newPassword': newPassword}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': data['message'] ?? 'Password reset'};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to reset password',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}