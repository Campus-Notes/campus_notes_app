import 'package:firebase_auth/firebase_auth.dart';
import 'database_services.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = result.user;
      if (user == null) return 'Failed to create account';

      final newUser = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        createdAt: DateTime.now(),
      );

      final saved = await _dbService.createUserDocument(newUser);
      if (!saved) {
        await user.delete();
        return 'Failed to save profile';
      }

      await user.updateDisplayName(name.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'Password too weak';
        case 'email-already-in-use':
          return 'Email already registered';
        case 'invalid-email':
          return 'Invalid email';
        default:
          return e.message ?? 'Registration failed';
      }
    } catch (e) {
      return 'Unexpected error';
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found';
        case 'wrong-password':
          return 'Incorrect password';
        case 'invalid-email':
          return 'Invalid email';
        default:
          return e.message ?? 'Login failed';
      }
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
