import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get usersCollection => _db.collection('users');

  Future<bool> createUserDocument(UserModel user) async {
    try {
      await usersCollection.doc(user.uid).set(user.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String mobile,
    required String university,
  }) async {
    try {
      await usersCollection.doc(uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'mobile': mobile,
        'university': university,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateBankDetails({
    required String uid,
    String? upiId,
    String? bankAccountNumber,
    String? ifscCode,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      
      if (upiId != null) {
        updates['upiId'] = upiId;
        updates['isUPIProvided'] = upiId.isNotEmpty;
      }
      
      if (bankAccountNumber != null && ifscCode != null) {
        updates['bankAccountNumber'] = bankAccountNumber;
        updates['ifscCode'] = ifscCode;
        updates['isBankDetailsProvided'] = bankAccountNumber.isNotEmpty && ifscCode.isNotEmpty;
      }
      
      if (updates.isNotEmpty) {
        await usersCollection.doc(uid).update(updates);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateWalletAndPoints({
    required String uid,
    double? walletBalance,
    int? points,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      
      if (walletBalance != null) {
        updates['walletBalance'] = walletBalance;
      }
      
      if (points != null) {
        updates['points'] = points;
      }
      
      if (updates.isNotEmpty) {
        await usersCollection.doc(uid).update(updates);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
