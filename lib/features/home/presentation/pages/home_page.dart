import 'package:flutter/material.dart';
import '../../../../data/dummy_data.dart';
import '../../../notes/presentation/widgets/note_card.dart';
import '../../../info/presentation/pages/reminders_page.dart';
import '../widgets/location_header.dart';
import '../widgets/mode_selector.dart';
import '../widgets/category_selector.dart';
import '../widgets/featured_note_card.dart';
import '../widgets/popular_note_card.dart';
import '../widgets/section_header.dart';
import '../widgets/sell_mode_content.dart';

class HomePage extends StatefulWidget {
  static const String route = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedUniversity = 'Amrita University';
  bool isBuyMode = true; 
  int selectedCategoryIndex = 0;

  final List<String> universities = [
    'Amrita University',
    'Stanford University',
    'MIT Campus',
    'Harvard University',
    'Oxford University',
  ];

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.computer, 'label': 'Computer Science'},
    {'icon': Icons.calculate, 'label': 'Mathematics'},
    {'icon': Icons.science, 'label': 'Physics'},
    {'icon': Icons.biotech, 'label': 'Biology'},
    {'icon': Icons.account_balance, 'label': 'Economics'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LocationHeader(
                    selectedUniversity: selectedUniversity,
                    universities: universities,
                    onUniversityChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedUniversity = newValue;
                        });
                      }
                    },
                    onSearchTap: () {
                    },
                    onNotificationTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RemindersPage()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ModeSelector(
                    isBuyMode: isBuyMode,
                    onModeChanged: (bool buyMode) {
                      setState(() {
                        isBuyMode = buyMode;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            if (isBuyMode)
              CategorySelector(
                selectedIndex: selectedCategoryIndex,
                categories: categories,
                onCategoryChanged: (int index) {
                  setState(() {
                    selectedCategoryIndex = index;
                  });
                },
              ),
            
            // Main content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isBuyMode 
                  ? _buildBuyModeContent() 
                  : _buildSellModeContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyModeContent() {
    return ListView(
      key: const ValueKey('buy_mode'),
      padding: const EdgeInsets.all(16),
      children: [
        const FeaturedNoteCard(),
        const SizedBox(height: 24),
        
        SectionHeader(
          title: 'Popular Notes',
          actionText: 'See All',
          onActionTap: () {
          },
        ),
        const SizedBox(height: 12),
        
        for (final note in dummyNotes.take(3))
          PopularNoteCard(note: note),
        
        const SizedBox(height: 20),
        
        SectionHeader(
          title: 'Recently Added',
          actionText: 'View More',
          onActionTap: () {
            // TODO: Navigate to recent notes page
          },
        ),
        const SizedBox(height: 12),
        
        // Recently added notes
        for (final note in dummyNotes.reversed.take(3))
          NoteCard(item: note),
      ],
    );
  }

  Widget _buildSellModeContent() {
    return const SingleChildScrollView(
      key: ValueKey('sell_mode'),
      padding: EdgeInsets.all(16),
      child: SellModeContent(),
    );
  }
}