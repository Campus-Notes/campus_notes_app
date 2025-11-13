import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../data/dummy_data.dart';
import '../pages/note_detail_page.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.item});

  final NoteItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color:  Color(0xFFE5E7EB))),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NoteDetailPage(note: item),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
                child: const Icon(Icons.description, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Verified badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 10,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.subject, style: const TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber[600]),
                        const SizedBox(width: 4),
                        Text(item.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        Text('${item.pages} pages', style: const TextStyle(color: AppColors.muted)),
                        const Spacer(),
                        Text('₹${item.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
