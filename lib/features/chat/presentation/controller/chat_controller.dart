import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get currentUserId => _auth.currentUser?.uid;

  String? get currentUserEmail => _auth.currentUser?.email;

  Future<void> sendMessage({
    required String chatId,
    required String message,
    String? receiverId,
  }) async {
    if (message.trim().isEmpty) return;

    try {
      _setLoading(true);
      _error = null;

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': user.uid,
        'senderEmail': user.email,
        'receiverId': receiverId,
        'message': message.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      await _firestore.collection('chats').doc(chatId).set({
        'participants': [user.uid, receiverId],
        'lastMessage': message.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': user.uid,
        'unreadCount': {
          receiverId!: FieldValue.increment(1),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      _error = e.toString();
      debugPrint('Error sending message: $e');
    } finally {
      _setLoading(false);
    }
  }

  Stream<QuerySnapshot> getUserChats() {
    final userId = currentUserId;

    if (userId == null) {
      return const Stream.empty();
    }

    final query = _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true);

    return query.snapshots();
  }

  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<String?> createOrGetChat(String otherUserId) async {
    try {
      _setLoading(true);
      _error = null;

      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final chatId = _generateChatId(userId, otherUserId);

      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        await _firestore.collection('chats').doc(chatId).set({
          'participants': [userId, otherUserId],
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessageTime': FieldValue.serverTimestamp(),
        });
      }

      return chatId;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating/getting chat: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markMessagesAsRead(String chatId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return;

      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$userId': 0,
      });
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  Future<void> togglePinChat(String chatId) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      final currentPinStatus = chatDoc.data()?['isPinned'] ?? false;

      await _firestore.collection('chats').doc(chatId).update({
        'isPinned': !currentPinStatus,
      });
    } catch (e) {
      debugPrint('Error toggling pin status: $e');
      rethrow;
    }
  }

  Future<void> muteChat(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'isMuted': true,
        'mutedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error muting chat: $e');
      rethrow;
    }
  }

  Future<void> unmuteChat(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'isMuted': false,
        'mutedAt': null,
      });
    } catch (e) {
      debugPrint('Error unmuting chat: $e');
      rethrow;
    }
  }

  Future<void> archiveChat(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'isArchived': true,
        'archivedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error archiving chat: $e');
      rethrow;
    }
  }

  Future<void> unarchiveChat(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'isArchived': false,
        'archivedAt': null,
      });
    } catch (e) {
      debugPrint('Error unarchiving chat: $e');
      rethrow;
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      _setLoading(true);
      _error = null;

      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(_firestore.collection('chats').doc(chatId));

      await batch.commit();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting chat: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  String _generateChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final queryLower = query.toLowerCase();

      final snapshot = await _firestore
          .collection('users')
          .where('firstName', isGreaterThanOrEqualTo: queryLower)
          .where('firstName', isLessThanOrEqualTo: '$queryLower\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .where((user) => user['id'] != currentUserId)
          .toList();
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  Future<int> getUnreadMessageCount() async {
    try {
      final userId = currentUserId;
      if (userId == null) return 0;

      final chats = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .get();

      int unreadCount = 0;

      for (var chat in chats.docs) {
        final messages = await chat.reference
            .collection('messages')
            .where('receiverId', isEqualTo: userId)
            .where('isRead', isEqualTo: false)
            .get();

        unreadCount += messages.docs.length;
      }

      return unreadCount;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
