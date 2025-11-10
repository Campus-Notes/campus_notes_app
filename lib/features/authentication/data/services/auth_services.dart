import 'package:firebase_auth/firebase_auth.dart';
import 'database_services.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String university,
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
        firstName: firstName.trim(),
        lastName: lastName.trim().isEmpty ? '' : lastName.trim(),
        email: email.trim(),
        mobile: mobile.trim().isEmpty ? '' : mobile.trim(), 
        university: university.trim(),
        walletBalance: 0.0,
        points: 0,
        isUPIProvided: false,
        isBankDetailsProvided: false,
        createdAt: DateTime.now(),
      );

      final saved = await _dbService.createUserDocument(newUser);
      if (!saved) {
        await user.delete();
        return 'Failed to save profile';
      }

      await user.updateDisplayName('${firstName.trim()} ${lastName.trim()}');
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

  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not logged in';

      // Re-authenticate user with old password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          return 'Current password is incorrect';
        case 'weak-password':
          return 'New password is too weak';
        default:
          return e.message ?? 'Failed to change password';
      }
    } catch (e) {
      return 'Unexpected error';
    }
  }

  Future<String?> updateProfile({
    required String firstName,
    required String lastName,
    required String mobile,
    required String university,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not logged in';

      final updatedUser = await _dbService.updateUserProfile(
        uid: user.uid,
        firstName: firstName,
        lastName: lastName,
        mobile: mobile,
        university: university,
      );

      if (!updatedUser) return 'Failed to update profile';

      // Update display name in Firebase Auth
      await user.updateDisplayName('$firstName $lastName');
      return null;
    } catch (e) {
      return 'Failed to update profile';
    }
  }

  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      return await _dbService.getUserData(user.uid);
    } catch (e) {
      return null;
    }
  }

  Future<String?> updateBankDetails({
    String? upiId,
    String? bankAccountNumber,
    String? ifscCode,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not logged in';

      final updated = await _dbService.updateBankDetails(
        uid: user.uid,
        upiId: upiId,
        bankAccountNumber: bankAccountNumber,
        ifscCode: ifscCode,
      );

      if (!updated) return 'Failed to update bank details';
      return null;
    } catch (e) {
      return 'Failed to update bank details';
    }
  }
}
