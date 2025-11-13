import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';

class SecurityService {
  static Future<void> disableScreenshots() async {
    try {
      if (Platform.isAndroid) {
        await ScreenProtector.protectDataLeakageOn();
        debugPrint('🔒 Screenshot protection enabled for Android');
      } else if (Platform.isIOS) {
        await ScreenProtector.protectDataLeakageOn();
        debugPrint('🔒 Screenshot protection enabled for iOS');
      }
    } catch (e) {
      debugPrint('⚠️ Error enabling screenshot protection: $e');
    }
  }

  static Future<void> enableScreenshots() async {
    try {
      await ScreenProtector.protectDataLeakageOff();
      debugPrint('🔓 Screenshot protection disabled');
    } catch (e) {
      debugPrint('⚠️ Error disabling screenshot protection: $e');
    }
  }

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
