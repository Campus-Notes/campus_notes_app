import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../routes/route_names.dart';
import '../widgets/tile_card.dart'; 
import '../widgets/stat_card.dart'; 

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const rewards = 12;
    const wallet = 250.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Student Name', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('you@example.com'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          const Text('Account', style: TextStyle(fontWeight: FontWeight.w700)),
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
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out ')),
              );
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false); 
            },
          ),
        ],
      ),
    );
  }
}


