import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';
import '../models/purchase_model.dart';

class NoteDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _notesCollection = 'notes';
  static const String _purchasesSubcollection = 'purchases';
  
  Future<NoteModel> uploadNote({
    required String title,
    required String subject,
    String? description,
    required String ownerUid,
    required bool isDonation,
    double? price,
    required String fileName,
    required String fileEncodedData,
    int pageCount = 0,
  }) async {
    try {
      const uuid = Uuid();
      final noteId = uuid.v4();
      final now = DateTime.now();

      final noteModel = NoteModel(
        noteId: noteId,
        title: title,
        subject: subject,
        description: description,
        ownerUid: ownerUid,
        isDonation: isDonation,
        price: isDonation ? null : price,
        rating: 0.0,
        fileName: fileName,
        fileEncodedData: fileEncodedData,
        createdAt: now,
        updatedAt: now,
        viewCount: 0,
        purchaseCount: 0,
        isVerified: false, 
        pageCount: pageCount,
      );

      // Store in Firestore
      await _firestore
          .collection(_notesCollection)
          .doc(noteId)
          .set(noteModel.toMap());

      return noteModel;
    } catch (e) {
      rethrow;
    }
  }

  Future<NoteModel?> getNoteById(String noteId) async {
    try {
      final doc = await _firestore
          .collection(_notesCollection)
          .doc(noteId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return NoteModel.fromSnapshot(doc);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NoteModel>> getUserNotes(
    String ownerUid, {
    int limit = 10,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_notesCollection)
          .where('ownerUid', isEqualTo: ownerUid)
          .get();

      final notes = querySnapshot.docs
          .map((doc) => NoteModel.fromSnapshot(doc))
          .toList();
      
      // Sort by createdAt in memory, then take the limit
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notes.take(limit).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NoteModel>> searchNotes(
    String query, {
    int limit = 20,
  }) async {
    try {
      final lowerQuery = query.toLowerCase();

      final querySnapshot = await _firestore
          .collection(_notesCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .where((doc) {
            final data = doc.data();
            final title = (data['title'] ?? '').toString().toLowerCase();
            final subject = (data['subject'] ?? '').toString().toLowerCase();
            final description = (data['description'] ?? '').toString().toLowerCase();

            return title.contains(lowerQuery) ||
                subject.contains(lowerQuery) ||
                description.contains(lowerQuery);
          })
          .map((doc) => NoteModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NoteModel>> getDonationNotes({int limit = 20}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_notesCollection)
          .where('isDonation', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => NoteModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<NoteModel> updateNote(NoteModel note) async {
    try {
      final updateData = {
        'title': note.title,
        'subject': note.subject,
        'description': note.description,
        'updatedAt': Timestamp.now(),
      };

      await _firestore
          .collection(_notesCollection)
          .doc(note.noteId)
          .update(updateData);

      return note.copyWith();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> incrementViewCount(String noteId) async {
    try {
      await _firestore.collection(_notesCollection).doc(noteId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> incrementPurchaseCount(String noteId) async {
    try {
      await _firestore.collection(_notesCollection).doc(noteId).update({
        'purchaseCount': FieldValue.increment(1),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRating(String noteId, double newRating) async {
    try {
      await _firestore
          .collection(_notesCollection)
          .doc(noteId)
          .update({'rating': newRating});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore
          .collection(_notesCollection)
          .doc(noteId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NoteModel>> getNotesBySubject(
    String subject, {
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_notesCollection)
          .where('subject', isEqualTo: subject)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => NoteModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
  Future<List<NoteModel>> getTrendingNotes({int limit = 20}) async {
    try {
      // First try to get by purchaseCount, if that fails fallback to createdAt
      try {
        final querySnapshot = await _firestore
            .collection(_notesCollection)
            .orderBy('purchaseCount', descending: true)
            .limit(limit)
            .get();

        return querySnapshot.docs
            .map((doc) => NoteModel.fromSnapshot(doc))
            .toList();
      } catch (indexError) {
        // Fallback to sorting by creation date if purchaseCount index doesn't exist
        final querySnapshot = await _firestore
            .collection(_notesCollection)
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();

        return querySnapshot.docs
            .map((doc) => NoteModel.fromSnapshot(doc))
            .toList();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get trending notes excluding the current user's own notes
  Future<List<NoteModel>> getTrendingNotesExcludingOwn({
    required String currentUserUid,
    int limit = 20,
  }) async {
    try {
      // First try to get by purchaseCount, if that fails fallback to createdAt
      try {
        final querySnapshot = await _firestore
            .collection(_notesCollection)
            .orderBy('purchaseCount', descending: true)
            .limit(limit * 2) // Get more to account for filtering
            .get();

        return querySnapshot.docs
            .map((doc) => NoteModel.fromSnapshot(doc))
            .where((note) => note.ownerUid != currentUserUid) // Exclude own notes
            .take(limit) // Take only the requested amount after filtering
            .toList();
      } catch (indexError) {
        // Fallback to sorting by creation date if purchaseCount index doesn't exist
        return await getAllNotesExcludingOwn(
          currentUserUid: currentUserUid,
          limit: limit,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get all notes excluding the current user's own notes
  Future<List<NoteModel>> getAllNotesExcludingOwn({
    required String currentUserUid,
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_notesCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit * 2) // Get more to account for filtering
          .get();

      return querySnapshot.docs
          .map((doc) => NoteModel.fromSnapshot(doc))
          .where((note) => note.ownerUid != currentUserUid) // Exclude own notes
          .take(limit) // Take only the requested amount after filtering
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NoteModel>> getDonationNotesExcludingOwn({
    required String currentUserUid,
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_notesCollection)
          .where('isDonation', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit * 2) // Get more to account for filtering
          .get();

      return querySnapshot.docs
          .map((doc) => NoteModel.fromSnapshot(doc))
          .where((note) => note.ownerUid != currentUserUid) // Exclude own notes
          .take(limit) // Take only the requested amount after filtering
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Search notes excluding the current user's own notes
  Future<List<NoteModel>> searchNotesExcludingOwn(
    String query, {
    required String currentUserUid,
    int limit = 20,
  }) async {
    try {
      final lowerQuery = query.toLowerCase();

      final querySnapshot = await _firestore
          .collection(_notesCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit * 2) // Get more to account for filtering
          .get();

      return querySnapshot.docs
          .where((doc) {
            final data = doc.data();
            final title = (data['title'] ?? '').toString().toLowerCase();
            final subject = (data['subject'] ?? '').toString().toLowerCase();
            final description = (data['description'] ?? '').toString().toLowerCase();
            final ownerUid = data['ownerUid'] ?? '';

            final matchesQuery = title.contains(lowerQuery) ||
                subject.contains(lowerQuery) ||
                description.contains(lowerQuery);

            return matchesQuery && ownerUid != currentUserUid; // Exclude own notes
          })
          .map((doc) => NoteModel.fromSnapshot(doc))
          .take(limit) // Take only the requested amount after filtering
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get notes by subject excluding the current user's own notes
  Future<List<NoteModel>> getNotesBySubjectExcludingOwn(
    String subject, {
    required String currentUserUid,
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_notesCollection)
          .where('subject', isEqualTo: subject)
          .orderBy('createdAt', descending: true)
          .limit(limit * 2) // Get more to account for filtering
          .get();

      return querySnapshot.docs
          .map((doc) => NoteModel.fromSnapshot(doc))
          .where((note) => note.ownerUid != currentUserUid) // Exclude own notes
          .take(limit) // Take only the requested amount after filtering
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<NoteModel>> getUserNotesStream(String ownerUid) {
    return _firestore
        .collection(_notesCollection)
        .where('ownerUid', isEqualTo: ownerUid)
        .snapshots()
        .map((snapshot) {
          final notes = snapshot.docs
              .map((doc) => NoteModel.fromSnapshot(doc))
              .toList();
          // Sort by createdAt in memory
          notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return notes;
        });
  }


  Stream<List<NoteModel>> getAllNotesStream({int limit = 20}) {
    return _firestore
        .collection(_notesCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => NoteModel.fromSnapshot(doc)).toList());
  }

  /// Stream of all notes excluding the current user's own notes
  Stream<List<NoteModel>> getAllNotesStreamExcludingOwn({
    required String currentUserUid,
    int limit = 20,
  }) {
    return _firestore
        .collection(_notesCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit * 2) // Get more to account for filtering
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromSnapshot(doc))
            .where((note) => note.ownerUid != currentUserUid) // Exclude own notes
            .take(limit) // Take only the requested amount after filtering
            .toList());
  }

  // ==================== Purchase Management Methods ====================

  /// Add a purchase record to a note's purchases subcollection
  Future<void> addPurchase({
    required String noteId,
    required String uid,
    required String name,
  }) async {
    try {
      const uuid = Uuid();
      final purchaseId = uuid.v4();
      
      final purchase = PurchaseModel(
        purchaseId: purchaseId,
        uid: uid,
        name: name,
        purchasedAt: DateTime.now(),
      );

      await _firestore
          .collection(_notesCollection)
          .doc(noteId)
          .collection(_purchasesSubcollection)
          .doc(purchaseId)
          .set(purchase.toMap());

      // Also increment the purchase count on the note
      await incrementPurchaseCount(noteId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all purchases for a specific note
  Future<List<PurchaseModel>> getNotePurchases(String noteId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_notesCollection)
          .doc(noteId)
          .collection(_purchasesSubcollection)
          .orderBy('purchasedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PurchaseModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Check if a user has purchased a specific note
  Future<bool> hasUserPurchased(String noteId, String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection(_notesCollection)
          .doc(noteId)
          .collection(_purchasesSubcollection)
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getUserPurchasedNoteIds(String uid) async {
    try {
      final notesSnapshot = await _firestore
          .collection(_notesCollection)
          .get();

      List<String> purchasedNoteIds = [];

      for (final noteDoc in notesSnapshot.docs) {
        final purchasesSnapshot = await noteDoc.reference
            .collection(_purchasesSubcollection)
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();

        if (purchasesSnapshot.docs.isNotEmpty) {
          purchasedNoteIds.add(noteDoc.id);
        }
      }

      return purchasedNoteIds;
    } catch (e) {
      rethrow;
    }
  }

  /// Stream of purchases for a specific note
  Stream<List<PurchaseModel>> getNotePurchasesStream(String noteId) {
    return _firestore
        .collection(_notesCollection)
        .doc(noteId)
        .collection(_purchasesSubcollection)
        .orderBy('purchasedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PurchaseModel.fromSnapshot(doc)).toList());
  }
}
