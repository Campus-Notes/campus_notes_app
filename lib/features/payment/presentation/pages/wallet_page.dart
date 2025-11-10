import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    const balance = 250.0; 
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, size: 28),
                  const SizedBox(width: 12),
                  const Text('Balance', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('₹${balance.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
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
