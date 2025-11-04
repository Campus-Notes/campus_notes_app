import 'package:flutter/material.dart';

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
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
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