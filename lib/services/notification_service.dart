import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService extends ChangeNotifier {
  static const String _notificationsEnabledKey = 'notifications_enabled';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _notificationsEnabled = true;
  String? _fcmToken;

  bool get notificationsEnabled => _notificationsEnabled;
  String? get fcmToken => _fcmToken;

  Future<void> init() async {
    await _loadNotificationsPreference();
    await _setupLocalNotifications();
    await _setupFCM();
  }

  Future<void> _setupLocalNotifications() async {
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'verification_channel',
        'Verification Notifications',
        description: 'Notifications for note verifications',
        importance: Importance.max,
        enableLights: true,
        enableVibration: true,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      debugPrint('✅ Local notifications initialized');
    } catch (e) {
      debugPrint('Error setting up local notifications: $e');
    }
  }

  Future<void> _setupFCM() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Notification permissions granted');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('⏳ Notification permissions granted (provisional)');
      } else {
        debugPrint('❌ Notification permissions denied');
      }

      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('📱 FCM Token: $_fcmToken');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📬 Foreground message received');
        debugPrint('Title: ${message.notification?.title}');
        debugPrint('Body: ${message.notification?.body}');

        if (message.notification != null) {
          _showLocalNotification(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            title: message.notification!.title ?? 'Notification',
            body: message.notification!.body ?? '',
            payload: message.data['payload'] ?? '',
          );
        }

        _handleMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('📩 Message opened from background');
        _handleMessage(message);
      });

      RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('📨 Message from terminated state');
        _handleMessage(initialMessage);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting up FCM: $e');
    }
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint('Handling message: ${message.messageId}');
  }

  Future<void> sendVerificationNotification({
    required String title,
    required String body,
  }) async {
    if (!_notificationsEnabled) {
      debugPrint('⏸️ Notifications disabled - not sending notification');
      return;
    }

    try {
      debugPrint('📤 Sending verification notification: $title - $body');

      int notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await _showLocalNotification(
        id: notificationId,
        title: title,
        body: body,
        payload: 'verification',
      );

      debugPrint('✅ Verification notification queued for delivery');
      debugPrint('   Title: $title');
      debugPrint('   Body: $body');
    } catch (e) {
      debugPrint('Error sending verification notification: $e');
    }
  }

  Future<void> sendCopyrightNotification({
    required String noteTitle,
    required String? copyrightReason,
  }) async {
    if (!_notificationsEnabled) {
      debugPrint('⏸️ Notifications disabled - not sending copyright notification');
      return;
    }

    try {
      final reason = copyrightReason ?? 'Your note contains copyrighted content';
      debugPrint('📤 Sending copyright notification for note: $noteTitle');

      int notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await _showLocalNotification(
        id: notificationId,
        title: '⚠️ Copyright Notice',
        body: '$noteTitle - $reason',
        payload: 'copyright',
      );

      debugPrint('✅ Copyright notification sent');
      debugPrint('   Note: $noteTitle');
      debugPrint('   Reason: $reason');
    } catch (e) {
      debugPrint('Error sending copyright notification: $e');
    }
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    try {
      debugPrint('🔔 Attempting to show local notification:');
      debugPrint('   ID: $id');
      debugPrint('   Title: $title');
      debugPrint('   Body: $body');

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'verification_channel',
        'Verification Notifications',
        channelDescription: 'Notifications for note verifications',
        importance: Importance.max,
        priority: Priority.high,
        enableLights: true,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      debugPrint('✅ Local notification displayed successfully');
    } catch (e) {
      debugPrint('❌ Error showing local notification: $e');
    }
  }

  Future<void> enableNotifications() async {
    if (_notificationsEnabled) return;

    _notificationsEnabled = true;
    await _saveNotificationsPreference();

    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        sound: true,
        badge: true,
      );
      debugPrint('✅ Notifications enabled');
    } catch (e) {
      debugPrint('Error enabling notifications: $e');
    }

    notifyListeners();
  }

  Future<void> disableNotifications() async {
    if (!_notificationsEnabled) return;

    _notificationsEnabled = false;
    await _saveNotificationsPreference();
    debugPrint('🔕 Notifications disabled');

    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    if (_notificationsEnabled) {
      await disableNotifications();
    } else {
      await enableNotifications();
    }
  }

  Future<void> _loadNotificationsPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notifications preference: $e');
    }
  }

  Future<void> _saveNotificationsPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, _notificationsEnabled);
    } catch (e) {
      debugPrint('Error saving notifications preference: $e');
    }
  }
}
