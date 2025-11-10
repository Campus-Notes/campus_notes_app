import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../routes/route_names.dart';
import '../widgets/tile_card.dart';
import '../widgets/stat_card.dart';
import '../../../authentication/presentation/controller/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const rewards = 12;
    const wallet = 250.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.userProfile),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: const Icon(Icons.person, size: 38, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Name',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'you@example.com',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: StatCard(
                          label: 'Rewards',
                          value: '$rewards pts',
                          icon: Icons.emoji_events_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: 'Wallet',
                          value: '₹${wallet.toInt()}',
                          icon: Icons.account_balance_wallet_outlined,
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.wallet),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text("Account", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),

                  TileCard(
                    icon: Icons.receipt_long_outlined,
                    title: 'Purchases',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.purchases),
                  ),
                  TileCard(
                    icon: Icons.upload_file_outlined,
                    title: 'My Notes',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.manageNotes),
                  ),
                  TileCard(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'Donations',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.donations),
                  ),
                  TileCard( 
                    icon: Icons.password_rounded,
                    title: 'Change Password',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.changePassword),
                  ),
                  TileCard(
                    icon: Icons.bug_report_outlined,
                    title: 'Report an Issue',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.reportIssue),
                  ),
                  TileCard(
                    icon: Icons.info_outline,
                    title: 'About CampusNotes+',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.about),
                  ),
                  TileCard(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.helpSupport),
                  ),
                  TileCard(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.privacyPolicy),
                  ),
                  TileCard(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
                  ),

                  TileCard(
                    icon: Icons.logout,
                    title: 'Log out',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
