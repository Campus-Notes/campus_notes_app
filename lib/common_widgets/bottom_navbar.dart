import 'package:campus_notes_app/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/notes/presentation/pages/sell_note.dart';
import '../features/notes/presentation/pages/cart_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const UploadPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark 
                  ? AppColors.surfaceDark 
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(40),
              border: theme.brightness == Brightness.light
                ? Border.all(
                    color: const Color.fromRGBO(0, 0, 0, 0.12),
                    width: 1.5,
                  )
                : null,
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  spreadRadius: -5,
                  offset: const Offset(0, 10),
                  color: Colors.black.withOpacity(0.15),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                final icons = [
                  Icons.home_outlined,
                  Icons.upload_outlined,
                  Icons.shopping_cart_outlined,
                  Icons.person_outline,
                ];

                return GestureDetector(
                  onTap: () => _onItemTapped(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _selectedIndex == index
                          ? AppColors.primary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icons[index],
                      size: 28,
                      color: _selectedIndex == index
                          ? Colors.white
                          : (theme.brightness == Brightness.dark 
                              ? AppColors.textSecondaryDark 
                              : AppColors.textSecondaryLight),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
