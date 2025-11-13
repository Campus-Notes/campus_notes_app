abstract class AppRoutes {
  // Onboarding & Auth
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const shell = '/';
  static const landing = '/landing';
  static const authentication = '/authentication';
  static const register = '/register';

  // Main Navigation
  static const home = '/home';
  static const search = '/search';
  static const upload = '/upload';
  static const chat = '/chat';
  static const profile = '/profile';
  static const libraryPage = '/library';

  // Notes & Payments
  static const noteDetail = '/note-detail';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const purchases = '/purchases';
  static const reminders = '/reminders';
  static const manageNotes = '/manage-notes';

  // Wallet & Support
  static const wallet = '/wallet';
  static const points = '/points';
  static const donations = '/donations';
  static const reportIssue = '/report-issue';
  static const about = '/about';
  static const helpSupport = '/help-support';
  static const privacyPolicy = '/privacy-policy';

  // Settings & Profile
  static const settings = '/settings';
  static const userProfile = '/user_profile';
  static const changePassword = '/change_password';
  static const bankDetails = '/bank_details';

  // Password Reset Flow
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
}