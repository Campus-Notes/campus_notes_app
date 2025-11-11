import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/route_names.dart';
import '../../../../theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Welcome to CampusNotes+',
      'description': 'Buy, sell, and share high-quality academic notes with ease.',
      'image': 'assets/images/onboarding1.png',
    },
    {
      'title': 'Find Notes Fast',
      'description': 'Search by subject, semester, or professor. Never miss a note again.',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': 'Upload & Earn',
      'description': 'Share your notes and earn money while helping others succeed.',
      'image': 'assets/images/onboarding3.png',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.authentication);
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.authentication);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
  alignment: Alignment.topRight,
  child: Padding(
    padding: const EdgeInsets.only(top: 25, right: 12),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _skip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
        child: Text(
          "Skip",
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.8)
                : Colors.black.withValues(alpha: 0.7),
          ),
        ),
      ),
    ),
  ),
),


            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          page['image']!,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 40),

                        Text(
                          page['title']!,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        Text(
                          page['description']!,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            height: 1.5,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index 
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.primaryLight
                            : AppColors.primary)
                        : (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.mutedDark
                            : AppColors.muted),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                        foregroundColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}