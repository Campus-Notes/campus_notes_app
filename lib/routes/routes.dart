import 'package:campus_notes_app/features/profile/presentation/pages/bank_details.dart';
import 'package:flutter/material.dart';
import 'route_names.dart';
import '../features/onboarding/presentation/pages/splash_screen.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/onboarding/presentation/pages/landingpage.dart';
import '../features/authentication/presentation/pages/auth_screen.dart';
import '../features/notes/presentation/pages/cart_page.dart';
import '../features/notes/presentation/pages/shopping_cart.dart';
import '../features/notes/presentation/pages/my_sold_notes_page.dart';
import '../features/profile/presentation/pages/wallet_page.dart';
import '../features/profile/presentation/pages/points_page.dart';
import '../features/notes/presentation/pages/donations_page.dart';
import '../features/profile/presentation/pages/report_issue_page.dart';
import '../features/info/presentation/pages/about_page.dart';
import '../features/profile/presentation/pages/help_support_page.dart';
import '../features/profile/presentation/pages/privacy_policy_page.dart';
import '../features/profile/presentation/pages/settings_page.dart';
import '../features/profile/presentation/pages/user_info_page.dart';
import '../features/profile/presentation/pages/change_password_page.dart';
import '../features/home/presentation/pages/new_search_page.dart';
import '../common_widgets/bottom_navbar.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.splash: (_) => const SplashScreen(), 
        AppRoutes.onboarding: (_) => const OnboardingPage(), 
        AppRoutes.shell: (_) => const MainShell(),
        AppRoutes.landing: (_) => const LandingScreen(), 
        AppRoutes.authentication: (_) => const AuthenticationScreen(),
        AppRoutes.search: (_) => const NewSearchPage(),
        AppRoutes.cart: (_) => const CartPage(),
        AppRoutes.purchases: (_) => const PurchasesPage(),
        AppRoutes.manageNotes: (_) => const MySoldNotesPage(),
        AppRoutes.wallet: (_) => const WalletPage(),
        AppRoutes.points: (_) => const PointsPage(),
        AppRoutes.donations: (_) => const DonationsPage(),
        AppRoutes.reportIssue: (_) => const ReportIssuePage(),
        AppRoutes.about: (_) => const AboutPage(),
        AppRoutes.helpSupport: (_) => const HelpSupportPage(), 
        AppRoutes.privacyPolicy: (_) => const PrivacyPolicyPage(), 
        AppRoutes.settings: (_) => const SettingsPage(),
        AppRoutes.userProfile: (_) => const UserProfilePage(),
        AppRoutes.changePassword: (_) => const ChangePasswordPage(),
        AppRoutes.bankDetails: (_) => const BankDetailsPage(),
      };
}