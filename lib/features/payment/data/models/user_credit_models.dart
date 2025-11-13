import 'package:cloud_firestore/cloud_firestore.dart';

class WalletCreditModel {
  final String creditId;
  final String userId;
  final String noteId;
  final String transactionId;
  final double amount;
  final String type;
  final DateTime creditedAt;
  final String? description;
  final String status;

  WalletCreditModel({
    required this.creditId,
    required this.userId,
    required this.noteId,
    required this.transactionId,
    required this.amount,
    required this.type,
    required this.creditedAt,
    this.description,
    this.status = 'completed',
  });

  Map<String, dynamic> toMap() {
    return {
      'creditId': creditId,
      'userId': userId,
      'noteId': noteId,
      'transactionId': transactionId,
      'amount': amount,
      'type': type,
      'creditedAt': Timestamp.fromDate(creditedAt),
      'description': description,
      'status': status,
    };
  }

  factory WalletCreditModel.fromMap(Map<String, dynamic> map, String docId) {
    return WalletCreditModel(
      creditId: map['creditId'] ?? docId,
      userId: map['userId'] ?? '',
      noteId: map['noteId'] ?? '',
      transactionId: map['transactionId'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: map['type'] ?? 'earning',
      creditedAt: (map['creditedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: map['description'],
      status: map['status'] ?? 'completed',
    );
  }

  factory WalletCreditModel.fromSnapshot(DocumentSnapshot snapshot) {
    return WalletCreditModel.fromMap(
      snapshot.data() as Map<String, dynamic>,
      snapshot.id,
    );
  }

  @override
  String toString() {
    return 'WalletCreditModel(creditId: $creditId, userId: $userId, noteId: $noteId, '
        'amount: $amount, type: $type, status: $status)';
  }
}

class PointsCreditModel {
  final String creditId;
  final String userId;
  final String noteId;
  final String transactionId;
  final double points;
  final String type;
  final DateTime creditedAt;
  final String? description;
  final String status;

  PointsCreditModel({
    required this.creditId,
    required this.userId,
    required this.noteId,
    required this.transactionId,
    required this.points,
    required this.type,
    required this.creditedAt,
    this.description,
    this.status = 'completed',
  });

  Map<String, dynamic> toMap() {
    return {
      'creditId': creditId,
      'userId': userId,
      'noteId': noteId,
      'transactionId': transactionId,
      'points': points,
      'type': type,
      'creditedAt': Timestamp.fromDate(creditedAt),
      'description': description,
      'status': status,
    };
  }

  factory PointsCreditModel.fromMap(Map<String, dynamic> map, String docId) {
    return PointsCreditModel(
      creditId: map['creditId'] ?? docId,
      userId: map['userId'] ?? '',
      noteId: map['noteId'] ?? '',
      transactionId: map['transactionId'] ?? '',
      points: (map['points'] as num?)?.toDouble() ?? 0.0,
      type: map['type'] ?? 'selling_bonus',
      creditedAt: (map['creditedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: map['description'],
      status: map['status'] ?? 'completed',
    );
  }

  factory PointsCreditModel.fromSnapshot(DocumentSnapshot snapshot) {
    return PointsCreditModel.fromMap(
      snapshot.data() as Map<String, dynamic>,
      snapshot.id,
    );
  }

  @override
  String toString() {
    return 'PointsCreditModel(creditId: $creditId, userId: $userId, noteId: $noteId, '
        'points: $points, type: $type, status: $status)';
  }
}
