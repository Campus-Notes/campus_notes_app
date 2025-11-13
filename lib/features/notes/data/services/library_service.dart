import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';
import '../models/purchase_model.dart';
import 'note_database_service.dart';
import '../../../authentication/data/services/database_services.dart';
import '../../../authentication/data/models/user_model.dart';

/// Model for a purchased note with additional metadata
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

  /// Fetch all purchased notes for the current user with owner information
  Future<List<PurchasedNoteData>> getUserPurchasedNotes(String currentUserUid) async {
    try {
      // Get all note IDs that the user has purchased
      final purchasedNoteIds = await _noteDatabaseService.getUserPurchasedNoteIds(currentUserUid);
      
      List<PurchasedNoteData> purchasedNotes = [];

      for (final noteId in purchasedNoteIds) {
        try {
          // Get the note details
          final note = await _noteDatabaseService.getNoteById(noteId);
          if (note == null) continue;

          // Get purchase information
          final purchases = await _noteDatabaseService.getNotePurchases(noteId);
          final userPurchase = purchases.firstWhere(
            (p) => p.uid == currentUserUid,
            orElse: () => purchases.first,
          );

          // Get owner information
          UserModel? owner;
          try {
            owner = await _userDatabaseService.getUserData(note.ownerUid);
          } catch (e) {
            // If owner fetch fails, continue without owner data
            owner = null;
          }

          purchasedNotes.add(PurchasedNoteData(
            note: note,
            purchase: userPurchase,
            owner: owner,
          ));
        } catch (e) {
          // Skip this note if there's an error
          continue;
        }
      }

      // Sort by purchase date (most recent first)
      purchasedNotes.sort((a, b) => b.purchase.purchasedAt.compareTo(a.purchase.purchasedAt));

      // Cache the library data for offline use
      await _cacheLibraryData(currentUserUid, purchasedNotes);

      return purchasedNotes;
    } catch (e) {
      rethrow;
    }
  }

  /// Get downloaded notes for offline viewing
  Future<List<PurchasedNoteData>> getDownloadedNotes(String currentUserUid) async {
    try {
      // Try to load from cache first
      final cachedNotes = await _loadCachedLibraryData(currentUserUid);
      
      if (cachedNotes.isEmpty) {
        return [];
      }

      // Filter only downloaded notes
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

  /// Cache library data for offline access
  Future<void> _cacheLibraryData(String userId, List<PurchasedNoteData> notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Store simple metadata for offline access
      final metadata = notes.map((noteData) => {
        'noteId': noteData.note.noteId,
        'title': noteData.note.title,
        'subject': noteData.note.subject,
        'fileName': noteData.note.fileName,
        'rating': noteData.note.rating,
        'price': noteData.note.price,
        'ownerUid': noteData.note.ownerUid,
        'purchaseDate': noteData.purchase.purchasedAt.toIso8601String(),
        'ownerName': noteData.owner?.fullName ?? 'Unknown',
      }).toList();
      
      final jsonString = jsonEncode(metadata);
      await prefs.setString('library_cache_$userId', jsonString);
    } catch (e) {
      // Silently fail if caching doesn't work
    }
  }

  /// Load cached library data
  Future<List<PurchasedNoteData>> _loadCachedLibraryData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('library_cache_$userId');
      
      if (jsonString == null) {
        return [];
      }

      final List<dynamic> metadata = jsonDecode(jsonString);
      
      return metadata.map((json) {
        // Create minimal models from cached metadata
        final note = NoteModel(
          noteId: json['noteId'],
          title: json['title'],
          subject: json['subject'],
          fileName: json['fileName'],
          fileEncodedData: '', // Not needed for downloaded files
          rating: (json['rating'] as num).toDouble(),
          price: (json['price'] as num?)?.toDouble(),
          ownerUid: json['ownerUid'],
          createdAt: DateTime.now(), // Not critical for offline viewing
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

  /// Decode base64 PDF data to bytes
  Uint8List decodePdfData(String encodedData) {
    try {
      return base64Decode(encodedData);
    } catch (e) {
      throw Exception('Failed to decode PDF data: $e');
    }
  }

  /// Save encrypted PDF to internal storage for offline access
  Future<File> saveEncryptedPdf(String noteId, String encodedData, String fileName) async {
    try {
      // Get app's internal directory (not accessible by other apps)
      final directory = await getApplicationDocumentsDirectory();
      final libraryDir = Directory('${directory.path}/library');
      
      // Create library directory if it doesn't exist
      if (!await libraryDir.exists()) {
        await libraryDir.create(recursive: true);
      }

      // Create a unique file name with hash to prevent conflicts
      final hashedFileName = _hashFileName(noteId, fileName);
      final file = File('${libraryDir.path}/$hashedFileName');

      // Decode the base64 data
      final pdfBytes = decodePdfData(encodedData);

      // Simple XOR encryption for additional security
      final encryptedBytes = _encryptBytes(pdfBytes, noteId);

      // Write encrypted bytes to file
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
