import 'package:flutter/material.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final _items = <Map<String, dynamic>>[
    {'title': 'DS Exam', 'date': DateTime.now().add(const Duration(days: 10)), 'enabled': true},
  ];

  void _add() {
    setState(() {
      _items.add({'title': 'New Reminder', 'date': DateTime.now().add(const Duration(days: 5)), 'enabled': true});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Reminders')),
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final r = _items[i];
          return SwitchListTile(
            title: Text(r['title'] as String),
            subtitle: Text((r['date'] as DateTime).toLocal().toString().split(' ').first),
            value: r['enabled'] as bool,
            onChanged: (v) => setState(() => r['enabled'] = v),
          );
        },
      ),
    );
  }
}
