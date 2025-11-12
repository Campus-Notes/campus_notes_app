import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/review_model.dart';
import 'note_database_service.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NoteDatabaseService _noteDatabaseService = NoteDatabaseService();
  static const String _reviewsCollection = 'reviews';

  Future<ReviewModel> addReview({
    required String noteId,
    required String userUid,
    required String description,
    required double rating,
  }) async {
    try {
      if (rating < 1.0 || rating > 5.0) {
        throw Exception('Rating must be between 1 and 5');
      }

      final existingReview = await hasUserReviewed(noteId, userUid);
      if (existingReview) {
        throw Exception('You have already reviewed this note');
      }

      const uuid = Uuid();
      final reviewId = uuid.v4();
      final now = DateTime.now();

      final review = ReviewModel(
        reviewId: reviewId,
        noteId: noteId,
        description: description.trim(),
        rating: rating,
        userUid: userUid,
        createdAt: now,
      );

      // Add review to Firestore
      await _firestore
          .collection(_reviewsCollection)
          .doc(reviewId)
          .set(review.toMap());

      // Update the note's average rating
      await _updateNoteAverageRating(noteId);

      return review;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all reviews for a specific note
  Future<List<ReviewModel>> getNoteReviews(String noteId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_reviewsCollection)
          .where('noteId', isEqualTo: noteId)
          .get();

      final reviews = querySnapshot.docs
          .map((doc) => ReviewModel.fromSnapshot(doc))
          .toList();
      
      // Sort by createdAt in memory to avoid requiring a composite index
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return reviews;
    } catch (e) {
      rethrow;
    }
  }

  /// Get reviews for a note as a stream
  Stream<List<ReviewModel>> getNoteReviewsStream(String noteId) {
    return _firestore
        .collection(_reviewsCollection)
        .where('noteId', isEqualTo: noteId)
        .snapshots()
        .map((snapshot) {
          final reviews = snapshot.docs
              .map((doc) => ReviewModel.fromSnapshot(doc))
              .toList();
          
          // Sort by createdAt in memory to avoid requiring a composite index
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return reviews;
        });
  }

  /// Check if a user has already reviewed a note
  Future<bool> hasUserReviewed(String noteId, String userUid) async {
    try {
      final querySnapshot = await _firestore
          .collection(_reviewsCollection)
          .where('noteId', isEqualTo: noteId)
          .where('userUid', isEqualTo: userUid)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  Future<ReviewModel?> getUserReview(String noteId, String userUid) async {
    try {
      final querySnapshot = await _firestore
          .collection(_reviewsCollection)
          .where('noteId', isEqualTo: noteId)
          .where('userUid', isEqualTo: userUid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return ReviewModel.fromSnapshot(querySnapshot.docs.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateReview({
    required String reviewId,
    required String noteId,
    required String description,
    required double rating,
  }) async {
    try {
      if (rating < 1.0 || rating > 5.0) {
        throw Exception('Rating must be between 1 and 5');
      }

      await _firestore.collection(_reviewsCollection).doc(reviewId).update({
        'description': description.trim(),
        'rating': rating,
      });

      await _updateNoteAverageRating(noteId);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete review
  Future<void> deleteReview(String reviewId, String noteId) async {
    try {
      await _firestore.collection(_reviewsCollection).doc(reviewId).delete();

      await _updateNoteAverageRating(noteId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updateNoteAverageRating(String noteId) async {
  try {
    final reviews = await getNoteReviews(noteId);

    double averageRating = 0.0;
    if (reviews.isNotEmpty) {
      final totalRating = reviews.fold<double>(
        0.0,
        (acc, review) => acc + review.rating,
      );
      averageRating = totalRating / reviews.length;
    }

    await _noteDatabaseService.updateRating(noteId, averageRating);
  } catch (e) {
    rethrow;
  }
}


  Future<int> getReviewCount(String noteId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_reviewsCollection)
          .where('noteId', isEqualTo: noteId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ReviewModel>> getUserReviews(String userUid) async {
    try {
      final querySnapshot = await _firestore
          .collection(_reviewsCollection)
          .where('userUid', isEqualTo: userUid)
          .get();

      final reviews = querySnapshot.docs
          .map((doc) => ReviewModel.fromSnapshot(doc))
          .toList();
      
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return reviews;
    } catch (e) {
      rethrow;
    }
  }
}
