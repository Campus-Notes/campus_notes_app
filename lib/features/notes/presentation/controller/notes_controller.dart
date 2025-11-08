import 'package:flutter/material.dart';
import '../../../../data/dummy_data.dart';

class NotesController extends ChangeNotifier {
  List<NoteItem> _notes = [];
  List<NoteItem> _filteredNotes = [];
  List<PurchaseItem> _purchases = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  
  List<NoteItem> get notes => _filteredNotes.isEmpty && _searchQuery.isEmpty ? _notes : _filteredNotes;
  List<PurchaseItem> get purchases => _purchases;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  
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
  
  void refreshNotes() {
    _loadNotes();
  }
}