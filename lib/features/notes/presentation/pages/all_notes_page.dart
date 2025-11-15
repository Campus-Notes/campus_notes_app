import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../common_widgets/app_bar.dart';
import '../../../../data/dummy_data.dart';
import '../controller/notes_controller.dart';
import '../controller/cart_controller.dart';
import '../../data/services/note_database_service.dart';
import '../../../home/presentation/widgets/popular_note_card.dart';
import 'note_detail_page.dart';

class AllNotesPage extends StatefulWidget {
  final String title;
  final String sortBy;

  const AllNotesPage({
    super.key,
    this.title = 'All Notes',
    this.sortBy = 'popular',
  });

  @override
  State<AllNotesPage> createState() => _AllNotesPageState();
}

class _AllNotesPageState extends State<AllNotesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        text: widget.title,
        showBackButton: true,
        centerTitle: true,
      ),
      body: Consumer<NotesController>(
        builder: (context, notesController, child) {
          final notes = _getSortedNotes(notesController);

          if (notesController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notesController.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
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

          if (notes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 80,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No notes available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Be the first to share your notes!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PopularNoteCardWrapper(
                  note: note,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteDetailPage(note: note),
                      ),
                    );
                  },
                  onAddToCart: () {
                    _handleAddToCart(context, note);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<dynamic> _getSortedNotes(NotesController controller) {
    final notes = List.from(controller.allNotes);

    switch (widget.sortBy) {
      case 'trending':
      case 'popular':
        notes.sort((a, b) => b.purchaseCount.compareTo(a.purchaseCount));
        break;
      case 'recent':
        break;
      default:
        notes.sort((a, b) => b.purchaseCount.compareTo(a.purchaseCount));
    }

    return notes;
  }

  void _handleAddToCart(BuildContext context, dynamic note) {
    final cart = context.read<CartController>();
    if (cart.isInCart(note.noteId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Already in cart'),
          action: SnackBarAction(
            label: 'VIEW CART',
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ),
      );
    } else {
      cart.addToCart(note);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${note.title} added to cart'),
          action: SnackBarAction(
            label: 'VIEW CART',
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class _PopularNoteCardWrapper extends StatefulWidget {
  final dynamic note;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const _PopularNoteCardWrapper({
    required this.note,
    this.onTap,
    this.onAddToCart,
  });

  @override
  State<_PopularNoteCardWrapper> createState() => _PopularNoteCardWrapperState();
}

class _PopularNoteCardWrapperState extends State<_PopularNoteCardWrapper> {
  final NoteDatabaseService _noteDatabaseService = NoteDatabaseService();
  late Future<bool> _purchasedFuture;

  @override
  void initState() {
    super.initState();
    _purchasedFuture = _checkIfPurchased();
  }

  Future<bool> _checkIfPurchased() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return false;
      }

      return await _noteDatabaseService.hasUserPurchased(
          widget.note.noteId, currentUser.uid);
    } catch (e) {
      debugPrint('Error checking purchase status: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _purchasedFuture,
      builder: (context, snapshot) {
        final isPurchased = snapshot.data ?? false;

        return PopularNoteCard(
          note: NoteItem(
            id: widget.note.noteId,
            title: widget.note.title,
            subject: widget.note.subject,
            seller: 'Anonymous',
            price: widget.note.price ?? 0.0,
            rating: widget.note.rating,
            pages: 0,
            tags: [widget.note.subject],
          ),
          hasAlreadyPurchased: isPurchased,
          onTap: widget.onTap,
          onAddToCart: isPurchased ? null : widget.onAddToCart,
        );
      },
    );
  }
}
