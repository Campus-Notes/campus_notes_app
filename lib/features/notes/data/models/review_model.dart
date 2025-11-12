import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String noteId;
  final String description;
  final double rating;
  final String userUid;
  final DateTime createdAt;

  ReviewModel({
    required this.reviewId,
    required this.noteId,
    required this.description,
    required this.rating,
    required this.userUid,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'noteId': noteId,
      'description': description,
      'rating': rating,
      'userUid': userUid,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReviewModel(
      reviewId: map['reviewId'] ?? docId,
      noteId: map['noteId'] ?? '',
      description: map['description'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      userUid: map['userUid'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ReviewModel.fromSnapshot(DocumentSnapshot snapshot) {
    return ReviewModel.fromMap(
      snapshot.data() as Map<String, dynamic>,
      snapshot.id,
    );
  }

  @override
  String toString() {
    return 'ReviewModel(reviewId: $reviewId, noteId: $noteId, rating: $rating, '
        'userUid: $userUid, description: $description)';
  }
}
