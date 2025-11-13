import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class NotesManagementPage extends StatefulWidget {
  const NotesManagementPage({super.key});

  @override
  State<NotesManagementPage> createState() => _NotesManagementPageState();
}

class _NotesManagementPageState extends State<NotesManagementPage> {
  final List<Map<String, dynamic>> _myNotes = [
    {
      'id': 'm1',
      'title': 'My DS Cheatsheet',
      'status': 'Published',
      'price': 59
    },
    {
      'id': 'm2',
      'title': 'Linear Algebra Key Points',
      'status': 'Draft',
      'price': 0
    },
    {
      'id': 'm3',
      'title': 'Operating Systems Concepts',
      'status': 'Pending Review',
      'price': 75
    },
  ];

  void _editNote(Map<String, dynamic> note) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing "${note['title']}" (stub)')),
    );
    setState(() {
      final index = _myNotes.indexWhere((n) => n['id'] == note['id']);
      if (index != -1) {
        _myNotes[index]['status'] = 'Draft (Edited)';
      }
    });
  }

  void _deleteNote(Map<String, dynamic> note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _myNotes.removeWhere((n) => n['id'] == note['id']);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${note['title']}" deleted.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      body: _myNotes.isEmpty
          ? const Center(
              child: Text(
                'You haven\'t uploaded any notes yet!',
                style: TextStyle(color: AppColors.muted),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _myNotes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final n = _myNotes[i];
                return ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8)),
                    child:
                        const Icon(Icons.description, color: AppColors.primary),
                  ),
                  title: Text(n['title'] as String),
                  subtitle:
                      Text('Status: ${n['status']} • Price: ₹${n['price']}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete',
                              style: TextStyle(color: AppColors.error))),
                    ],
                    onSelected: (v) {
                      if (v == 'edit') {
                        _editNote(n);
                      } else if (v == 'delete') {
                        _deleteNote(n);
                      }
                    },
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('View "${n['title']}" details ')),
                    );
                  },
                );
              },
            ),
    );
  }
}
