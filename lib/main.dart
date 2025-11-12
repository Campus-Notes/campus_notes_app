// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:campus_notes_app/data/dummy_data.dart';
import 'package:campus_notes_app/services/theme_service.dart';
import 'package:campus_notes_app/routes/route_names.dart';
import 'package:campus_notes_app/routes/routes.dart';
import 'package:campus_notes_app/theme/app_theme.dart';
import 'firebase_options.dart';

// ────────────────────── Screens ──────────────────────
import 'features/authentication/presentation/screens/forgot_password_feature.dart';
import 'features/authentication/presentation/screens/reset_password_screen.dart';
import 'features/notes/presentation/pages/note_detail_page.dart';
import 'features/payment/presentation/pages/checkout_page.dart';
import 'features/authentication/presentation/pages/auth_screen.dart';
import 'features/onboarding/presentation/pages/landingpage.dart';
import 'features/onboarding/presentation/pages/splash_screen.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/authentication/presentation/controller/auth_controller.dart';
import 'features/notes/presentation/controller/notes_controller.dart';
import 'features/home/presentation/controller/sell_mode_controller.dart';
import 'features/notes/data/services/note_database_service.dart';

// chat features
import 'features/chat/presentation/controller/chat_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // -------------------------------------------------
  // 1. Load .env (only once)
  // -------------------------------------------------
  await dotenv.load(fileName: ".env");

  // -------------------------------------------------
  // 2. Firebase
  // -------------------------------------------------
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );



  // -------------------------------------------------
  // 4. Theme
  // -------------------------------------------------
  final themeService = ThemeService();
  await themeService.init();

  // -------------------------------------------------
  // 5. API base URL from .env
  // -------------------------------------------------
  final String apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'https://your-api.com';

  // -------------------------------------------------
  // 6. Run the app
  // -------------------------------------------------
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(baseUrl: apiBaseUrl),
        ),
        ChangeNotifierProvider(create: (_) => NotesController()),
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider(create: (_) => ChatController()),
        ChangeNotifierProvider(
          create: (context) {
            final authController = context.read<AuthController>();
            return SellModeController(
              noteDatabaseService: NoteDatabaseService(),
              authController: authController,
            );
          },
        ),
      ],
      child: const CampusNotesApp(),
    ),
  );
}

class CampusNotesApp extends StatelessWidget {
  const CampusNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Campus Notes+',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeService.themeMode,
          initialRoute: AppRoutes.splash,
          routes: {
            ...AppRouter.routes,
            AppRoutes.splash: (_) => const SplashScreen(),
            AppRoutes.onboarding: (_) => const OnboardingPage(),
            AppRoutes.landing: (_) => const LandingScreen(),
            AppRoutes.authentication: (_) => const AuthenticationScreen(),
            AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
          },
          onGenerateRoute: (settings) {
            // ── Note detail ──
            if (settings.name == AppRoutes.noteDetail) {
              final note = settings.arguments as NoteItem;
              return MaterialPageRoute(
                builder: (_) => NoteDetailPage(note: note),
              );
            }

            // ── Checkout ──
            if (settings.name == AppRoutes.checkout) {
              final note = settings.arguments as NoteItem;
              return MaterialPageRoute(
                builder: (_) => CheckoutPage(note: note),
              );
            }

            // ── Reset password (with token) ──
            if (settings.name == AppRoutes.resetPassword) {
              final token = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => ResetPasswordScreen(token: token),
              );
            }

            return null;
          },
        );
      },
    );
  }
}