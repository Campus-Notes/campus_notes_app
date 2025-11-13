import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/route_names.dart';
import '../../../authentication/presentation/controller/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    
    _controller.forward();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // Check authentication state
    final authController = Provider.of<AuthController>(context, listen: false);
    
    if (authController.isLoggedIn) {
      // User is logged in, go to home (main shell)
      Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
    } else {
      // User not logged in, show onboarding
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Image.asset(
                      isDark ? 'assets/icons/dark logo.png' : 'assets/icons/light_logo.png',
                      width: 280,
                      height: 280,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/icons/applogo.png',
                          width: 280,
                          height: 280,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Text(
                      'Affordable Digital Marketplace',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        letterSpacing: 0.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
