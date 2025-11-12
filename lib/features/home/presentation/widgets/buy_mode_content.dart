import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../notes/presentation/controller/notes_controller.dart';
import '../../../notes/presentation/pages/note_detail_page.dart';
import '../../../../data/dummy_data.dart';
import 'featured_note_card.dart';
import 'popular_note_card.dart';
import 'section_header.dart';

class BuyModeContent extends StatelessWidget {
  const BuyModeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesController>(
      builder: (context, notesController, child) {
        final notes = notesController.allNotes;

        if (notesController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (notesController.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 64, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Error loading notes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notesController.error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: notesController.loadTrendingNotes,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return ListView(
          key: const ValueKey('buy_mode'),
          padding: const EdgeInsets.all(16),
          children: [
            const FeaturedNoteCard(),
            const SizedBox(height: 24),

            SectionHeader(
              title: 'Popular Notes',
              actionText: 'See All',
              onActionTap: () {},
            ),
            const SizedBox(height: 12),

            if (notes.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No notes available',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text('Be the first to share your notes!',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              for (final note in notes.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetailPage(note: note),
                        ),
                      );
                    },
                    child: PopularNoteCard(
                      note: NoteItem(
                        id: note.noteId,
                        title: note.title,
                        subject: note.subject,
                        seller: 'Anonymous',
                        price: note.price ?? 0.0,
                        rating: note.rating,
                        pages: 0,
                        tags: [note.subject],
                      ),
                    ),
                  ),
                ),

            const SizedBox(height: 20),

            SectionHeader(
              title: 'Recently Added',
              actionText: 'View More',
              onActionTap: () {},
            ),
            const SizedBox(height: 12),

            for (final note in notes.reversed.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteDetailPage(note: note),
                      ),
                    );
                  },
                  child: PopularNoteCard(
                    note: NoteItem(
                      id: note.noteId,
                      title: note.title,
                      subject: note.subject,
                      seller: 'Anonymous',
                      price: note.price ?? 0.0,
                      rating: note.rating,
                      pages: 0,
                      tags: [note.subject],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
