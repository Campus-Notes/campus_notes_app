import 'package:flutter/material.dart';
import 'package:flutter_auth_ui/data/dummy_data.dart';
import 'package:flutter_auth_ui/pages/settings_page.dart';
import 'package:flutter_auth_ui/shell/main_shell.dart';
import 'pages/landingpage.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/note_detail_page.dart';
import 'pages/checkout_page.dart';
import 'pages/purchases_page.dart';
import 'pages/reminders_page.dart';
import 'pages/notes_management_page.dart';
import 'pages/wallet_page.dart';
import 'pages/donations_page.dart';
import 'pages/report_issue_page.dart';
import 'pages/about_page.dart';
import 'pages/splash_screen.dart'; 
import 'pages/onboarding_page.dart'; 
import 'pages/help_support_page.dart'; 
import 'pages/privacy_policy_page.dart'; 
import 'routes.dart';
import 'theme/app_theme.dart'; 

void main() => runApp(const CampusNotesApp());

class CampusNotesApp extends StatelessWidget {
  const CampusNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Notes+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.material(ThemeData.light()), 
      initialRoute: AppRoutes.splash, 
      routes: {
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
  }
}