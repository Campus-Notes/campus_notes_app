import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../payment/data/models/user_credit_models.dart';

class PointsTransactionCard extends StatelessWidget {
  final PointsCreditModel transaction;

  const PointsTransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.points > 0;
    final icon = _getIconForType(transaction.type);
    final color = isPositive ? AppColors.success : AppColors.error;

    final now = DateTime.now();
    final difference = now.difference(transaction.creditedAt);
    final String timeAgo;

    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes}m ago';
    } else {
      timeAgo = 'Just now';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ??
                      _getTransactionTitle(transaction.type),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isPositive ? '+' : ''}${transaction.points.abs().toStringAsFixed(0)} pts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'selling_bonus':
        return Icons.sell_outlined;
      case 'buying_bonus':
        return Icons.shopping_bag_outlined;
      case 'referral':
        return Icons.person_add_outlined;
      case 'bonus':
        return Icons.card_giftcard_outlined;
      case 'deduction':
        return Icons.remove_circle_outline;
      case 'redemption':
        return Icons.redeem_outlined;
      default:
        return Icons.star_outline;
    }
  }

  String _getTransactionTitle(String type) {
    switch (type) {
      case 'selling_bonus':
        return 'Selling Bonus';
      case 'buying_bonus':
        return 'Purchase Reward';
      case 'referral':
        return 'Referral Bonus';
      case 'bonus':
        return 'Bonus Points';
      case 'deduction':
        return 'Points Deducted';
      case 'redemption':
        return 'Points Redeemed';
      default:
        return 'Points Transaction';
    }
  }
}
