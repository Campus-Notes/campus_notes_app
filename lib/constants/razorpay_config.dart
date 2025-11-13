import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class RazorpayConfig {
  // Razorpay Test/Live Keys
  static String get keyId {
    final key = dotenv.env['RAZORPAY_KEY_ID'] ?? '';
    if (kDebugMode) {
      debugPrint('🔑 Razorpay Key ID loaded: ${key.isNotEmpty ? "✓ (${key.substring(0, 12)}...)" : "✗ MISSING"}');
    }
    return key;
  }
  
  static String get keySecret {
    final secret = dotenv.env['RAZORPAY_KEY_SECRET'] ?? '';
    if (kDebugMode) {
      debugPrint('🔑 Razorpay Key Secret loaded: ${secret.isNotEmpty ? "✓ (hidden)" : "✗ MISSING"}');
    }
    return secret;
  }
  
  // Company/App Information
  static const String companyName = 'Campus Notes';
  static const String companyLogo = ''; // Add your logo URL here
  static const String currency = 'INR';
  
  // Payment Configuration
  static const int timeout = 300; // 5 minutes in seconds
  
  // Validate configuration
  static bool get isConfigured {
    final configured = keyId.isNotEmpty && keySecret.isNotEmpty;
    if (kDebugMode && !configured) {
      debugPrint('❌ Razorpay NOT configured properly!');
    }
    return configured;
  }
  
  // Get error message if not configured
  static String get configurationError {
    if (!isConfigured) {
      return 'Razorpay is not configured. Please add RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET to your .env file';
    }
    return '';
  }
}
