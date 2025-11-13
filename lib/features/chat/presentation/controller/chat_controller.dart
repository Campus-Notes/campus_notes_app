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
  
  /// Get current user ID from Firebase Auth
  String? get currentUserId => _auth.currentUser?.uid;
  
  /// Get current user email
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
      
      // Create message d
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
      
      // Update chat metadata 
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
  
  /// Get messages for a specific chat thread
  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  
  /// Create or get existing chat between two users
  Future<String?> createOrGetChat(String otherUserId) async {
    try {
      _setLoading(true);
      _error = null;
      
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');
      
      // Create a consistent chat ID based on user IDs
      final chatId = _generateChatId(userId, otherUserId);
      
      // Check if chat exists
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
  
  /// Mark messages as read in a chat
  Future<void> markMessagesAsRead(String chatId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return;
      
      // Get all unread messages
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      // Update all unread messages
      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      
      // Reset unread count 
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$userId': 0,
      });
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }
  
  /// Toggle pin status for a chat
  /// Pinned chats appear at the top of the chat list
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
  
  /// Mute notifications for a chat
  /// User will no longer receive notifications for this chat
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
  
  /// Unmute notifications for a chat
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
  
  /// Archive a chat
  /// Archived chats are hidden from main chat list
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
  
  /// Unarchive a chat
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
  
  /// Delete a chat thread and all its messages
  /// 
  /// Warning: This permanently deletes all messages in the chat
  Future<void> deleteChat(String chatId) async {
    try {
      _setLoading(true);
      _error = null;
      
      // Get all messages in the chat
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();
      
      // Delete all messages in a batch operation
      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete the chat document itself
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
  
  /// Generate consistent chat ID from two user IDs
  /// Always returns same ID regardless of order
  /// Example: user1_user2 (sorted alphabetically)
  String _generateChatId(String userId1, String userId2) {
    // Sort IDs to ensure consistency regardless of who initiates
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }
  
  /// Get user data from Firestore users collection
  /// 
  /// Returns user data map or null if not found
  /// Useful for displaying user names, profile pictures, etc.
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }
  
  /// Search users by name
  /// 
  /// Note: For better performance, consider using Algolia or similar
  /// This is a simple implementation for small user bases
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) return [];
      
      final queryLower = query.toLowerCase();
      
      // Search by firstName (simple startsWith query)
      final snapshot = await _firestore
          .collection('users')
          .where('firstName', isGreaterThanOrEqualTo: queryLower)
          .where('firstName', isLessThanOrEqualTo: '$queryLower\uf8ff')
          .limit(20)
          .get();
      
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .where((user) => user['id'] != currentUserId) // Exclude current user
          .toList();
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }
  
  /// Get unread message count for current user
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
  
  /// Helper method to set loading state and notify listeners
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  /// Clear any error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }
}