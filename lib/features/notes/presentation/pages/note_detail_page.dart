import 'package:campus_notes_app/features/notes/data/services/note_database_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/dummy_data.dart';
import '../../../payment/data/services/transaction_service.dart';
import '../../data/models/note_model.dart';
import '../widgets/pdf_preview.dart';
import '../widgets/note_header.dart';
import '../widgets/status_indicators.dart';
import '../widgets/note_details.dart';
import '../widgets/purchase_status.dart';
import '../widgets/bottom_action_bar.dart';

class NoteDetailPage extends StatefulWidget {
  const NoteDetailPage({super.key, required this.note});
  final dynamic note; 

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final TransactionService _transactionService = TransactionService();
  final NoteDatabaseService _noteDatabaseService = NoteDatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  bool _isOwnNote = false;
  bool _hasAlreadyPurchased = false;

  @override
  void initState() {
    super.initState();
    _checkNoteOwnershipAndPurchase();
  }

  Future<void> _checkNoteOwnershipAndPurchase() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Get full note data if we only have NoteItem
      if (widget.note is NoteItem) {
        // For dummy data, we'll simulate
        _isOwnNote = false;
        _hasAlreadyPurchased = false;
      } else if (widget.note is NoteModel) {
        final noteModel = widget.note as NoteModel;
        
        // Check if user owns this note
        _isOwnNote = noteModel.ownerUid == currentUser.uid;
        
        // Check if user has already purchased this note
        if (!_isOwnNote) {
          _hasAlreadyPurchased = await _noteDatabaseService.hasUserPurchased(
            noteModel.noteId,
            currentUser.uid, 
          );
        }
      }
    } catch (e) {
      // Handle error silently for now
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handlePurchase() async {
    if (_isOwnNote) return;
    if (_hasAlreadyPurchased) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to purchase notes')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notePrice = _getNotePrice();
      final noteId = _getNoteId();
      final sellerId = _getSellerId();

      if (noteId.isEmpty) {
        throw Exception('Invalid note ID');
      }
      
      if (sellerId.isEmpty) {
        throw Exception('Invalid seller ID');
      }

      if (notePrice <= 0) {
        _handleFreePurchase();
        return;
      }

      final transaction = await _transactionService.createTransaction(
        buyerId: currentUser.uid,
        sellerId: sellerId,
        noteId: noteId,
        salePrice: notePrice,
        paymentMethod: 'dummy',
      );

      final success = await _transactionService.completeTransaction(
        transactionId: transaction.transactionId,
        paymentId: 'dummy_payment_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (success) {
        setState(() {
          _hasAlreadyPurchased = true;
        });

        _showSuccessDialog();
      } else {
        throw Exception('Payment processing failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleFreePurchase() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Free note added to your collection!')),
    );
    setState(() {
      _hasAlreadyPurchased = true;
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have successfully purchased "${_getNoteTitle()}"'),
            const SizedBox(height: 12),
            const Text('Rewards earned:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Points: +${(_getNotePrice() * 0.02).round()}'),
            const SizedBox(height: 8),
            const Text('The note has been added to your collection.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _addToCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_getNoteTitle()} added to cart!')),
    );
  }

  // Helper methods to get note data regardless of type
  String _getNoteTitle() {
    if (widget.note is NoteItem) {
      return (widget.note as NoteItem).title;
    } else if (widget.note is NoteModel) {
      return (widget.note as NoteModel).title;
    }
    return 'Unknown';
  }

  String _getNoteSubject() {
    if (widget.note is NoteItem) {
      return (widget.note as NoteItem).subject;
    } else if (widget.note is NoteModel) {
      return (widget.note as NoteModel).subject;
    }
    return 'Unknown';
  }

  double _getNotePrice() {
    if (widget.note is NoteItem) {
      return (widget.note as NoteItem).price;
    } else if (widget.note is NoteModel) {
      final noteModel = widget.note as NoteModel;
      return noteModel.price ?? 0.0;
    }
    return 0.0;
  }

  double _getNoteRating() {
    if (widget.note is NoteItem) {
      return (widget.note as NoteItem).rating;
    } else if (widget.note is NoteModel) {
      return (widget.note as NoteModel).rating;
    }
    return 0.0;
  }

  String _getNoteId() {
    if (widget.note is NoteItem) {
      return (widget.note as NoteItem).id;
    } else if (widget.note is NoteModel) {
      return (widget.note as NoteModel).noteId;
    }
    return '';
  }

  String _getSellerId() {
    if (widget.note is NoteItem) {
      return 'dummy_seller_123';
    } else if (widget.note is NoteModel) {
      return (widget.note as NoteModel).ownerUid;
    }
    return 'dummy_seller_123';
  }

  bool _isDonation() {
    if (widget.note is NoteModel) {
      return (widget.note as NoteModel).isDonation;
    }
    return _getNotePrice() == 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.favorite_border, color: theme.colorScheme.onSurface),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.share, color: theme.colorScheme.onSurface),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // PDF Preview Section
                PdfPreviewWidget(
                  hasAlreadyPurchased: _hasAlreadyPurchased,
                  isOwnNote: _isOwnNote,
                  onTap: () {
                  },
                ),
                
                const SizedBox(height: 20),
                
                NoteHeaderWidget(
                  title: _getNoteTitle(),
                  rating: _getNoteRating(),
                  price: _getNotePrice(),
                  isDonation: _isDonation(),
                ),
                
                const SizedBox(height: 16),
                
                StatusIndicatorsWidget(
                  hasAlreadyPurchased: _hasAlreadyPurchased,
                ),
                
                NoteDetailsWidget(
                  subject: _getNoteSubject(),
                  isDonation: _isDonation(),
                  price: _getNotePrice(),
                ),
                
                PurchaseStatusWidget(
                  isOwnNote: _isOwnNote,
                  hasAlreadyPurchased: _hasAlreadyPurchased,
                ),
                
                const SizedBox(height: 100), 
              ],
            ),
          ),
          
          BottomActionBarWidget(
            isOwnNote: _isOwnNote,
            hasAlreadyPurchased: _hasAlreadyPurchased,
            isDonation: _isDonation(),
            price: _getNotePrice(),
            isLoading: _isLoading,
            onAddToCart: _addToCart,
            onPurchase: _handlePurchase,
          ),
        ],
      ),
    );
  }
}