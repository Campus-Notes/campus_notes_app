import 'package:flutter/material.dart';

class NoteDetailsWidget extends StatelessWidget {
  final String subject;
  final bool isDonation;
  final double price;

  const NoteDetailsWidget({
    super.key,
    required this.subject,
    required this.isDonation,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: theme.colorScheme.outline.withOpacity(0.2), thickness: 1),
          
          const SizedBox(height: 16),
          
          Text(
            'Description',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comprehensive $subject notes covering all key topics. High-quality content perfect for exam preparation and academic reference.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Details section
          Text(
            'Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildDetailRow('Subject', subject, theme),
          _buildDetailRow('Format', 'PDF Document', theme),
          _buildDetailRow('Type', isDonation ? 'Donation' : 'Premium', theme),
          if (!isDonation)
            _buildDetailRow('Revenue Split', '80% to seller, 5% points to seller, 2% points to buyer', theme),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}