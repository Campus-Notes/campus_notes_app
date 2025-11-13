import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../models/user_credit_models.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _transactionsCollection = 'transactions';
  static const String _userPurchasesSubcollection = 'purchased_notes';
  static const String _walletCreditsSubcollection = 'wallet_credits';
  static const String _pointsCreditsSubcollection = 'points_credits';

  Map<String, double> calculateTransactionAmounts(double price) {
    return {
      'sellerAmount': price * 0.80,
      'sellerPoints': price * 0.05,
      'buyerPoints': price * 0.02,
    };
  }

  Future<TransactionModel> createTransaction({
    required String buyerId,
    required String sellerId,
    required String noteId,
    required double salePrice,
    String? paymentMethod,
    String? razorpayOrderId,
  }) async {
    try {
      if (buyerId.isEmpty) throw Exception('Buyer ID cannot be empty');
      if (sellerId.isEmpty) throw Exception('Seller ID cannot be empty');
      if (noteId.isEmpty) throw Exception('Note ID cannot be empty');
      if (salePrice < 0) throw Exception('Sale price cannot be negative');

      const uuid = Uuid();
      final transactionId = uuid.v4();
      final amounts = calculateTransactionAmounts(salePrice);

      final transaction = TransactionModel(
        transactionId: transactionId,
        buyerId: buyerId,
        sellerId: sellerId,
        noteId: noteId,
        salePrice: salePrice,
        sellerAmount: amounts['sellerAmount']!,
        sellerPoints: amounts['sellerPoints']!,
        buyerPoints: amounts['buyerPoints']!,
        transactionDate: DateTime.now(),
        status: 'pending',
        paymentMethod: paymentMethod ?? 'razorpay',
        razorpayOrderId: razorpayOrderId,
      );

      await _firestore
          .collection(_transactionsCollection)
          .doc(transactionId)
          .set(transaction.toMap());

      return transaction;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> completeTransaction({
    required String transactionId,
    required String paymentId,
  }) async {
    try {
      final transactionDoc = await _firestore
          .collection(_transactionsCollection)
          .doc(transactionId)
          .get();

      if (!transactionDoc.exists) {
        throw Exception('Transaction not found');
      }

      final transaction = TransactionModel.fromSnapshot(transactionDoc);

      final batch = _firestore.batch();

      batch.update(
        _firestore.collection(_transactionsCollection).doc(transactionId),
        {
          'status': 'completed',
          'paymentId': paymentId,
        },
      );

      final sellerDoc =
          _firestore.collection('users').doc(transaction.sellerId);
      batch.update(sellerDoc, {
        'walletBalance': FieldValue.increment(transaction.sellerAmount),
        'totalEarnings': FieldValue.increment(transaction.sellerAmount),
        'points': FieldValue.increment(transaction.sellerPoints),
      });

      final sellerWalletCredit = WalletCreditModel(
        creditId: '${transaction.transactionId}_seller_wallet',
        userId: transaction.sellerId,
        noteId: transaction.noteId,
        transactionId: transaction.transactionId,
        amount: transaction.sellerAmount,
        type: 'earning',
        creditedAt: DateTime.now(),
        description: 'Sale earning from note purchase',
      );

      batch.set(
        _firestore
            .collection('users')
            .doc(transaction.sellerId)
            .collection(_walletCreditsSubcollection)
            .doc(sellerWalletCredit.creditId),
        sellerWalletCredit.toMap(),
      );

      final sellerPointsCredit = PointsCreditModel(
        creditId: '${transaction.transactionId}_seller_points',
        userId: transaction.sellerId,
        noteId: transaction.noteId,
        transactionId: transaction.transactionId,
        points: transaction.sellerPoints,
        type: 'selling_bonus',
        creditedAt: DateTime.now(),
        description: 'Selling bonus points',
      );

      batch.set(
        _firestore
            .collection('users')
            .doc(transaction.sellerId)
            .collection(_pointsCreditsSubcollection)
            .doc(sellerPointsCredit.creditId),
        sellerPointsCredit.toMap(),
      );

      final buyerDoc = _firestore.collection('users').doc(transaction.buyerId);
      batch.update(buyerDoc, {
        'points': FieldValue.increment(transaction.buyerPoints),
      });

      final buyerPointsCredit = PointsCreditModel(
        creditId: '${transaction.transactionId}_buyer_points',
        userId: transaction.buyerId,
        noteId: transaction.noteId,
        transactionId: transaction.transactionId,
        points: transaction.buyerPoints,
        type: 'purchase_bonus',
        creditedAt: DateTime.now(),
        description: 'Purchase bonus points',
      );

      batch.set(
        _firestore
            .collection('users')
            .doc(transaction.buyerId)
            .collection(_pointsCreditsSubcollection)
            .doc(buyerPointsCredit.creditId),
        buyerPointsCredit.toMap(),
      );

      final purchaseRecord = {
        'noteId': transaction.noteId,
        'purchasedAt': Timestamp.now(),
        'transactionId': transactionId,
        'price': transaction.salePrice,
      };

      batch.set(
        _firestore
            .collection('users')
            .doc(transaction.buyerId)
            .collection(_userPurchasesSubcollection)
            .doc(transaction.noteId),
        purchaseRecord,
      );

      final noteDoc = _firestore.collection('notes').doc(transaction.noteId);
      final noteData = await noteDoc.get();

      if (noteData.exists) {
        batch.update(noteDoc, {
          'purchaseCount': FieldValue.increment(1),
          'purchaserIds': FieldValue.arrayUnion([transaction.buyerId]),
          'earnings': FieldValue.increment(transaction.sellerAmount),
        });
      } else {}

      batch.set(
        _firestore
            .collection('notes')
            .doc(transaction.noteId)
            .collection('purchases')
            .doc(transaction.buyerId),
        {
          'uid': transaction.buyerId,
          'purchasedAt': Timestamp.now(),
          'transactionId': transactionId,
        },
      );

      await batch.commit();
      return true;
    } catch (e) {
      try {
        await _firestore
            .collection(_transactionsCollection)
            .doc(transactionId)
            .update({'status': 'failed', 'failureReason': e.toString()});
      } catch (updateError) {
        debugPrint('Error updating transaction status: $updateError');
      }

      rethrow;
    }
  }

  Future<bool> cancelTransaction(String transactionId, String reason) async {
    try {
      await _firestore
          .collection(_transactionsCollection)
          .doc(transactionId)
          .update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
