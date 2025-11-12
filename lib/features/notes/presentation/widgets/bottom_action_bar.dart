import 'package:flutter/material.dart';

class BottomActionBarWidget extends StatelessWidget {
  final bool isOwnNote;
  final bool hasAlreadyPurchased;
  final bool isDonation;
  final double price;
  final bool isLoading;
  final VoidCallback? onAddToCart;
  final VoidCallback? onPurchase;

  const BottomActionBarWidget({
    super.key,
    required this.isOwnNote,
    required this.hasAlreadyPurchased,
    required this.isDonation,
    required this.price,
    required this.isLoading,
    this.onAddToCart,
    this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Add to Cart button
            if (!isOwnNote && !hasAlreadyPurchased)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: isLoading ? null : onAddToCart,
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            
            if (!isOwnNote && !hasAlreadyPurchased)
              const SizedBox(width: 12),
            
            // Main action button
            Expanded(
              child: ElevatedButton(
                onPressed: (isOwnNote || hasAlreadyPurchased || isLoading) ? null : onPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOwnNote 
                      ? theme.colorScheme.outline.withOpacity(0.3)
                      : hasAlreadyPurchased 
                          ? Colors.green 
                          : theme.colorScheme.primary,
                  foregroundColor: isOwnNote
                      ? theme.colorScheme.onSurfaceVariant
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOwnNote ? theme.colorScheme.onSurfaceVariant : Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _getButtonText(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getButtonText() {
    if (isOwnNote) {
      return 'Cannot Buy Own Note';
    }
    if (hasAlreadyPurchased) {
      return 'Already Purchased';
    }
    if (isDonation) {
      return 'Get Free Note';
    }
    return 'Pay Now ₹${price.toStringAsFixed(0)}';
  }
}