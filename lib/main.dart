import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:campus_notes_app/data/dummy_data.dart';
import 'package:campus_notes_app/services/theme_service.dart';
import 'package:campus_notes_app/services/security_service.dart';
import 'package:campus_notes_app/services/connectivity_service.dart';
import 'package:campus_notes_app/services/notification_service.dart';
import 'package:campus_notes_app/services/verification_service.dart';
import 'package:campus_notes_app/routes/route_names.dart';
import 'package:campus_notes_app/routes/routes.dart';
import 'package:campus_notes_app/theme/app_theme.dart';
import 'firebase_options.dart';

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
import 'features/notes/presentation/controller/cart_controller.dart';
import 'features/home/presentation/controller/sell_mode_controller.dart';
import 'features/notes/data/services/note_database_service.dart';

import 'features/chat/presentation/controller/chat_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await SecurityService.disableScreenshots();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );

  final themeService = ThemeService();
  await themeService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  final verificationService = VerificationService(
    notificationService: notificationService,
  );

  final connectivityService = ConnectivityService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(),
        ),
        ChangeNotifierProvider(create: (_) => NotesController()),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: notificationService),
        ChangeNotifierProvider.value(value: verificationService),
        ChangeNotifierProvider.value(value: connectivityService),
        ChangeNotifierProvider(create: (_) => ChatController()),
        ChangeNotifierProvider(
          create: (context) {
            final authController = context.read<AuthController>();
            final verificationService = context.read<VerificationService>();
            return SellModeController(
              noteDatabaseService: NoteDatabaseService(),
              authController: authController,
              verificationService: verificationService,
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
            if (settings.name == AppRoutes.noteDetail) {
              final note = settings.arguments as NoteItem;
              return MaterialPageRoute(
                builder: (_) => NoteDetailPage(note: note),
              );
            }

            if (settings.name == AppRoutes.checkout) {
              final note = settings.arguments as NoteItem;
              return MaterialPageRoute(
                builder: (_) => CheckoutPage(note: note),
              );
            }

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
