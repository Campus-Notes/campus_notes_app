import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_notes_app/data/dummy_data.dart';
import 'package:campus_notes_app/services/theme_service.dart';
import 'package:campus_notes_app/routes/route_names.dart';
import 'package:campus_notes_app/routes/routes.dart';
import 'package:campus_notes_app/theme/app_theme.dart';
import 'firebase_options.dart';

// Features
import 'features/notes/presentation/pages/note_detail_page.dart';
import 'features/payment/presentation/pages/checkout_page.dart';
import 'features/authentication/presentation/pages/auth_screen.dart';
import 'features/onboarding/presentation/pages/landingpage.dart';
import 'features/onboarding/presentation/pages/splash_screen.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/authentication/presentation/controller/auth_controller.dart';

// chat features
import 'features/chat/presentation/controller/chat_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final themeService = ThemeService();
  await themeService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider(create: (_) => ChatController()),
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
          },

          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.noteDetail) {
              final note = settings.arguments as NoteItem;
              return MaterialPageRoute(builder: (_) => NoteDetailPage(note: note));
            }
            if (settings.name == AppRoutes.checkout) {
              final note = settings.arguments as NoteItem;
              return MaterialPageRoute(builder: (_) => CheckoutPage(note: note));
            }
            return null;
          },
        );
      },
    );
  }
}