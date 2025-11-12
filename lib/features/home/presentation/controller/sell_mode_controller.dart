import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../authentication/presentation/controller/auth_controller.dart';
import '../../../notes/data/models/note_model.dart';
import '../../../notes/data/services/note_database_service.dart';

class SellModeController with ChangeNotifier {
  final NoteDatabaseService _noteDatabaseService;
  final AuthController _authController;

  SellModeController({
    required NoteDatabaseService noteDatabaseService,
    required AuthController authController,
  })  : _noteDatabaseService = noteDatabaseService,
        _authController = authController;

  bool _isLoading = false;
  double _totalEarnings = 0.0;
  int _totalSoldNotes = 0;
  List<NoteModel> _userNotes = [];

  bool get isLoading => _isLoading;
  double get totalEarnings => _totalEarnings;
  int get totalSoldNotes => _totalSoldNotes;
  List<Map<String, dynamic>> get soldNotesData => _getSoldNotesData();

  Future<void> loadSellModeData() async {
    final userId = _authController.currentUserUid;
    if (userId == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _userNotes = await _noteDatabaseService.getUserNotes(userId);
      
      _totalEarnings = 0.0;
      _totalSoldNotes = 0;
      
      for (final note in _userNotes) {
        if (note.purchaseCount > 0 && note.price != null) {
          final noteEarnings = (note.price! * note.purchaseCount) * 0.8; 
          _totalEarnings += noteEarnings;
          _totalSoldNotes++;
        }
      }
      
      final userData = await _authController.getCurrentUser();
      if (userData != null && userData.totalEarnings != _totalEarnings) {
        await _updateUserTotalEarnings(userId, _totalEarnings);
      }
      
    } catch (e) {
      // Error loading sell mode data
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateUserTotalEarnings(String userId, double totalEarnings) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'totalEarnings': totalEarnings});
    } catch (e) {
      // Error updating user total earnings
    }
  }

  List<Map<String, dynamic>> _getSoldNotesData() {
    final soldNotesData = <Map<String, dynamic>>[];
    
    for (final note in _userNotes) {
      if (note.price != null) { 
        final totalEarned = note.purchaseCount > 0 
            ? (note.price! * note.purchaseCount) * 0.8 
            : 0.0; 
        
        soldNotesData.add({
          'id': note.noteId,
          'title': note.title,
          'subject': note.subject,
          'price': note.price!,
          'dateSold': note.createdAt.toIso8601String().split('T').first,
          'buyerCount': note.purchaseCount,
          'totalEarned': totalEarned,
          'rating': note.rating,
        });
      }
    }
    
    soldNotesData.sort((a, b) => b['dateSold'].compareTo(a['dateSold']));
    
    return soldNotesData;
  }

  Future<void> refresh() async {
    await loadSellModeData();
  }
}