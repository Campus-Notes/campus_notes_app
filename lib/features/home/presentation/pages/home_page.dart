import 'package:campus_notes_app/features/home/presentation/widgets/buy_mode_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    {'icon': Icons.all_inclusive, 'label': 'All', 'subject': 'All'},
    {'icon': Icons.computer, 'label': 'Computer Science', 'subject': 'Computer Science'},
    {'icon': Icons.calculate, 'label': 'Mathematics', 'subject': 'Mathematics'},
    {'icon': Icons.science, 'label': 'Physics', 'subject': 'Physics'},
    {'icon': Icons.biotech, 'label': 'Biology', 'subject': 'Biology'},
    {'icon': Icons.science_outlined, 'label': 'Chemistry', 'subject': 'Chemistry'},
    {'icon': Icons.menu_book, 'label': 'English', 'subject': 'English'},
    {'icon': Icons.account_balance, 'label': 'Social', 'subject': 'Social'},
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

  void _onCategoryChanged(int index) {
    setState(() {
      selectedCategoryIndex = index;
    });
    
    // Filter notes by subject
    final notesController = Provider.of<NotesController>(context, listen: false);
    final selectedSubject = categories[index]['subject'] as String;
    
    if (selectedSubject == 'All') {
      notesController.loadTrendingNotes();
    } else {
      notesController.getNotesBySubject(selectedSubject);
    }
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
                    onSearchTap: () {
                      Navigator.pushNamed(context, '/search');
                    },
                    onChatTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ChatListPage()),
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
                ],
              ),
            ),

            if (isBuyMode)
              CategorySelector(
                selectedIndex: selectedCategoryIndex,
                categories: categories,
                onCategoryChanged: _onCategoryChanged,
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
