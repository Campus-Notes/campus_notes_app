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
  bool examReminders = true;
  bool chatNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'Settings',
        usePremiumBackIcon: true,
      ),
      body: ListView(
        children: [
          Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return Column(
                children: [
                  ListTile(
                    leading: Icon(themeService.themeModeIcon),
                    title: Text(
                      'Theme',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      'Current: ${themeService.themeModeString}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: DropdownButton<ThemeMode>(
                      value: themeService.themeMode,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                            mainAxisSize: MainAxisSize.min,
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
                            mainAxisSize: MainAxisSize.min,
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
                ],
              );
            },
          ),
          const Divider(),
          SwitchListTile(
            value: examReminders,
            onChanged: (v) => setState(() => examReminders = v),
            title: Text(
              'Exam reminders',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            subtitle: Text(
              'Receive upcoming exam alerts',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            secondary: const Icon(Icons.alarm),
          ),
          SwitchListTile(
            value: chatNotifications,
            onChanged: (v) => setState(() => chatNotifications = v),
            title: Text(
              'Chat notifications',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            subtitle: Text(
              'New messages from buyers/sellers',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            secondary: const Icon(Icons.chat_bubble_outline),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(
              'Help & Support',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.helpSupport), 
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.privacyPolicy), 
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(
              'Terms of Service',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Terms of Service')),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}