import 'package:flutter/material.dart';
import '../../../notes/presentation/widgets/note_card.dart';
import '../widgets/search_filters.dart';
import '../../../../data/dummy_data.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  String subject = 'All';
  String tag = 'All';

  @override
  Widget build(BuildContext context) {
    final filtered = dummyNotes.where((n) {
      final matchesQuery =
          query.isEmpty || n.title.toLowerCase().contains(query.toLowerCase());
      final matchesSubject = subject == 'All' ||
          n.subject.toLowerCase().contains(subject.toLowerCase());
      final matchesTag = tag == 'All' || n.tags.contains(tag);
      return matchesQuery && matchesSubject && matchesTag;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search notes, subjects...'),
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 12),
          SearchFilters(
            onChange: (s, t) => setState(() {
              subject = s;
              tag = t;
            }),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const Text('No results')
          else
            ...filtered.map((n) => NoteCard(item: n)),
        ],
      ),
    );
  }
}
