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
}
