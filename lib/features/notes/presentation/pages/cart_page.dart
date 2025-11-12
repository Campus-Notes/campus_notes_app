import 'package:flutter/material.dart';
import '../../../../data/dummy_data.dart';
import '../widgets/cart_card.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<NoteItem> cartItems = [
    // Add some dummy cart items for demonstration
    const NoteItem(
      id: 'cart1',
      title: 'Data Structures: Exam Cheatsheet',
      subject: 'CS - Data Structures',
      seller: 'Ananya Sharma',
      price: 59.0,
      rating: 4.7,
      pages: 18,
      tags: ['cs', 'dsa', 'semester-4'],
    ),
    const NoteItem(
      id: 'cart2',
      title: 'Microeconomics Quick Revision',
      subject: 'Economics',
      seller: 'Rohit Verma',
      price: 39.0,
      rating: 4.4,
      pages: 12,
      tags: ['eco', 'first-year'],
    ),
  ];

  Map<String, int> quantities = {
    'cart1': 1,
    'cart2': 1,
  };

  void _updateQuantity(String itemId, int change) {
    setState(() {
      quantities[itemId] = (quantities[itemId] ?? 1) + change;
      if (quantities[itemId]! <= 0) {
        quantities.remove(itemId);
        cartItems.removeWhere((item) => item.id == itemId);
      }
    });
  }

  double get subtotal {
    return cartItems.fold(0, (sum, item) {
      return sum + (item.price * (quantities[item.id] ?? 1));
    });
  }

  double get deliveryFee => 2.0;
  double get discount => subtotal * 0.05; // 5% discount
  double get total => subtotal + deliveryFee - discount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cart',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some notes to get started',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      
                      return CartCard(
                        item: item,
                        onDelete: () => _updateQuantity(item.id, -1),
                      );
                    },
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                          Text('₹${subtotal.toStringAsFixed(0)}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivery', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                          Text('₹${deliveryFee.toStringAsFixed(0)}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Discount', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                          Text('-₹${discount.toStringAsFixed(0)}', 
                               style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '₹${total.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Proceeding to checkout...')),
                            );
                          },
                          child: const Text('Buy Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}