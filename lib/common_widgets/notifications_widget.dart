import 'package:flutter/material.dart';
import 'app_bar.dart';

class NotificationPage extends StatelessWidget{
  const NotificationPage({super.key});
  @override
  Widget build(BuildContext context){
    const items = [
      {'title': 'Price drop on Discrete Math', 'time': '2h'},
      {'title': 'New message from Ananya', 'time': 'Yesterday'},
      {'title': 'Exam reminder: DS on 12th', 'time': '3d'},
    ];
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'Notifications',
        sideIcon: Icons.clear_all,
        usePremiumBackIcon: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12.0),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final n = items[i];
          return ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(n['title']!),
            subtitle: Text(n['time']!),
            onTap: () {}
          );
        } 
      ),
    );
  }
}