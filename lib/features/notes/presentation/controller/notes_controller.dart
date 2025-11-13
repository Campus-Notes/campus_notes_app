import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../notes/data/models/note_model.dart';
import '../../../notes/data/services/note_database_service.dart';
import '../../../notes/data/services/pdf_service.dart';
import '../../../../data/dummy_data.dart';

class NotesController extends ChangeNotifier {
  final NoteDatabaseService _databaseService = NoteDatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<NoteItem> _notes = [];
  List<NoteItem> _filteredNotes = [];
  List<PurchaseItem> _purchases = [];

  List<NoteModel> _userNotes = [];
  List<NoteModel> _allNotes = [];
  List<NoteModel> _searchResults = [];

  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String? _error;
  String? _uploadMessage;
  String _searchQuery = '';

  List<NoteItem> get notes =>
      _filteredNotes.isEmpty && _searchQuery.isEmpty ? _notes : _filteredNotes;
  List<PurchaseItem> get purchases => _purchases;
  bool get isLoading => _isLoading;
  bool get hasLoadedOnce => _hasLoadedOnce;
  String? get error => _error;
  String get searchQuery => _searchQuery;

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
            note.tags
                .any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredNotes = [];
    notifyListeners();
  }

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

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!PdfService.isPdfBytes(fileBytes)) {
        _error = 'Please select a valid PDF file';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final fileSizeMB = PdfService.getBytesSizeInMB(fileBytes);
      if (fileSizeMB > 10) {
        _error =
            'PDF file is too large (max 10MB). Size: ${fileSizeMB.toStringAsFixed(2)}MB';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _uploadMessage = 'Encoding PDF...';
      notifyListeners();
      final fileEncodedData = PdfService.encodeBytesToBase64(fileBytes);

      _uploadMessage = 'Analyzing PDF...';
      notifyListeners();
      final pageCount = PdfService.countPdfPages(fileBytes);

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
        pageCount: pageCount,
      );

      _userNotes.insert(0, uploadedNote);
      _uploadMessage = isDonation
          ? 'Note donated successfully!'
          : 'Note published successfully!';
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

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!PdfService.isPdfFile(filePath)) {
        _error = 'Please select a valid PDF file';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final fileSizeMB = await PdfService.getFileSizeInMB(filePath);
      if (fileSizeMB > 10) {
        _error =
            'PDF file is too large (max 10MB). Size: ${fileSizeMB.toStringAsFixed(2)}MB';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _uploadMessage = 'Encoding PDF...';
      notifyListeners();
      final fileEncodedData = await PdfService.encodeFileToBase64(filePath);

      _uploadMessage = 'Analyzing PDF...';
      notifyListeners();
      final fileBytes = await File(filePath).readAsBytes();
      final pageCount = PdfService.countPdfPages(fileBytes);

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
        pageCount: pageCount,
      );

      _userNotes.insert(0, uploadedNote);
      _uploadMessage = isDonation
          ? 'Note donated successfully!'
          : 'Note published successfully!';
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

      _allNotes = await _databaseService.getTrendingNotesExcludingOwn(
        currentUserUid: currentUser.uid,
        limit: limit,
      );
      _hasLoadedOnce = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load notes: ${e.toString()}';
      _hasLoadedOnce = true;
      _isLoading = false;
      notifyListeners();
    }
  }

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

      await _databaseService.incrementViewCount(noteId);

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

  Future<bool> updateNote(NoteModel note) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _databaseService.updateNote(note);

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

  Future<bool> deleteNote(String noteId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _databaseService.deleteNote(noteId);

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

  Future<NoteModel?> getNoteById(String noteId) async {
    try {
      return await _databaseService.getNoteById(noteId);
    } catch (e) {
      _error = 'Failed to get note: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<void> recordNotePurchase(String noteId,
      {String? userUid, String? userName}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null && userUid != null && userName != null) {
        await _databaseService.addPurchase(
          noteId: noteId,
          uid: userUid,
          name: userName,
        );
      } else {
        await _databaseService.incrementPurchaseCount(noteId);
      }
    } catch (e) {
      _error = 'Failed to record purchase: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateNoteRating(String noteId, double rating) async {
    try {
      await _databaseService.updateRating(noteId, rating);
    } catch (e) {
      _error = 'Failed to update rating: ${e.toString()}';
      notifyListeners();
    }
  }

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
      await Future.delayed(const Duration(seconds: 2));

      if (title.isEmpty || subject.isEmpty) {
        throw Exception('Title and subject are required');
      }

      if (price <= 0) {
        throw Exception('Price must be greater than 0');
      }

      if (pages <= 0) {
        throw Exception('Pages must be greater than 0');
      }

      final newNote = NoteItem(
        id: 'n${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        subject: subject,
        seller: 'You',
        price: price,
        rating: 0.0,
        pages: pages,
        tags: tags,
      );

      _notes.insert(0, newNote);
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
      await Future.delayed(const Duration(seconds: 1));

      if (_purchases.any((p) => p.id == note.id)) {
        throw Exception('You have already purchased this note');
      }

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
