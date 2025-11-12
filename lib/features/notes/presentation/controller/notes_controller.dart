import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../notes/data/models/note_model.dart';
import '../../../notes/data/services/note_database_service.dart';
import '../../../notes/data/services/pdf_service.dart';
import '../../../../data/dummy_data.dart';

/// NotesController manages the state and operations for notes feature
/// Handles note uploads, retrievals, and state management with Firestore integration
class NotesController extends ChangeNotifier {
  final NoteDatabaseService _databaseService = NoteDatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Legacy dummy data support
  List<NoteItem> _notes = [];
  List<NoteItem> _filteredNotes = [];
  List<PurchaseItem> _purchases = [];

  // Firestore integration
  List<NoteModel> _userNotes = [];
  List<NoteModel> _allNotes = [];
  List<NoteModel> _searchResults = [];

  // State
  bool _isLoading = false;
  String? _error;
  String? _uploadMessage;
  String _searchQuery = '';

  // Getters - Legacy support
  List<NoteItem> get notes => _filteredNotes.isEmpty && _searchQuery.isEmpty ? _notes : _filteredNotes;
  List<PurchaseItem> get purchases => _purchases;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  // Getters - Firestore
  List<NoteModel> get userNotes => _userNotes;
  List<NoteModel> get allNotes => _allNotes;
  List<NoteModel> get searchResults => _searchResults;
  String? get uploadMessage => _uploadMessage;

  NotesController() {
    _loadNotes();
    _loadPurchases();
  }

  void _loadNotes() {
    _isLoading = true;
    notifyListeners();

    // Simulate loading notes
    Future.delayed(const Duration(milliseconds: 500), () {
      _notes = List.from(dummyNotes);
      _isLoading = false;
      notifyListeners();
    });
  }

  void _loadPurchases() {
    _purchases = List.from(dummyPurchases);
    notifyListeners();
  }

