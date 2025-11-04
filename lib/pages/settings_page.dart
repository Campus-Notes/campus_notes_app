import 'package:flutter/material.dart';
import '../routes.dart'; 

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;
  bool examReminders = true;
  bool chatNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            value: darkMode,
            onChanged: (v) => setState(() => darkMode = v),
            title: const Text('Dark mode'),
            subtitle: const Text('Appearance'),
          ),
          SwitchListTile(
            value: examReminders,
            onChanged: (v) => setState(() => examReminders = v),
            title: const Text('Exam reminders'),
            subtitle: const Text('Receive upcoming exam alerts'),
          ),
          SwitchListTile(
            value: chatNotifications,
            onChanged: (v) => setState(() => chatNotifications = v),
            title: const Text('Chat notifications'),
            subtitle: const Text('New messages from buyers/sellers'),
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
        ],
      ),
    );
  }
}