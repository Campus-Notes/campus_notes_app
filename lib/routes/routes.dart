import 'package:flutter/material.dart';
import 'route_names.dart';
import '../features/onboarding/presentation/pages/splash_screen.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/onboarding/presentation/pages/landingpage.dart';
import '../features/authentication/presentation/pages/auth_screen.dart';
import '../features/notes/presentation/pages/shopping_cart.dart';
import '../features/info/presentation/pages/reminders_page.dart';
import '../features/notes/presentation/pages/notes_management_page.dart';
import '../features/payment/presentation/pages/wallet_page.dart';
import '../features/notes/presentation/pages/donations_page.dart';
import '../features/info/presentation/pages/report_issue_page.dart';
import '../features/info/presentation/pages/about_page.dart';
import '../features/info/presentation/pages/help_support_page.dart';
import '../features/info/presentation/pages/privacy_policy_page.dart';
import '../features/info/presentation/pages/settings_page.dart';
import '../features/profile/presentation/widgets/user_profile_page.dart';
import '../features/profile/presentation/widgets/change_password.dart';
import '../common_widgets/bottom_navbar.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.splash: (_) => const SplashScreen(), 
        AppRoutes.onboarding: (_) => const OnboardingPage(), 
        AppRoutes.shell: (_) => const MainShell(),
        AppRoutes.landing: (_) => const LandingScreen(), 
        AppRoutes.authentication: (_) => const AuthenticationScreen(),
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
        AppRoutes.userProfile: (_) => const UserProfilePage(),
        AppRoutes.changePassword: (_) => const ChangePasswordPage(),
      };
}