  void searchNotes(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredNotes = [];
    } else {
      _filteredNotes = _notes.where((note) {
        return note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.subject.toLowerCase().contains(query.toLowerCase()) ||
            note.seller.toLowerCase().contains(query.toLowerCase()) ||
            note.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredNotes = [];
    notifyListeners();
  }

  // ==================== Firestore Integration Methods ====================

  /// Upload a new note with PDF file bytes to Firestore
  /// 
  /// Parameters:
  /// - title: Note title
  /// - subject: Subject/category
  /// - description: Optional description
  /// - isDonation: Whether it's free or paid
  /// - price: Price in rupees (null if donation)
  /// - fileName: Name of PDF file
  /// - fileBytes: PDF file bytes
  /// 
  /// Returns true if upload successful, false otherwise
  Future<bool> uploadNoteWithBytes({
    required String title,
    required String subject,
    String? description,
    required bool isDonation,
    double? price,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      _uploadMessage = null;
      notifyListeners();

      // Validate user is authenticated
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate PDF file bytes
      if (!PdfService.isPdfBytes(fileBytes)) {
        _error = 'Please select a valid PDF file';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check file size (max 10MB recommended for Firestore)
      final fileSizeMB = PdfService.getBytesSizeInMB(fileBytes);
      if (fileSizeMB > 10) {
        _error =
            'PDF file is too large (max 10MB). Size: ${fileSizeMB.toStringAsFixed(2)}MB';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Encode PDF bytes to Base64
      _uploadMessage = 'Encoding PDF...';
      notifyListeners();
      final fileEncodedData = PdfService.encodeBytesToBase64(fileBytes);

      // Upload to Firestore
      _uploadMessage = 'Uploading to cloud...';
      notifyListeners();
      final uploadedNote = await _databaseService.uploadNote(
        title: title,
        subject: subject,
        description: description,
        ownerUid: currentUser.uid,
        isDonation: isDonation,
        price: isDonation ? null : price,
        fileName: fileName,
        fileEncodedData: fileEncodedData,
      );

      // Add to local list
      _userNotes.insert(0, uploadedNote);
      _uploadMessage = isDonation ? 'Note donated successfully!' : 'Note published successfully!';
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = 'Upload failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Upload a new note with PDF file to Firestore
  /// 
  /// Parameters:
  /// - title: Note title
  /// - subject: Subject/category
  /// - description: Optional description
  /// - isDonation: Whether it's free or paid
  /// - price: Price in rupees (null if donation)
  /// - fileName: Name of PDF file
  /// - filePath: Path to PDF file on device
  /// 
  /// Returns true if upload successful, false otherwise
  Future<bool> uploadNoteWithPdf({
    required String title,
    required String subject,
    String? description,
    required bool isDonation,
    double? price,
    required String fileName,
    required String filePath,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      _uploadMessage = null;
      notifyListeners();

      // Validate user is authenticated
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate PDF file
      if (!PdfService.isPdfFile(filePath)) {
        _error = 'Please select a valid PDF file';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check file size (max 10MB recommended for Firestore)
      final fileSizeMB = await PdfService.getFileSizeInMB(filePath);
      if (fileSizeMB > 10) {
        _error =
            'PDF file is too large (max 10MB). Size: ${fileSizeMB.toStringAsFixed(2)}MB';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Encode PDF to Base64
      _uploadMessage = 'Encoding PDF...';
      notifyListeners();
      final fileEncodedData = await PdfService.encodeFileToBase64(filePath);

      // Upload to Firestore
      _uploadMessage = 'Uploading to cloud...';
      notifyListeners();
      final uploadedNote = await _databaseService.uploadNote(
        title: title,
        subject: subject,
        description: description,
        ownerUid: currentUser.uid,
        isDonation: isDonation,
        price: isDonation ? null : price,
        fileName: fileName,
        fileEncodedData: fileEncodedData,
      );

      // Add to local list
      _userNotes.insert(0, uploadedNote);
      _uploadMessage = isDonation ? 'Note donated successfully!' : 'Note published successfully!';
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = 'Upload failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load user's notes from Firestore
  Future<void> loadUserNotes() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _userNotes = await _databaseService.getUserNotes(currentUser.uid);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load notes: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all notes from Firestore excluding current user's own notes
  Future<void> loadAllNotes({int limit = 20}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Use the new method that excludes own notes
      _allNotes = await _databaseService.getAllNotesExcludingOwn(
        currentUserUid: currentUser.uid,
        limit: limit,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load notes: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load trending notes from Firestore excluding current user's own notes
  Future<void> loadTrendingNotes({int limit = 20}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Use the new method that excludes own notes
      _allNotes = await _databaseService.getTrendingNotesExcludingOwn(
        currentUserUid: currentUser.uid,
        limit: limit,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load notes: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search notes by query excluding current user's own notes
  Future<void> searchNotesFirestore(String query) async {
    try {
      if (query.isEmpty) {
        _searchResults = [];
        notifyListeners();
        return;
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Use the new method that excludes own notes
      _searchResults = await _databaseService.searchNotesExcludingOwn(
        query,
        currentUserUid: currentUser.uid,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get notes by subject excluding current user's own notes
  Future<void> getNotesBySubject(String subject) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Use the new method that excludes own notes
      _allNotes = await _databaseService.getNotesBySubjectExcludingOwn(
        subject,
        currentUserUid: currentUser.uid,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load notes: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Download note PDF from Firestore
  /// 
  /// Parameters:
  /// - noteId: ID of the note
  /// - outputPath: Where to save the PDF file
  /// 
  /// Returns the File object or null if failed
  Future<File?> downloadNotePdf(String noteId, String outputPath) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final note = await _databaseService.getNoteById(noteId);
      if (note == null) {
        _error = 'Note not found';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // Increment view count
      await _databaseService.incrementViewCount(noteId);

      // Decode Base64 to file
      final file = await PdfService.decodeBase64ToFile(
        note.fileEncodedData,
        outputPath,
      );

      _isLoading = false;
      notifyListeners();
      return file;
    } catch (e) {
      _error = 'Download failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update note details
  Future<bool> updateNote(NoteModel note) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _databaseService.updateNote(note);

      // Update in local list
      final index = _userNotes.indexWhere((n) => n.noteId == note.noteId);
      if (index != -1) {
        _userNotes[index] = note;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Update failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a note
  Future<bool> deleteNote(String noteId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _databaseService.deleteNote(noteId);

      // Remove from local list
      _userNotes.removeWhere((n) => n.noteId == noteId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Delete failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get a single note by ID
  Future<NoteModel?> getNoteById(String noteId) async {
    try {
      return await _databaseService.getNoteById(noteId);
    } catch (e) {
      _error = 'Failed to get note: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Record a note purchase with user details
  Future<void> recordNotePurchase(String noteId, {String? userUid, String? userName}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null && userUid != null && userName != null) {
        // Add purchase record with user details
        await _databaseService.addPurchase(
          noteId: noteId,
          uid: userUid,
          name: userName,
        );
      } else {
        // Fallback to just incrementing purchase count
        await _databaseService.incrementPurchaseCount(noteId);
      }
    } catch (e) {
      _error = 'Failed to record purchase: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Update note rating
  Future<void> updateNoteRating(String noteId, double rating) async {
    try {
      await _databaseService.updateRating(noteId, rating);
    } catch (e) {
      _error = 'Failed to update rating: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Get donation notes excluding current user's own notes
  Future<void> loadDonationNotes() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Use the new method that excludes own notes
      _allNotes = await _databaseService.getDonationNotesExcludingOwn(
        currentUserUid: currentUser.uid,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load donation notes: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== Legacy Dummy Data Methods ====================

  Future<void> uploadNote({
    required String title,
    required String subject,
    required double price,
    required int pages,
    required List<String> tags,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate upload process
      await Future.delayed(const Duration(seconds: 2));

      // Validation
      if (title.isEmpty || subject.isEmpty) {
        throw Exception('Title and subject are required');
      }

      if (price <= 0) {
        throw Exception('Price must be greater than 0');
      }

      if (pages <= 0) {
        throw Exception('Pages must be greater than 0');
      }

      // Create new note
      final newNote = NoteItem(
        id: 'n${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        subject: subject,
        seller: 'You', // Current user
        price: price,
        rating: 0.0, // New notes start with 0 rating
        pages: pages,
        tags: tags,
      );

      _notes.insert(0, newNote); // Add to beginning
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> purchaseNote(NoteItem note) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate purchase process
      await Future.delayed(const Duration(seconds: 1));

      // Check if already purchased
      if (_purchases.any((p) => p.id == note.id)) {
        throw Exception('You have already purchased this note');
      }

      // Create purchase record
      final purchase = PurchaseItem(
        id: note.id,
        title: note.title,
        subject: note.subject,
        date: DateTime.now(),
        amount: note.price,
      );

      _purchases.insert(0, purchase);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearUploadMessage() {
    _uploadMessage = null;
    notifyListeners();
  }

  void refreshNotes() {
    _loadNotes();
  }
}