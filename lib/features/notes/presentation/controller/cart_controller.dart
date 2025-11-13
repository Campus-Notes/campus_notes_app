import 'package:flutter/material.dart';
import '../../data/models/note_model.dart';

class CartController extends ChangeNotifier {
  final Map<String, NoteModel> _items = {};

  Map<String, NoteModel> get items => {..._items};

  int get itemCount => _items.length;

  bool isInCart(String noteId) => _items.containsKey(noteId);

  double get subtotal {
    return _items.values.fold(0.0, (sum, note) => sum + (note.price ?? 0.0));
  }

  double get total => subtotal;

  void addToCart(NoteModel note) {
    if (!_items.containsKey(note.noteId)) {
      _items[note.noteId] = note;
      notifyListeners();
    }
  }

  void removeFromCart(String noteId) {
    _items.remove(noteId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  List<NoteModel> get cartNotes => _items.values.toList();

  List<String> get noteIds => _items.keys.toList();
}
