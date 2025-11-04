import 'package:flutter/material.dart';
import '../data/dummy_data.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key, required this.note});
  final NoteItem note;

  void _pay(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Razorpay flow ')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = note.price;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(note.subject),
              trailing: Text('₹${note.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Subtotal'),
                const Spacer(),
                Text('₹${total.toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Text('Fees'),
                Spacer(),
                Text('₹0'),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            Row(
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('₹${total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _pay(context),
              child: const Text('Pay with Razorpay'),
            ),
          ],
        ),
      ),
    );
  }
}