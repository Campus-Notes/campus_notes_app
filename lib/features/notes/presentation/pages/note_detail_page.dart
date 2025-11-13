import 'package:campus_notes_app/features/notes/data/models/note_model.dart';
import 'package:campus_notes_app/features/notes/data/services/note_database_service.dart';
import 'package:campus_notes_app/features/payment/data/services/transaction_service.dart';
import 'package:campus_notes_app/features/payment/data/services/razorpay_service.dart';
import 'package:campus_notes_app/features/chat/presentation/pages/chat_thread_page.dart';
import 'package:campus_notes_app/features/chat/presentation/controller/chat_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_notes_app/theme/app_theme.dart';
import 'package:campus_notes_app/common_widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../../data/dummy_data.dart';
import '../widgets/pdf_preview.dart';
import '../widgets/note_header.dart';
import '../widgets/status_indicators.dart';
import '../widgets/note_details.dart';
import '../widgets/purchase_status.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/reviews_section.dart';
import '../controller/cart_controller.dart';

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
  RazorpayService? _razorpayService;
  
  bool _isLoading = true; 
  bool _isOwnNote = false;
  bool _hasAlreadyPurchased = false;
  bool _isPurchasing = false; 

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    
    if (widget.note is NoteModel) {
      final noteModel = widget.note as NoteModel;
      debugPrint('🔍 NoteDetailPage initState - Full NoteModel: $noteModel');
      debugPrint('🔍 NoteDetailPage initState - Description field: "${noteModel.description}"');
      debugPrint('🔍 NoteDetailPage initState - Description is null: ${noteModel.description == null}');
      debugPrint('🔍 NoteDetailPage initState - Description isEmpty: ${noteModel.description?.isEmpty}');
    }
    
    _checkNoteOwnershipAndPurchase();
  }

  @override
  void dispose() {
    _razorpayService?.dispose();
    super.dispose();
  }

  Future<String> _getSellerName(String sellerId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(sellerId)
          .get();

      return doc.data()?['firstName'] ?? 'Seller';
    } catch (_) {
      return 'Seller';
    }
  }


  Future<void> _checkNoteOwnershipAndPurchase() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }

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
        if (!_isOwnNote && !noteModel.isDonation) {
          _hasAlreadyPurchased = await _noteDatabaseService.hasUserPurchased(
            noteModel.noteId,
            currentUser.uid, 
          );
        } else if (noteModel.isDonation) {
          _hasAlreadyPurchased = await _noteDatabaseService.hasUserPurchased(
            noteModel.noteId,
            currentUser.uid, 
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking note ownership: $e');
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

    setState(() => _isPurchasing = true);

    try {
      final notePrice = _getNotePrice();
      final noteId = _getNoteId();
      final sellerId = _getSellerId();
      final noteTitle = _getNoteTitle();

      debugPrint('💳 Purchase attempt:');
      debugPrint('   - Note ID: "$noteId" (isEmpty: ${noteId.isEmpty})');
      debugPrint('   - Seller ID: "$sellerId" (isEmpty: ${sellerId.isEmpty})');
      debugPrint('   - Note Price: $notePrice');
      debugPrint('   - Note Type: ${widget.note.runtimeType}');

      if (noteId.isEmpty) {
        throw Exception('Invalid note ID');
      }
      
      if (sellerId.isEmpty) {
        throw Exception('Invalid seller ID');
      }

      if (notePrice <= 0) {
        // Handle free note (donation)
        await _handleFreePurchase(noteId, currentUser.uid);
        return;
      }

      // Get user details for Razorpay
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      final userData = userDoc.data() ?? {};
      final userName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
      final userEmail = currentUser.email ?? '';
      final userPhone = userData['phone'] ?? '';

      // Create a pending transaction
      final transaction = await _transactionService.createTransaction(
        buyerId: currentUser.uid,
        sellerId: sellerId,
        noteId: noteId,
        salePrice: notePrice,
        paymentMethod: 'razorpay',
      );

      // Initiate Razorpay payment
      if (_razorpayService == null) {
        throw Exception('Razorpay service not initialized');
      }

      await _razorpayService!.payForNote(
        amount: notePrice,
        noteTitle: noteTitle,
        userName: userName,
        userEmail: userEmail,
        userPhone: userPhone,
        onSuccess: (paymentId, orderId) async {
          // Payment successful, complete the transaction
          try {
            final success = await _transactionService.completeTransaction(
              transactionId: transaction.transactionId,
              paymentId: paymentId,
            );

            if (success && mounted) {
              setState(() {
                _hasAlreadyPurchased = true;
                _isPurchasing = false;
              });
              _showSuccessDialog();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment completed but failed to process: ${e.toString()}'),
                  backgroundColor: AppColors.error,
                ),
              );
              setState(() => _isPurchasing = false);
            }
          }
        },
        onError: (error) async {
          // Payment failed
          await _transactionService.cancelTransaction(
            transaction.transactionId,
            'Payment failed: $error',
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment failed: $error'),
                backgroundColor: AppColors.error,
              ),
            );
            setState(() => _isPurchasing = false);
          }
        },
        onCancel: () async {
          // Payment cancelled by user
          await _transactionService.cancelTransaction(
            transaction.transactionId,
            'Payment cancelled by user',
          );
          
          if (mounted) {
            setState(() => _isPurchasing = false);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() => _isPurchasing = false);
      }
    }
  }

  Future<void> _openChat() async {
    final sellerId = _getSellerId();
    final currentUser = _auth.currentUser;

    if (sellerId.isEmpty || currentUser == null) return;

    final chatController = context.read<ChatController>();

    final chatId = await chatController.createOrGetChat(sellerId);

    if (!mounted) return;  // ✅ FIX HERE

    final sellerName = await _getSellerName(sellerId);

    if (!mounted) return;  // optional second check

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatThreadPage(
          chatId: chatId!,
          peerId: sellerId,
          peerName: sellerName,
        ),
      ),
    );
  }


  Future<void> _handleFreePurchase(String noteId, String userId) async {
    try {
      // For free notes, just record the "purchase" (access)
      await _noteDatabaseService.addPurchase(
        noteId: noteId,
        uid: userId,
        name: _auth.currentUser?.displayName ?? 'Unknown',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Free note added to your collection!')),
        );
        setState(() {
          _hasAlreadyPurchased = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to access note: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
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
            Text('• Points: +${(_getNotePrice() * 0.02).toStringAsFixed(2)}'),
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
    // Only allow adding NoteModel to cart (not dummy NoteItem)
    if (widget.note is NoteModel) {
      final cartController = context.read<CartController>();
      final noteModel = widget.note as NoteModel;
      
      if (cartController.isInCart(noteModel.noteId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('${noteModel.title} is already in your cart'),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'VIEW CART',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        cartController.addToCart(noteModel);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('${noteModel.title} added to cart!'),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'VIEW CART',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      // For dummy data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_getNoteTitle()} added to cart!')),
      );
    }
  }

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
      debugPrint('💰 _getSellerId - Note is NoteItem, returning empty string');
      return ''; 
    } else if (widget.note is NoteModel) {
      final noteModel = widget.note as NoteModel;
      final sellerId = noteModel.ownerUid;
      debugPrint('💰 _getSellerId - Note is NoteModel');
      debugPrint('💰 _getSellerId - ownerUid: "$sellerId"');
      debugPrint('💰 _getSellerId - ownerUid isEmpty: ${sellerId.isEmpty}');
      debugPrint('💰 _getSellerId - Full NoteModel: $noteModel');
      return sellerId;
    }
    debugPrint('💰 _getSellerId - Note is neither type, returning empty string');
    return '';
  }

  String? _getNoteDescription() {
    if (widget.note is NoteItem) {
      return null; // Dummy data doesn't have description
    } else if (widget.note is NoteModel) {
      final noteModel = widget.note as NoteModel;
      final description = noteModel.description;
      return description;
    }
    return null;
  }

  int _getPageCount() {
    if (widget.note is NoteItem) {
      return 0; // Dummy data doesn't have page count
    } else if (widget.note is NoteModel) {
      return (widget.note as NoteModel).pageCount;
    }
    return 0;
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
    final sellerId = _getSellerId();
    final showChatButton = !_isOwnNote && sellerId.isNotEmpty && _auth.currentUser != null;

    
    if (_isLoading) {
      return const Scaffold(
        appBar: CustomAppBar(
          text: 'Buy Note',
          usePremiumBackIcon: true,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(  
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        text: _getNoteTitle(),
        usePremiumBackIcon: true,
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
                  note: widget.note,
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
                  description: _getNoteDescription(),
                  pageCount: _getPageCount(),
                ),
                
                const SizedBox(height: 20),
                
                // Reviews Section - only show for NoteModel (not dummy data)
                if (widget.note is NoteModel)
                  ReviewsSectionWidget(
                    noteId: _getNoteId(),
                  ),
                
                PurchaseStatusWidget(
                  isOwnNote: _isOwnNote,
                  hasAlreadyPurchased: _hasAlreadyPurchased,
                ),

                if (showChatButton)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ElevatedButton.icon(
                      onPressed: _openChat,
                      icon: const Icon(Icons.chat),
                      label: const Text("Chat with Owner"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
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
            isLoading: _isPurchasing, 
            onAddToCart: _addToCart,
            onPurchase: _handlePurchase,
          ),
        ],
      ),
    );
  }
}