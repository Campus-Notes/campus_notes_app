import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../routes/route_names.dart';
import '../../../../services/theme_service.dart';

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
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return Column(
                children: [
                  ListTile(
                    leading: Icon(themeService.themeModeIcon),
                    title: const Text('Theme'),
                    subtitle: Text('Current: ${themeService.themeModeString}'),
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
            title: const Text('Exam reminders'),
            subtitle: const Text('Receive upcoming exam alerts'),
            secondary: const Icon(Icons.alarm),
          ),
          SwitchListTile(
            value: chatNotifications,
            onChanged: (v) => setState(() => chatNotifications = v),
            title: const Text('Chat notifications'),
            subtitle: const Text('New messages from buyers/sellers'),
            secondary: const Icon(Icons.chat_bubble_outline),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.helpSupport), 
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.privacyPolicy), 
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
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