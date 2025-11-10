import 'package:campus_notes_app/common_widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../routes/route_names.dart';
import '../widgets/quick_access_card.dart';
import '../widgets/menu_card.dart';
import '../../../authentication/presentation/controller/auth_controller.dart';
import '../../../authentication/data/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final auth = Provider.of<AuthController>(context, listen: false);
    final user = await auth.getCurrentUser();
    
    if (user != null && mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          text: 'Profile',
          usePremiumBackIcon: true,
          sideIcon: Icons.help_center_rounded,
          onSideIconTap: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.helpSupport,
            (route) => false,
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Use fallback values if user data is not available
    final displayName = _currentUser?.fullName ?? 'Guest User';
    final displayEmail = _currentUser?.email ?? 'No email';
    final points = _currentUser?.points ?? 0;
    final wallet = _currentUser?.walletBalance ?? 0.0;
    final initials = _currentUser != null && _currentUser!.firstName.isNotEmpty
        ? _currentUser!.firstName[0].toUpperCase()
        : 'GU';
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        text: 'Profile',
        usePremiumBackIcon: true,
        sideIcon: Icons.help_center_rounded,
        onSideIconTap: () => Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.helpSupport,
          (route) => false,
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.userProfile),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayEmail,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_currentUser?.university != null && _currentUser!.university.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _currentUser!.university,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white60,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    
                    // Quick access cards
                    Row(
                      children: [
                        Expanded(
                          child: QuickAccessCard(
                            icon: Icons.emoji_events_outlined,
                            label: 'Rewards',
                            value: '$points pts',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: QuickAccessCard(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Wallet',
                            value: '₹${wallet.toStringAsFixed(0)}',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.wallet),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: QuickAccessCard(
                            icon: Icons.upload_file_outlined,
                            label: 'My Notes',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.manageNotes),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: QuickAccessCard(
                            icon: Icons.volunteer_activism_outlined,
                            label: 'Donations',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.donations),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Card(
                      child: Column(
                        children: [
                          MenuItem(
                            icon: Icons.credit_card,
                            title: 'Payment Details',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.bankDetails),
                          ),
                          MenuItem(
                            icon: Icons.password_rounded,
                            title: 'Change Password',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.changePassword),
                          ),
                          MenuItem(
                            icon: Icons.bug_report_outlined,
                            title: 'Report an Issue',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.reportIssue),
                          ),
                          MenuItem(
                            icon: Icons.info_outline,
                            title: 'About CampusNotes+',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.about),
                          ),
                          MenuItem(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.privacyPolicy),
                          ),
                          MenuItem(
                            icon: Icons.settings_outlined,
                            title: 'Settings',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Card(
                      child: MenuItem(
                        icon: Icons.logout,
                        title: 'Log out',
                        showDivider: false,
                        onTap: () async {
                          final auth = Provider.of<AuthController>(context, listen: false);
                          await auth.logout();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Logged out successfully")),
                            );
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.authentication,
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



