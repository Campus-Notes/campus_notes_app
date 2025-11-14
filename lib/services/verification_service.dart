import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';

class VerificationService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService;

  static const String _notesCollection = 'notes';

  final Set<String> _notifiedNoteIds = {};

  String? _listeningUserId;

  final Map<String, bool> _previousVerificationState = {};
  final Map<String, bool> _previousCopyrightState = {};

  VerificationService({required NotificationService notificationService})
      : _notificationService = notificationService;

  void listenToUserNoteVerifications(String userId) {
    if (_listeningUserId == userId) {
      debugPrint('✅ Already listening to verifications for user: $userId');
      return;
    }

    _listeningUserId = userId;
    debugPrint('🔍 Setting up verification listener for user: $userId');

    bool isFirstSnapshot = true;

    _firestore
        .collection(_notesCollection)
        .where('ownerUid', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final noteData = doc.data();
        final isVerified = noteData['isVerified'] ?? false;
        final isCopyrighted = noteData['isCopyrighted'] ?? false;
        final copyrightReason = noteData['copyrightReason'] as String?;
        final noteTitle = noteData['title'] ?? 'Your note';
        final noteId = doc.id;

        if (isFirstSnapshot) {
          _previousVerificationState[noteId] = isVerified;
          _previousCopyrightState[noteId] = isCopyrighted;
          debugPrint(
              '📝 Initializing verification state for "$noteTitle": $isVerified');
          debugPrint(
              '📝 Initializing copyright state for "$noteTitle": $isCopyrighted');
          continue;
        }

        final wasVerified = _previousVerificationState[noteId] ?? false;
        final wasCopyrighted = _previousCopyrightState[noteId] ?? false;

        if (isVerified && !wasVerified && !_notifiedNoteIds.contains(noteId)) {
          _notifiedNoteIds.add(noteId);
          debugPrint(
              '✅ Note "$noteTitle" (ID: $noteId) has been NEWLY verified!');
          _sendVerificationNotification(noteTitle);
        }

        if (isCopyrighted && !wasCopyrighted) {
          debugPrint(
              '⚠️ Note "$noteTitle" (ID: $noteId) has been marked as COPYRIGHTED!');
          _sendCopyrightNotification(noteTitle, copyrightReason);
        }

        _previousVerificationState[noteId] = isVerified;
        _previousCopyrightState[noteId] = isCopyrighted;
      }

      if (isFirstSnapshot) {
        isFirstSnapshot = false;
        debugPrint('✅ First snapshot processed - initialization complete');
      }
    });
  }

  Future<void> _sendVerificationNotification(String noteTitle) async {
    try {
      await _notificationService.sendVerificationNotification(
        title: '📚 Note Verified!',
        body: '"$noteTitle" has been verified and is now live on Campus Notes+',
      );
      debugPrint('✅ Verification notification sent for: $noteTitle');
    } catch (e) {
      debugPrint('❌ Error sending verification notification: $e');
    }
  }

  Future<void> _sendCopyrightNotification(
    String noteTitle,
    String? copyrightReason,
  ) async {
    try {
      await _notificationService.sendCopyrightNotification(
        noteTitle: noteTitle,
        copyrightReason: copyrightReason,
      );
      debugPrint('⚠️ Copyright notification sent for: $noteTitle');
    } catch (e) {
      debugPrint('❌ Error sending copyright notification: $e');
    }
  }

  Future<void> testVerificationNotification() async {
    await _notificationService.sendVerificationNotification(
      title: '📚 Test: Note Verified!',
      body: 'This is a test notification for note verification',
    );
  }
}
