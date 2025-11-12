import 'package:campus_notes_app/features/home/presentation/widgets/buy_mode_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../info/presentation/pages/reminders_page.dart';
import '../../../chat/presentation/pages/chat_list_page.dart'; 
import '../../../notes/presentation/controller/notes_controller.dart';
import '../widgets/location_header.dart';
import '../widgets/mode_selector.dart';
import '../widgets/category_selector.dart';
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
  void initState() {
    super.initState();
    // Load notes when the home page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notesController = Provider.of<NotesController>(context, listen: false);
      notesController.loadTrendingNotes(); // Load trending notes excluding own notes
    });
  }

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
                    onSearchTap: () {},
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
                  const SizedBox(height: 12),

                  // ✅ Messages Button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.chat),
                    label: const Text('Messages'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatListPage(),
                        ),
                      );
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
                    ? const BuyModeContent()
                    : _buildSellModeContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellModeContent() {
    return const Padding(
      key: ValueKey('sell_mode'),
      padding: EdgeInsets.all(16),
      child: SellModeContent(),
    );
  }
}
