import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';

/// Service to handle app security features like screenshot prevention
class SecurityService {
  static Future<void> disableScreenshots() async {
    try {
      if (Platform.isAndroid) {
        // For Android: Prevent screenshots and screen recording
        await ScreenProtector.protectDataLeakageOn();
        debugPrint('🔒 Screenshot protection enabled for Android');
      } else if (Platform.isIOS) {
        // For iOS: Prevent screenshots (shows blur when screenshot is taken)
        await ScreenProtector.protectDataLeakageOn();
        debugPrint('🔒 Screenshot protection enabled for iOS');
      }
    } catch (e) {
      debugPrint('⚠️ Error enabling screenshot protection: $e');
    }
  }

  static Future<void> enableScreenshots() async {
    try {
      // Remove screenshot protection (useful for development/debugging)
      await ScreenProtector.protectDataLeakageOff();
      debugPrint('🔓 Screenshot protection disabled');
    } catch (e) {
      debugPrint('⚠️ Error disabling screenshot protection: $e');
    }
  }
  
  /// Prevent screen recording (Android only, iOS has no API for this)
  static Future<void> preventScreenRecording() async {
    try {
      if (Platform.isAndroid) {
        await ScreenProtector.preventScreenshotOn();
        debugPrint('� Screen recording protection enabled for Android');
      }
    } catch (e) {
      debugPrint('⚠️ Error preventing screen recording: $e');
    }
  }
}

