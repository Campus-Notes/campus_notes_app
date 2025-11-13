import 'dart:typed_data';
import 'package:campus_notes_app/common_widgets/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_theme.dart';
import '../../data/services/library_service.dart';
import '../../data/services/review_service.dart';
import '../widgets/add_review_dialog.dart';
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
    _checkDownloadStatus();
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

      final notes = await _libraryService.getUserPurchasedNotes(currentUser.uid);
      
      setState(() {
        _purchasedNotes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load library: ${e.toString()}';
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
      
      // If not downloaded, check if we have the data to display
      if (!isDownloaded && noteData.note.fileEncodedData.isEmpty) {
        // Show dialog prompting user to download when online
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.cloud_off, size: 48, color: AppColors.warning),
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
      
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading PDF...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Try to load from downloaded file first
      Uint8List pdfBytes;
      
      if (isDownloaded) {
        try {
          pdfBytes = await _libraryService.loadEncryptedPdf(
            noteData.note.noteId,
            noteData.note.fileName,
          );
          debugPrint('✅ Loaded PDF from offline storage');
        } catch (e) {
          debugPrint('⚠️ Failed to load from offline storage, trying online: $e');
          // If loading fails, decode from base64
          pdfBytes = _libraryService.decodePdfData(noteData.note.fileEncodedData);
        }
      } else {
        // Decode from base64 (requires initial load from Firestore)
        pdfBytes = _libraryService.decodePdfData(noteData.note.fileEncodedData);
        debugPrint('✅ Loaded PDF from cached data');
      }

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Navigate to PDF viewer
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
      Navigator.pop(context); // Close loading dialog
      
      // Show user-friendly error message
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
          action: !isDownloaded ? SnackBarAction(
            label: 'DOWNLOAD',
            textColor: Colors.white,
            onPressed: () => _downloadNote(noteData),
          ) : null,
        ),
      );
    }
  }

  Future<void> _downloadNote(PurchasedNoteData noteData) async {
    try {
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Downloading...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Save encrypted PDF
      await _libraryService.saveEncryptedPdf(
        noteData.note.noteId,
        noteData.note.fileEncodedData,
        noteData.note.fileName,
      );

      // Update download status
      setState(() {
        _downloadStatus[noteData.note.noteId] = true;
      });

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

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
      Navigator.pop(context); // Close loading dialog

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

    // Check if user has already reviewed this note
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

      // Show the review dialog if not reviewed yet
      if (!mounted) return;
      
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AddReviewDialog(
          noteId: noteData.note.noteId,
          noteTitle: noteData.note.title,
        ),
      );

      // If review was submitted successfully, reload the list
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

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your library...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadPurchasedNotes,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_purchasedNotes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.library_books_outlined,
                size: 80,
                color: theme.brightness == Brightness.dark
                    ? AppColors.textSecondaryDark.withOpacity(0.3)
                    : AppColors.textSecondaryLight.withOpacity(0.3),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your library is empty',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Notes you purchase will appear here',
                style: TextStyle(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _purchasedNotes.length,
      itemBuilder: (context, index) {
        final noteData = _purchasedNotes[index];
        final isDownloaded = _downloadStatus[noteData.note.noteId] ?? false;
        
        return _buildNoteCard(noteData, isDownloaded, theme);
      },
    );
  }

  Widget _buildNoteCard(PurchasedNoteData noteData, bool isDownloaded, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewNote(noteData),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and rating
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          noteData.note.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          noteData.note.subject,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDownloaded)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.download_done,
                            size: 16,
                            color: AppColors.success,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Offline',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Owner and rating info
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: theme.brightness == Brightness.dark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    noteData.owner?.fullName ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.brightness == Brightness.dark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    noteData.note.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.brightness == Brightness.dark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: theme.brightness == Brightness.dark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(noteData.purchase.purchasedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.brightness == Brightness.dark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewNote(noteData),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View Note'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isDownloaded
                          ? () => _deleteDownload(noteData)
                          : () => _downloadNote(noteData),
                      icon: Icon(
                        isDownloaded ? Icons.delete_outline : Icons.download,
                        size: 18,
                      ),
                      label: Text(isDownloaded ? 'Remove' : 'Download'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDownloaded ? AppColors.error : AppColors.primary,
                        side: BorderSide(
                          color: isDownloaded ? AppColors.error : AppColors.primary,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showRatingDialog(noteData),
                    icon: const Icon(Icons.star_border),
                    tooltip: 'Rate',
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
