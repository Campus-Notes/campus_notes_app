import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../models/user_credit_models.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _transactionsCollection = 'transactions';
  static const String _userPurchasesSubcollection = 'purchased_notes';
  static const String _walletCreditsSubcollection = 'wallet_credits';
  static const String _pointsCreditsSubcollection = 'points_credits';

  /// Check if a user has purchased a specific note
  Future<bool> hasUserPurchased(String userId, String noteId) async {
    try {
      if (userId.isEmpty || noteId.isEmpty) {
        return false;
      }

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_userPurchasesSubcollection)
          .doc(noteId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get list of note IDs purchased by a user
  Future<List<String>> getUserPurchasedNoteIds(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_userPurchasesSubcollection)
          .get();

      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get user's current wallet balance
  Future<double> getWalletBalance(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return (data['walletBalance'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Get user's total earnings (lifetime earnings)
  Future<double> getTotalEarnings(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return (data['totalEarnings'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Get user's points balance
  Future<int> getPointsBalance(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return (data['points'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get user's wallet transaction history
  Future<List<WalletCreditModel>> getWalletHistory({
    required String userId,
    int? limit,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection(_walletCreditsSubcollection)
          .orderBy('creditedAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => WalletCreditModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get user's points transaction history
  Future<List<PointsCreditModel>> getPointsHistory({
    required String userId,
    int? limit,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection(_pointsCreditsSubcollection)
          .orderBy('creditedAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => PointsCreditModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get user's purchase history with details
  Future<List<Map<String, dynamic>>> getPurchaseHistory({
    required String userId,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection(_userPurchasesSubcollection)
          .orderBy('purchasedAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'noteId': doc.id,
          'purchasedAt': data['purchasedAt'],
          'transactionId': data['transactionId'],
          'price': data['price'],
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get user's transaction history (both buying and selling)
  Future<List<TransactionModel>> getTransactionHistory({
    required String userId,
    String? type, // 'buyer', 'seller', or null for both
    int? limit,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(_transactionsCollection)
          .where('status', isEqualTo: 'completed');

      // Filter by user role
      if (type == 'buyer') {
        query = query.where('buyerId', isEqualTo: userId);
      } else if (type == 'seller') {
        query = query.where('sellerId', isEqualTo: userId);
      } else {
        // Get both - need to do separate queries and merge
        final buyerQuery = _firestore
            .collection(_transactionsCollection)
            .where('status', isEqualTo: 'completed')
            .where('buyerId', isEqualTo: userId)
            .orderBy('transactionDate', descending: true);

        final sellerQuery = _firestore
            .collection(_transactionsCollection)
            .where('status', isEqualTo: 'completed')
            .where('sellerId', isEqualTo: userId)
            .orderBy('transactionDate', descending: true);

        if (limit != null) {
          final buyerDocs = await buyerQuery.limit(limit ~/ 2).get();
          final sellerDocs = await sellerQuery.limit(limit ~/ 2).get();
          
          final allDocs = [...buyerDocs.docs, ...sellerDocs.docs];
          allDocs.sort((a, b) {
            final aData = a.data();
            final bData = b.data();
            final aDate = aData['transactionDate'] as Timestamp;
            final bDate = bData['transactionDate'] as Timestamp;
            return bDate.compareTo(aDate);
          });

          return allDocs
              .take(limit)
              .map((doc) => TransactionModel.fromSnapshot(doc))
              .toList();
        } else {
          final buyerDocs = await buyerQuery.get();
          final sellerDocs = await sellerQuery.get();
          
          final allDocs = [...buyerDocs.docs, ...sellerDocs.docs];
          allDocs.sort((a, b) {
            final aData = a.data();
            final bData = b.data();
            final aDate = aData['transactionDate'] as Timestamp;
            final bDate = bData['transactionDate'] as Timestamp;
            return bDate.compareTo(aDate);
          });

          return allDocs
              .map((doc) => TransactionModel.fromSnapshot(doc))
              .toList();
        }
      }

      query = query.orderBy('transactionDate', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => TransactionModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Handle wallet withdrawal - decreases walletBalance but maintains totalEarnings
  Future<bool> processWithdrawal({
    required String userId,
    required double amount,
    required String withdrawalMethod,
    String? withdrawalDetails,
  }) async {
    try {
      if (amount <= 0) {
        throw Exception('Withdrawal amount must be positive');
      }

      final userDoc = _firestore.collection('users').doc(userId);
      
      // Check current wallet balance
      final userData = await userDoc.get();
      if (!userData.exists) {
        throw Exception('User not found');
      }

      final currentBalance = (userData.data() as Map<String, dynamic>)['walletBalance'] ?? 0.0;
      if (currentBalance < amount) {
        throw Exception('Insufficient wallet balance');
      }

      final batch = _firestore.batch();
      
      // Update user wallet balance (decrease)
      batch.update(userDoc, {
        'walletBalance': FieldValue.increment(-amount),
        // Note: totalEarnings remains unchanged
      });

      // Create withdrawal record
      final withdrawalId = _firestore
          .collection('users')
          .doc(userId)
          .collection(_walletCreditsSubcollection)
          .doc()
          .id;

      final withdrawalCredit = WalletCreditModel(
        creditId: withdrawalId,
        userId: userId,
        noteId: '', // No note associated with withdrawal
        transactionId: '', // No transaction associated with withdrawal
        amount: -amount,
        type: 'withdrawal',
        creditedAt: DateTime.now(),
        description: 'Wallet withdrawal via $withdrawalMethod${withdrawalDetails != null ? ' - $withdrawalDetails' : ''}',
        status: 'completed',
      );

      batch.set(
        _firestore
            .collection('users')
            .doc(userId)
            .collection(_walletCreditsSubcollection)
            .doc(withdrawalId),
        withdrawalCredit.toMap(),
      );

      await batch.commit();
      return true;

    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getWalletSummary(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      double walletBalance = 0.0;
      double totalEarnings = 0.0;
      int points = 0;

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        walletBalance = (data['walletBalance'] as num?)?.toDouble() ?? 0.0;
        totalEarnings = (data['totalEarnings'] as num?)?.toDouble() ?? 0.0;
        points = (data['points'] as num?)?.toInt() ?? 0;
      }

      return {
        'walletBalance': walletBalance,
        'totalEarnings': totalEarnings,
        'points': points,
        'totalWithdrawn': totalEarnings - walletBalance,
      };
    } catch (e) {
      return {
        'walletBalance': 0.0,
        'totalEarnings': 0.0,
        'points': 0,
        'totalWithdrawn': 0.0,
      };
    }
  }
}