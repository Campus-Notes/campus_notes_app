import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../notes/presentation/controller/notes_controller.dart';
import '../../../notes/presentation/controller/cart_controller.dart';
import '../../../notes/presentation/pages/note_detail_page.dart';
import '../../../notes/presentation/pages/all_notes_page.dart';
import '../../../../data/dummy_data.dart';
import '../../../../services/connectivity_service.dart';
import '../../../../routes/route_names.dart';
import '../../../../theme/app_theme.dart';
import 'featured_note_card.dart';
import 'popular_note_card.dart';
import 'section_header.dart';
import 'notes_shimmer_loading.dart';

class BuyModeContent extends StatelessWidget {
  const BuyModeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotesController, ConnectivityService>(
      builder: (context, notesController, connectivity, child) {
        final notes = notesController.allNotes;

        if (connectivity.isOffline) {
          return _buildOfflineMessage(context);
        }

        if (notesController.isLoading || !notesController.hasLoadedOnce) {
          return const NotesShimmerLoading();
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

        return RefreshIndicator(
          onRefresh: () async {
            await notesController.loadTrendingNotes();
          },
          child: ListView(
            key: const ValueKey('buy_mode'),
            padding: const EdgeInsets.all(16),
            children: [
              if (notes.isNotEmpty)
                FeaturedNoteCard(
                  featuredNote: _getTrendingNotes(notes).isNotEmpty
                      ? NoteItem(
                          id: _getTrendingNotes(notes).first.noteId,
                          title: _getTrendingNotes(notes).first.title,
                          subject: _getTrendingNotes(notes).first.subject,
                          seller: 'Top Seller',
                          price: _getTrendingNotes(notes).first.price ?? 0.0,
                          rating: _getTrendingNotes(notes).first.rating,
                          pages: 0,
                          tags: [_getTrendingNotes(notes).first.subject],
                        )
                      : null,
                  onTap: () {
                    if (_getTrendingNotes(notes).isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetailPage(
                            note: _getTrendingNotes(notes).first,
                          ),
                        ),
                      );
                    }
                  },
                )
              else
                const FeaturedNoteCard(),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Trending',
                actionText: 'See All',
                onActionTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllNotesPage(
                        title: 'Trending Notes',
                        sortBy: 'trending',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              if (notes.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.note_alt_outlined,
                            size: 64, color: Colors.grey),
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
                for (final note in _getTrendingNotes(notes).take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteDetailPage(note: note),
                          ),
                        );
                      },
                      onAddToCart: () {
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
                      },
                    ),
                  ),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Recently Added',
                actionText: 'View More',
                onActionTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllNotesPage(
                        title: 'Recently Added',
                        sortBy: 'recent',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              for (final note in notes.reversed.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetailPage(note: note),
                        ),
                      );
                    },
                    onAddToCart: () {
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
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<dynamic> _getTrendingNotes(List<dynamic> notes) {
    final sortedNotes = List.from(notes);
    sortedNotes.sort((a, b) => b.purchaseCount.compareTo(a.purchaseCount));
    return sortedNotes;
  }

  Widget _buildOfflineMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Internet Connection',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You\'re currently offline. Browse and view your downloaded notes in your Library.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.libraryPage);
                },
                icon: const Icon(Icons.library_books, size: 20),
                label: const Text('Go to Library'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  (context as Element).markNeedsBuild();
                },
                child: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
