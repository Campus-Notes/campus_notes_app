import 'package:campus_notes_app/features/notes/presentation/pages/cart_checkout_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../common_widgets/app_bar.dart';
import '../../../../theme/app_theme.dart';
import '../../../payment/data/services/wallet_service.dart';
import '../../../payment/data/services/transaction_service.dart';
import '../../../payment/data/services/razorpay_service.dart';
import '../controller/cart_controller.dart';
import '../widgets/cart_card.dart';
import '../widgets/cart_empty_view.dart';
import 'note_detail_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final WalletService _walletService = WalletService();
  final TransactionService _transactionService = TransactionService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RazorpayService? _razorpayService;

  double _userPoints = 0.0;
  double _pointsToRedeem = 0.0;
  bool _isLoadingPoints = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _loadUserPoints();
  }

  @override
  void dispose() {
    _razorpayService?.dispose();
    super.dispose();
  }

  Future<void> _loadUserPoints() async {
    setState(() => _isLoadingPoints = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final points = await _walletService.getPointsBalance(user.uid);
        setState(() {
          _userPoints = points;
          _isLoadingPoints = false;
        });
      } else {
        setState(() => _isLoadingPoints = false);
      }
    } catch (_) {
      setState(() => _isLoadingPoints = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        text: 'Shopping Cart',
        showBackButton: true,
        centerTitle: true,
        trailing: Consumer<CartController>(
          builder: (context, cart, child) => cart.itemCount == 0
              ? const SizedBox()
              : IconButton(
                  icon: const Icon(Icons.delete_sweep, color: AppColors.error),
                  tooltip: 'Clear cart',
                  onPressed: () => _showClearCartDialog(context, cart),
                ),
        ),
      ),
      body: Consumer<CartController>(
        builder: (context, cart, _) {
          if (cart.itemCount == 0) return const CartEmptyView();
          return _buildCartContent(context, cart);
        },
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartController cart) {
    return Column(
      children: [
        _CartHeader(itemCount: cart.itemCount),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.cartNotes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final note = cart.cartNotes[index];
              return CartCard(
                note: note,
                onDelete: () {
                  cart.removeFromCart(note.noteId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${note.title} removed from cart'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () => cart.addToCart(note),
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NoteDetailPage(note: note),
                  ),
                ),
              );
            },
          ),
        ),
        CartCheckoutSection(
          userPoints: _userPoints,
          pointsToRedeem: _pointsToRedeem,
          isLoadingPoints: _isLoadingPoints,
          isProcessing: _isProcessing,
          onPointsChanged: (value) => setState(() => _pointsToRedeem = value),
          onCheckout: (finalAmount) =>
              _handleCheckout(context, cart, finalAmount),
        ),
      ],
    );
  }

Future<void> _handleCheckout(
    BuildContext context, CartController cart, double finalAmount) async {
  final user = _auth.currentUser;
  if (user == null) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please log in to complete purchase')),
    );
    return;
  }

  if (finalAmount <= 0) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid amount')),
    );
    return;
  }

  setState(() => _isProcessing = true);
  
  try {
    // Get user details for Razorpay
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    
    final userData = userDoc.data() ?? {};
    final userName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
    final userEmail = user.email ?? '';
    final userPhone = userData['phone'] ?? '';

    // Create pending transactions for all items
    final List<String> transactionIds = [];
    for (final note in cart.cartNotes) {
      final txn = await _transactionService.createTransaction(
        buyerId: user.uid,
        sellerId: note.ownerUid,
        noteId: note.noteId,
        salePrice: note.price ?? 0.0,
        paymentMethod: _pointsToRedeem > 0 ? 'points+razorpay' : 'razorpay',
      );
      transactionIds.add(txn.transactionId);
    }

    // Initiate Razorpay payment
    if (_razorpayService == null) {
      throw Exception('Razorpay service not initialized');
    }

    await _razorpayService!.payForCart(
      amount: finalAmount,
      itemCount: cart.cartNotes.length,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      onSuccess: (paymentId, orderId) async {
        // Payment successful, complete all transactions
        try {
          for (final transactionId in transactionIds) {
            await _transactionService.completeTransaction(
              transactionId: transactionId,
              paymentId: paymentId,
            );
          }

          if (mounted) {
            cart.clearCart();
            await _loadUserPoints();
            
            setState(() {
              _isProcessing = false;
              _pointsToRedeem = 0.0;
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
            setState(() => _isProcessing = false);
          }
        }
      },
      onError: (error) async {
        // Payment failed, cancel all transactions
        for (final transactionId in transactionIds) {
          await _transactionService.cancelTransaction(
            transactionId,
            'Payment failed: $error',
          );
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: $error'),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() => _isProcessing = false);
        }
      },
      onCancel: () async {
        // Payment cancelled, cancel all transactions
        for (final transactionId in transactionIds) {
          await _transactionService.cancelTransaction(
            transactionId,
            'Payment cancelled by user',
          );
        }
        
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      },
    );
  } catch (e) {
    if (!mounted) return;
    
    setState(() => _isProcessing = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checkout failed: $e'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

// Also update _showSuccessDialog to check mounted
void _showSuccessDialog() {
  if (!mounted) return;
  
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success),
          SizedBox(width: 8),
          Text('Purchase Successful!'),
        ],
      ),
      content: const Text('Your notes have been added to your library.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: const Text('Continue Shopping'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/library');
          },
          child: const Text('View Library'),
        ),
      ],
    ),
  );
}

  void _showClearCartDialog(BuildContext context, CartController cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Cart'),
        content:
            const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cart.clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart cleared')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  final int itemCount;
  const _CartHeader({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 20),
          const SizedBox(width: 8),
          Text(
            '$itemCount ${itemCount == 1 ? 'item' : 'items'} in cart',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
