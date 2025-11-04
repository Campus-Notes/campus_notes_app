import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../routes.dart'; 

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
                backgroundColor: AppColors.primary.withOpacity(0.12),
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
              Expanded(
                child: _StatCard(
                  label: 'Rewards',
                  value: '$rewards pts',
                  icon: Icons.emoji_events_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
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
          _Tile(
            icon: Icons.receipt_long_outlined,
            title: 'Purchases',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.purchases),
          ),
          _Tile(
            icon: Icons.upload_file_outlined, 
            title: 'My Notes',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.manageNotes),
          ),
          _Tile(
            icon: Icons.volunteer_activism_outlined,
            title: 'Donations',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.donations),
          ),
          _Tile(
            icon: Icons.bug_report_outlined,
            title: 'Report an Issue',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.reportIssue),
          ),
          _Tile(
            icon: Icons.info_outline,
            title: 'About CampusNotes+',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.about),
          ),
          _Tile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.helpSupport), 
          ),
          _Tile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.privacyPolicy), 
          ),
          _Tile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings), 
          ),
          _Tile(
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap, 
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap; 

  @override
  Widget build(BuildContext context) {
    return InkWell( 
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.muted)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}