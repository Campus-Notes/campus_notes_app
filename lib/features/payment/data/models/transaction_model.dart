import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String transactionId;
  final String buyerId;
  final String sellerId;
  final String noteId;
  final double salePrice;
  final double sellerAmount;
  final double sellerPoints;
  final double buyerPoints;
  final DateTime transactionDate;
  final String status;
  final String? paymentMethod;
  final String? paymentId;
  final String? razorpayOrderId;

  TransactionModel({
    required this.transactionId,
    required this.buyerId,
    required this.sellerId,
    required this.noteId,
    required this.salePrice,
    required this.sellerAmount,
    required this.sellerPoints,
    required this.buyerPoints,
    required this.transactionDate,
    this.status = 'pending',
    this.paymentMethod,
    this.paymentId,
    this.razorpayOrderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'noteId': noteId,
      'salePrice': salePrice,
      'sellerAmount': sellerAmount,
      'sellerPoints': sellerPoints,
      'buyerPoints': buyerPoints,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'razorpayOrderId': razorpayOrderId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String docId) {
    return TransactionModel(
      transactionId: map['transactionId'] ?? docId,
      buyerId: map['buyerId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      noteId: map['noteId'] ?? '',
      salePrice: (map['salePrice'] as num?)?.toDouble() ?? 0.0,
      sellerAmount: (map['sellerAmount'] as num?)?.toDouble() ?? 0.0,
      sellerPoints: (map['sellerPoints'] as num?)?.toDouble() ?? 0.0,
      buyerPoints: (map['buyerPoints'] as num?)?.toDouble() ?? 0.0,
      transactionDate:
          (map['transactionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'pending',
      paymentMethod: map['paymentMethod'],
      paymentId: map['paymentId'],
      razorpayOrderId: map['razorpayOrderId'],
    );
  }

  factory TransactionModel.fromSnapshot(DocumentSnapshot snapshot) {
    return TransactionModel.fromMap(
      snapshot.data() as Map<String, dynamic>,
      snapshot.id,
    );
  }

  TransactionModel copyWith({
    String? status,
    String? paymentMethod,
    String? paymentId,
    String? razorpayOrderId,
  }) {
    return TransactionModel(
      transactionId: transactionId,
      buyerId: buyerId,
      sellerId: sellerId,
      noteId: noteId,
      salePrice: salePrice,
      sellerAmount: sellerAmount,
      sellerPoints: sellerPoints,
      buyerPoints: buyerPoints,
      transactionDate: transactionDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(transactionId: $transactionId, buyerId: $buyerId, sellerId: $sellerId, '
        'noteId: $noteId, salePrice: $salePrice, status: $status)';
  }
}
