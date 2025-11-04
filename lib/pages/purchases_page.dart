import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
class PurchasesPage extends StatelessWidget{
  const PurchasesPage({super.key});
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Purchases',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemBuilder: (_,i){
          final p= dummyPurchases[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary.withValues(alpha: 0.08)
              ),
              child: const Icon(Icons.description, color: AppColors.primary),
            ),
            title: Text(p.title),
            subtitle: Text('${p.subject} • ${p.date.toLocal().toString().split(' ').first}'),
            trailing: Text('₹${p.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700)),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open note'))),
          );
        },
        separatorBuilder: (_,__) => const Divider(height: 1),
        itemCount: dummyPurchases.length,
      ),
    );
  }
}