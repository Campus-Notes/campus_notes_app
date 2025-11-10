import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import 'sell_note.dart';
import 'donations_page.dart';
import '../widgets/sold_note_card.dart';

class MySoldNotesPage extends StatelessWidget {
  const MySoldNotesPage({super.key});

  static const List<Map<String, dynamic>> soldNotes = [
    {
      'id': '1',
      'title': 'Data Structures and Algorithms Notes',
      'subject': 'Computer Science',
      'price': 149.0,
      'dateSold': '2024-11-08',
      'buyerCount': 3,
      'totalEarned': 447.0,
      'rating': 4.8,
    },
    {
      'id': '2', 
      'title': 'Calculus Problem Sets',
      'subject': 'Mathematics',
      'price': 99.0,
      'dateSold': '2024-11-05',
      'buyerCount': 5,
      'totalEarned': 495.0,
      'rating': 4.9,
    },
    {
      'id': '3',
      'title': 'Physics Lab Reports',
      'subject': 'Physics',
      'price': 79.0,
      'dateSold': '2024-11-03',
      'buyerCount': 2,
      'totalEarned': 158.0,
      'rating': 4.5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    double totalEarnings = soldNotes.fold(0.0, (sum, note) => sum + note['totalEarned']);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Sold Notes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DonationsPage()),
            ),
            icon: const Icon(Icons.volunteer_activism_outlined, size: 20),
            label: const Text('Donate', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Earnings',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${totalEarnings.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UploadPage()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Sell New Note',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: soldNotes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No notes sold yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start by selling your first note!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: soldNotes.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            'My Sold Notes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }
                      
                      final note = soldNotes[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SoldNoteCard(note: note),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}