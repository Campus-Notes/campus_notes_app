import 'package:flutter/material.dart';

class DonationsPage extends StatelessWidget {
  const DonationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      {'title': 'Donate your free notes', 'desc': 'Help juniors by donating your notes for free.'},
      {'title': 'Sponsor a student', 'desc': 'Contribute small amounts to support access.'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Donations')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final it = items[i];
          return ListTile(
            leading: const Icon(Icons.volunteer_activism_outlined),
            title: Text(it['title']!),
            subtitle: Text(it['desc']!),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${it['title']} '))),
          );
        },
      ),
    );
  }
}
