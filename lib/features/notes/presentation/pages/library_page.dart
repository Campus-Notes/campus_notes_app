import 'dart:typed_data';
import 'package:campus_notes_app/common_widgets/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/connectivity_service.dart';
import '../../data/services/library_service.dart';
import '../../data/services/review_service.dart';
import '../widgets/add_review_dialog.dart';
import '../widgets/library_loading_view.dart';
import '../widgets/library_error_view.dart';
import '../widgets/library_empty_view.dart';
import '../widgets/library_note_card.dart';
import '../widgets/loading_dialog.dart';
import 'pdf_viewer_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final LibraryService _libraryService = LibraryService();
  final ReviewService _reviewService = ReviewService();
  List<PurchasedNoteData> _purchasedNotes = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, bool> _downloadStatus = {};

  @override
  void initState() {
    super.initState();
    _loadPurchasedNotes();
  }

  Future<void> _loadPurchasedNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = 'Please log in to view your library';
          _isLoading = false;
        });
        return;
      }

      final connectivity =
          Provider.of<ConnectivityService>(context, listen: false);

      if (connectivity.isOffline) {
        await _loadOfflineNotes(currentUser.uid);
      } else {
        final notes =
            await _libraryService.getUserPurchasedNotes(currentUser.uid);

        setState(() {
          _purchasedNotes = notes;
          _isLoading = false;
        });

        await _checkDownloadStatus();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load library: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOfflineNotes(String userId) async {
    try {
      final downloadedNotes = await _libraryService.getDownloadedNotes(userId);

      setState(() {
        _purchasedNotes = downloadedNotes;
        _isLoading = false;
        for (var noteData in downloadedNotes) {
          _downloadStatus[noteData.note.noteId] = true;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No offline notes available';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkDownloadStatus() async {
    for (var noteData in _purchasedNotes) {
      final isDownloaded = await _libraryService.isPdfDownloaded(
        noteData.note.noteId,
        noteData.note.fileName,
      );
      setState(() {
        _downloadStatus[noteData.note.noteId] = isDownloaded;
      });
    }
  }

  Future<void> _viewNote(PurchasedNoteData noteData) async {
    try {
      final isDownloaded = _downloadStatus[noteData.note.noteId] ?? false;

      if (!isDownloaded && noteData.note.fileEncodedData.isEmpty) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon:
                const Icon(Icons.cloud_off, size: 48, color: AppColors.warning),
            title: const Text('No Internet Connection'),
            content: const Text(
              'This note is not available offline. Please download it when you have an internet connection to view it offline.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      if (!mounted) return;
      LoadingDialog.show(context, message: 'Loading PDF...');

      Uint8List pdfBytes;

      if (isDownloaded) {
        try {
          pdfBytes = await _libraryService.loadEncryptedPdf(
            noteData.note.noteId,
            noteData.note.fileName,
          );
          debugPrint('✅ Loaded PDF from offline storage');
        } catch (e) {
          debugPrint(
              '⚠️ Failed to load from offline storage, trying online: $e');
          pdfBytes =
              _libraryService.decodePdfData(noteData.note.fileEncodedData);
        }
      } else {
        pdfBytes = _libraryService.decodePdfData(noteData.note.fileEncodedData);
        debugPrint('✅ Loaded PDF from cached data');
      }

      if (!mounted) return;
      LoadingDialog.hide(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SecurePdfViewerPage(
            noteTitle: noteData.note.title,
            pdfBytes: pdfBytes,
            noteId: noteData.note.noteId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      LoadingDialog.hide(context);

      final isDownloaded = _downloadStatus[noteData.note.noteId] ?? false;
      final errorMessage = isDownloaded
          ? 'Failed to open downloaded PDF. Please try re-downloading.'
          : 'Unable to load PDF. Please check your internet connection or download for offline access.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('Failed to Open PDF')),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                errorMessage,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
          action: !isDownloaded
              ? SnackBarAction(
                  label: 'DOWNLOAD',
                  textColor: Colors.white,
                  onPressed: () => _downloadNote(noteData),
                )
              : null,
        ),
      );
    }
  }

  Future<void> _downloadNote(PurchasedNoteData noteData) async {
    try {
      if (!mounted) return;
      LoadingDialog.show(context, message: 'Downloading...');

      await _libraryService.saveEncryptedPdf(
        noteData.note.noteId,
        noteData.note.fileEncodedData,
        noteData.note.fileName,
      );

      setState(() {
        _downloadStatus[noteData.note.noteId] = true;
      });

      if (!mounted) return;
      LoadingDialog.hide(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Download Complete'),
                    Text(
                      'File saved securely for offline access',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      LoadingDialog.hide(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteDownload(PurchasedNoteData noteData) async {
    try {
      await _libraryService.deleteDownloadedPdf(
        noteData.note.noteId,
        noteData.note.fileName,
      );

      setState(() {
        _downloadStatus[noteData.note.noteId] = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Downloaded file removed'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove download: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showRatingDialog(PurchasedNoteData noteData) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to review notes'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final hasReviewed = await _reviewService.hasUserReviewed(
        noteData.note.noteId,
        currentUser.uid,
      );

      if (hasReviewed) {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text('Already Reviewed'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('You have already reviewed this note.'),
                const SizedBox(height: 12),
                Text(
                  'Current Rating: ${noteData.note.rating.toStringAsFixed(1)} ⭐',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      if (!mounted) return;

      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AddReviewDialog(
          noteId: noteData.note.noteId,
          noteTitle: noteData.note.title,
        ),
      );

      if (result == true && mounted) {
        _loadPurchasedNotes();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking review status: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        text: "My Library",
        showBackButton: true,
        centerTitle: true,
        sideIcon: Icons.refresh_rounded,
        onSideIconTap: _loadPurchasedNotes,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPurchasedNotes,
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const LibraryLoadingView();
    }

    if (_errorMessage != null) {
      return LibraryErrorView(
        errorMessage: _errorMessage!,
        onRetry: _loadPurchasedNotes,
      );
    }

    if (_purchasedNotes.isEmpty) {
      return const LibraryEmptyView();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _purchasedNotes.length,
      itemBuilder: (context, index) {
        final noteData = _purchasedNotes[index];
        final isDownloaded = _downloadStatus[noteData.note.noteId] ?? false;

        return LibraryNoteCard(
          noteData: noteData,
          isDownloaded: isDownloaded,
          onView: () => _viewNote(noteData),
          onDownloadOrDelete: isDownloaded
              ? () => _deleteDownload(noteData)
              : () => _downloadNote(noteData),
          onRate: () => _showRatingDialog(noteData),
        );
      },
    );
  }
}
