import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseModel {
  final String purchaseId;
  final String uid;
  final String name;
  final DateTime purchasedAt;

  PurchaseModel({
    required this.purchaseId,
    required this.uid,
    required this.name,
    required this.purchasedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'purchaseId': purchaseId,
      'uid': uid,
      'name': name,
      'purchasedAt': Timestamp.fromDate(purchasedAt),
    };
  }

  factory PurchaseModel.fromMap(Map<String, dynamic> map, String docId) {
    return PurchaseModel(
      purchaseId: map['purchaseId'] ?? docId,
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      purchasedAt: (map['purchasedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory PurchaseModel.fromSnapshot(DocumentSnapshot snapshot) {
    return PurchaseModel.fromMap(
      snapshot.data() as Map<String, dynamic>,
      snapshot.id,
    );
  }

  @override
  String toString() {
    return 'PurchaseModel(purchaseId: $purchaseId, uid: $uid, name: $name, purchasedAt: $purchasedAt)';
  }
}