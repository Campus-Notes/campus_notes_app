import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';
import '../models/purchase_model.dart';
import 'note_database_service.dart';
import '../../../authentication/data/services/database_services.dart';
import '../../../authentication/data/models/user_model.dart';

class PurchasedNoteData {
  final NoteModel note;
  final PurchaseModel purchase;
  final UserModel? owner;

  PurchasedNoteData({
    required this.note,
    required this.purchase,
    this.owner,
  });
}

class LibraryService {
  final NoteDatabaseService _noteDatabaseService = NoteDatabaseService();
  final DatabaseService _userDatabaseService = DatabaseService();

  Future<List<PurchasedNoteData>> getUserPurchasedNotes(
      String currentUserUid) async {
    try {
      final purchasedNoteIds =
          await _noteDatabaseService.getUserPurchasedNoteIds(currentUserUid);

      List<PurchasedNoteData> purchasedNotes = [];

      for (final noteId in purchasedNoteIds) {
        try {
          final note = await _noteDatabaseService.getNoteById(noteId);
          if (note == null) continue;

          final purchases = await _noteDatabaseService.getNotePurchases(noteId);
          final userPurchase = purchases.firstWhere(
            (p) => p.uid == currentUserUid,
            orElse: () => purchases.first,
          );

          UserModel? owner;
          try {
            owner = await _userDatabaseService.getUserData(note.ownerUid);
          } catch (e) {
            owner = null;
          }

          purchasedNotes.add(PurchasedNoteData(
            note: note,
            purchase: userPurchase,
            owner: owner,
          ));
        } catch (e) {
          continue;
        }
      }

      purchasedNotes.sort(
          (a, b) => b.purchase.purchasedAt.compareTo(a.purchase.purchasedAt));

      await _cacheLibraryData(currentUserUid, purchasedNotes);

      return purchasedNotes;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PurchasedNoteData>> getDownloadedNotes(
      String currentUserUid) async {
    try {
      final cachedNotes = await _loadCachedLibraryData(currentUserUid);

      if (cachedNotes.isEmpty) {
        return [];
      }

      List<PurchasedNoteData> downloadedNotes = [];
      for (var noteData in cachedNotes) {
        final isDownloaded = await isPdfDownloaded(
          noteData.note.noteId,
          noteData.note.fileName,
        );
        if (isDownloaded) {
          downloadedNotes.add(noteData);
        }
      }

      return downloadedNotes;
    } catch (e) {
      return [];
    }
  }

  Future<void> _cacheLibraryData(
      String userId, List<PurchasedNoteData> notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final metadata = notes
          .map((noteData) => {
                'noteId': noteData.note.noteId,
                'title': noteData.note.title,
                'subject': noteData.note.subject,
                'fileName': noteData.note.fileName,
                'rating': noteData.note.rating,
                'price': noteData.note.price,
                'ownerUid': noteData.note.ownerUid,
                'purchaseDate': noteData.purchase.purchasedAt.toIso8601String(),
                'ownerName': noteData.owner?.fullName ?? 'Unknown',
              })
          .toList();

      final jsonString = jsonEncode(metadata);
      await prefs.setString('library_cache_$userId', jsonString);
    } catch (e) {
      debugPrint('Error caching library data: $e');
    }
  }

  Future<List<PurchasedNoteData>> _loadCachedLibraryData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('library_cache_$userId');

      if (jsonString == null) {
        return [];
      }

      final List<dynamic> metadata = jsonDecode(jsonString);

      return metadata.map((json) {
        final note = NoteModel(
          noteId: json['noteId'],
          title: json['title'],
          subject: json['subject'],
          fileName: json['fileName'],
          fileEncodedData: '',
          rating: (json['rating'] as num).toDouble(),
          price: (json['price'] as num?)?.toDouble(),
          ownerUid: json['ownerUid'],
          createdAt: DateTime.now(),
          isDonation: (json['price'] == null),
          purchaseCount: 0,
        );

        final purchase = PurchaseModel(
          purchaseId: 'offline',
          name: json['title'],
          uid: userId,
          purchasedAt: DateTime.parse(json['purchaseDate']),
        );

        final owner = UserModel(
          uid: json['ownerUid'],
          email: '',
          firstName: json['ownerName'],
          lastName: '',
          mobile: '',
          university: '',
          createdAt: DateTime.now(),
        );

        return PurchasedNoteData(
          note: note,
          purchase: purchase,
          owner: owner,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Uint8List decodePdfData(String encodedData) {
    try {
      return base64Decode(encodedData);
    } catch (e) {
      throw Exception('Failed to decode PDF data: $e');
    }
  }

  Future<File> saveEncryptedPdf(
      String noteId, String encodedData, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final libraryDir = Directory('${directory.path}/library');

      if (!await libraryDir.exists()) {
        await libraryDir.create(recursive: true);
      }

      final hashedFileName = _hashFileName(noteId, fileName);
      final file = File('${libraryDir.path}/$hashedFileName');

      final pdfBytes = decodePdfData(encodedData);

      final encryptedBytes = _encryptBytes(pdfBytes, noteId);

      await file.writeAsBytes(encryptedBytes);

      return file;
    } catch (e) {
      throw Exception('Failed to save PDF: $e');
    }
  }

  Future<Uint8List> loadEncryptedPdf(String noteId, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final hashedFileName = _hashFileName(noteId, fileName);
      final file = File('${directory.path}/library/$hashedFileName');

      if (!await file.exists()) {
        throw Exception('PDF file not found');
      }

      final encryptedBytes = await file.readAsBytes();

      final decryptedBytes = _encryptBytes(encryptedBytes, noteId);

      return decryptedBytes;
    } catch (e) {
      throw Exception('Failed to load PDF: $e');
    }
  }

  Future<bool> isPdfDownloaded(String noteId, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final hashedFileName = _hashFileName(noteId, fileName);
      final file = File('${directory.path}/library/$hashedFileName');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteDownloadedPdf(String noteId, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final hashedFileName = _hashFileName(noteId, fileName);
      final file = File('${directory.path}/library/$hashedFileName');

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete PDF: $e');
    }
  }

  Future<int> getLibrarySize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final libraryDir = Directory('${directory.path}/library');

      if (!await libraryDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in libraryDir.list(recursive: false)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  String _hashFileName(String noteId, String fileName) {
    final input = '$noteId-$fileName';
    final bytes = utf8.encode(input);
    final hash = sha256.convert(bytes);
    return '$hash.encrypted';
  }

  Uint8List _encryptBytes(Uint8List bytes, String key) {
    final keyBytes = utf8.encode(key);
    final encrypted = Uint8List(bytes.length);

    for (int i = 0; i < bytes.length; i++) {
      encrypted[i] = bytes[i] ^ keyBytes[i % keyBytes.length];
    }

    return encrypted;
  }
}
