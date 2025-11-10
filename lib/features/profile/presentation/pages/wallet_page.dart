import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../common_widgets/app_bar.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    const balance = 250.0; 
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'Wallet',
        usePremiumBackIcon: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07), 
                borderRadius: BorderRadius.circular(12),
                border: Theme.of(context).brightness == Brightness.dark
                    ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined, 
                    size: 28,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.primary.withValues(alpha: 0.8)
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Balance', 
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Text(
                    '₹${balance.toStringAsFixed(0)}', 
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdraw'))), child: const Text('Withdraw')),
          ],
        ),
      ),
    );
  }
}
