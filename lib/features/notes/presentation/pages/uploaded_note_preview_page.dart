import 'package:campus_notes_app/features/notes/data/models/note_model.dart';
import 'package:campus_notes_app/common_widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/pdf_preview.dart';
import '../widgets/note_header.dart';
import '../widgets/note_details.dart';
import '../widgets/reviews_section.dart';
import '../../../../services/notification_service.dart';

class UploadedNotePreviewPage extends StatefulWidget {
  final NoteModel note;

  const UploadedNotePreviewPage({
    super.key,
    required this.note,
  });

  @override
  State<UploadedNotePreviewPage> createState() =>
      _UploadedNotePreviewPageState();
}

class _UploadedNotePreviewPageState extends State<UploadedNotePreviewPage> {
  @override
  void initState() {
    super.initState();
    // Trigger copyright notification if note is copyrighted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.note.isCopyrighted) {
        final notificationService = context.read<NotificationService>();
        notificationService.sendCopyrightNotification(
          noteTitle: widget.note.title,
          copyrightReason: widget.note.copyrightReason,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        text: widget.note.title,
        usePremiumBackIcon: true,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          PdfPreviewWidget(
            hasAlreadyPurchased: true,
            isOwnNote: true,
            note: widget.note,
            onTap: () {},
          ),
          const SizedBox(height: 20),
          NoteHeaderWidget(
            title: widget.note.title,
            rating: widget.note.rating,
            price: widget.note.price ?? 0.0,
            isDonation: widget.note.isDonation,
            isVerified: widget.note.isVerified,
          ),
          const SizedBox(height: 16),
          NoteDetailsWidget(
            subject: widget.note.subject,
            isDonation: widget.note.isDonation,
            price: widget.note.price ?? 0.0,
            description: widget.note.description,
            pageCount: widget.note.pageCount,
          ),
          const SizedBox(height: 20),
          _buildStatsSection(context),
          const SizedBox(height: 20),
          _buildVerificationSection(context),
          const SizedBox(height: 20),
          ReviewsSectionWidget(
            noteId: widget.note.noteId,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 3,
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Note Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  icon: Icons.shopping_cart,
                  label: 'Purchases',
                  value: widget.note.purchaseCount.toString(),
                ),
                _buildStatItem(
                  context,
                  icon: Icons.star,
                  label: 'Rating',
                  value: widget.note.rating.toStringAsFixed(1),
                ),
              ],
            ),
            if (!widget.note.isDonation) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Earnings',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '₹${widget.note.earnings.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildVerificationSection(BuildContext context) {
    final isCopyrighted = widget.note.isCopyrighted;
    final copyrightReason = widget.note.copyrightReason;

    if (isCopyrighted) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.copyright,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Copyrighted Content',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      copyrightReason ?? 'This note has been marked as copyrighted content',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red.shade700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.note.isVerified
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.note.isVerified
                ? Colors.green.withValues(alpha: 0.5)
                : Colors.orange.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              widget.note.isVerified ? Icons.verified : Icons.pending_actions,
              color: widget.note.isVerified ? Colors.green : Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.note.isVerified
                        ? 'Verified Note'
                        : 'Pending Verification',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.note.isVerified
                              ? Colors.green
                              : Colors.orange,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.note.isVerified
                        ? 'This note has been verified by our moderators'
                        : 'Your note is being reviewed by our moderators',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: widget.note.isVerified
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
