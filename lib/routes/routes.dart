import 'package:flutter/material.dart';
import 'route_names.dart';
import '../features/onboarding/presentation/pages/splash_screen.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/onboarding/presentation/pages/landingpage.dart';
import '../features/authentication/presentation/pages/login_page.dart';
import '../features/authentication/presentation/pages/register_page.dart';
import '../features/notes/presentation/pages/purchases_page.dart';
import '../features/info/presentation/pages/reminders_page.dart';
import '../features/notes/presentation/pages/notes_management_page.dart';
import '../features/payment/presentation/pages/wallet_page.dart';
import '../features/notes/presentation/pages/donations_page.dart';
import '../features/info/presentation/pages/report_issue_page.dart';
import '../features/info/presentation/pages/about_page.dart';
import '../features/info/presentation/pages/help_support_page.dart';
import '../features/info/presentation/pages/privacy_policy_page.dart';
import '../features/info/presentation/pages/settings_page.dart';
import '../common_widgets/bottom_navbar.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.splash: (_) => const SplashScreen(), 
        AppRoutes.onboarding: (_) => const OnboardingPage(), 
        AppRoutes.shell: (_) => const MainShell(),
        AppRoutes.landing: (_) => const LandingScreen(), 
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.purchases: (_) => const PurchasesPage(),
        AppRoutes.reminders: (_) => const RemindersPage(),
        AppRoutes.manageNotes: (_) => const NotesManagementPage(),
        AppRoutes.wallet: (_) => const WalletPage(),
        AppRoutes.donations: (_) => const DonationsPage(),
        AppRoutes.reportIssue: (_) => const ReportIssuePage(),
        AppRoutes.about: (_) => const AboutPage(),
        AppRoutes.helpSupport: (_) => const HelpSupportPage(), 
        AppRoutes.privacyPolicy: (_) => const PrivacyPolicyPage(), 
        AppRoutes.settings: (_) => const SettingsPage(),
      };
}