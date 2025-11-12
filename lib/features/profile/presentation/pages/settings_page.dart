import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../routes/route_names.dart';
import '../../../../services/theme_service.dart';
import '../../../../common_widgets/app_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool appNotifications = true;
  bool chatNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'Settings',
        usePremiumBackIcon: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: ListView(
          children: [
            Consumer<ThemeService>(
              builder: (context, themeService, child) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(themeService.themeModeIcon, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Theme',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              'Current: ${themeService.themeModeString}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ThemeMode>(
                            value: themeService.themeMode,
                            alignment: Alignment.centerRight,
                            borderRadius: BorderRadius.circular(10),
                            items: const [
                              DropdownMenuItem(
                                value: ThemeMode.system,
                                child: Row(
                                  children: [
                                    Icon(Icons.brightness_auto, size: 16),
                                    SizedBox(width: 8),
                                    Text('System'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: ThemeMode.light,
                                child: Row(
                                  children: [
                                    Icon(Icons.light_mode, size: 16),
                                    SizedBox(width: 8),
                                    Text('Light'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: ThemeMode.dark,
                                child: Row(
                                  children: [
                                    Icon(Icons.dark_mode, size: 16),
                                    SizedBox(width: 8),
                                    Text('Dark'),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (ThemeMode? mode) {
                              if (mode != null) {
                                themeService.setThemeMode(mode);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              value: appNotifications,
              onChanged: (v) => setState(() => appNotifications = v),
              title: Text(
                'App notifications',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              subtitle: Text(
                'Receive push notifications from the app',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              secondary: const Icon(Icons.notifications_outlined),
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              value: chatNotifications,
              onChanged: (v) => setState(() => chatNotifications = v),
              title: Text(
                'Chat notifications',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              subtitle: Text(
                'Get notified about new messages from marketplace chats',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              secondary: const Icon(Icons.chat_bubble_outline),
            ),
            const SizedBox(height: 18),
            _buildListTile(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.helpSupport),
            ),
            _buildListTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.privacyPolicy),
            ),
            _buildListTile(
              context,
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of Service')),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 3,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}
