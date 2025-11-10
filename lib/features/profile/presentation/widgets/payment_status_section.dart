import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../authentication/data/models/user_model.dart';
import 'status_card.dart';

class PaymentStatusSection extends StatelessWidget {
  final UserModel user;

  const PaymentStatusSection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Payment Methods Status',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatusCard(
                  title: 'UPI',
                  isProvided: user.isUPIProvided,
                  icon: Icons.account_balance_wallet,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatusCard(
                  title: 'Bank Account',
                  isProvided: user.isBankDetailsProvided,
                  icon: Icons.account_balance,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}