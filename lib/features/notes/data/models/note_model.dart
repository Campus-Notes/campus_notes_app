import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String noteId;
  final String title;
  final String subject;
  final String? description;
  final String ownerUid;
  final bool isDonation;
  final double? price;
  final double rating;
  final String fileName;
  final String fileEncodedData;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int viewCount;
  final int purchaseCount;
  final double earnings;
  final bool isVerified;
  final int pageCount;

  NoteModel({
    required this.noteId,
    required this.title,
    required this.subject,
    this.description,
    required this.ownerUid,
    required this.isDonation,
    this.price,
    this.rating = 0.0,
    required this.fileName,
    required this.fileEncodedData,
    required this.createdAt,
    this.updatedAt,
    this.viewCount = 0,
    this.purchaseCount = 0,
    this.earnings = 0.0,
    this.isVerified = false,
    this.pageCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'noteId': noteId,
      'title': title,
      'subject': subject,
      'description': description,
      'ownerUid': ownerUid,
      'isDonation': isDonation,
      'price': isDonation ? null : price,
      'rating': rating,
      'fileName': fileName,
      'fileEncodedData': fileEncodedData,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'viewCount': viewCount,
      'purchaseCount': purchaseCount,
      'earnings': earnings,
      'isVerified': isVerified,
      'pageCount': pageCount,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map, String docId) {
    final descriptionValue = map['description'] as String?;

    final ownerUidValue = map['ownerUid'] ?? '';

    return NoteModel(
      noteId: map['noteId'] ?? docId,
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      description: descriptionValue,
      ownerUid: ownerUidValue,
      isDonation: map['isDonation'] ?? false,
      price:
          map['isDonation'] == true ? null : (map['price'] as num?)?.toDouble(),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      fileName: map['fileName'] ?? '',
      fileEncodedData: map['fileEncodedData'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      viewCount: map['viewCount'] ?? 0,
      purchaseCount: map['purchaseCount'] ?? 0,
      earnings: (map['earnings'] as num?)?.toDouble() ?? 0.0,
      isVerified: map['isVerified'] ?? false,
      pageCount: map['pageCount'] ?? 0,
    );
  }

  factory NoteModel.fromSnapshot(DocumentSnapshot snapshot) {
    return NoteModel.fromMap(
      snapshot.data() as Map<String, dynamic>,
      snapshot.id,
    );
  }

  NoteModel copyWith({
    String? title,
    String? subject,
    String? description,
    bool? isDonation,
    double? price,
    double? rating,
    String? fileName,
    String? fileEncodedData,
    int? viewCount,
    int? purchaseCount,
    double? earnings,
    bool? isVerified,
    int? pageCount,
  }) {
    return NoteModel(
      noteId: noteId,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      ownerUid: ownerUid,
      isDonation: isDonation ?? this.isDonation,
      price: isDonation == true ? null : (price ?? this.price),
      rating: rating ?? this.rating,
      fileName: fileName ?? this.fileName,
      fileEncodedData: fileEncodedData ?? this.fileEncodedData,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      viewCount: viewCount ?? this.viewCount,
      purchaseCount: purchaseCount ?? this.purchaseCount,
      earnings: earnings ?? this.earnings,
      isVerified: isVerified ?? this.isVerified,
      pageCount: pageCount ?? this.pageCount,
    );
  }

  @override
  String toString() {
    return 'NoteModel(noteId: $noteId, title: $title, subject: $subject, '
        'description: "$description" (length: ${description?.length}, isEmpty: ${description?.isEmpty}, isNull: ${description == null}), '
        'ownerUid: $ownerUid, isDonation: $isDonation, price: $price, rating: $rating, '
        'pageCount: $pageCount, earnings: $earnings)';
  }
}
