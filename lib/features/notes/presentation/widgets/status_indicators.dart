import 'package:flutter/material.dart';

class StatusIndicatorsWidget extends StatelessWidget {
  final bool hasAlreadyPurchased;

  const StatusIndicatorsWidget({
    super.key,
    required this.hasAlreadyPurchased,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatusBadge(
            icon: Icons.check_circle,
            label: hasAlreadyPurchased ? 'Purchased' : 'Available',
            iconColor: hasAlreadyPurchased ? Colors.green : Colors.blue,
            theme: theme,
          ),
          const SizedBox(width: 16),
          _buildStatusBadge(
            icon: Icons.download,
            label: 'Instant Download',
            iconColor: theme.colorScheme.primary,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({
    required IconData icon,
    required String label,
    required Color iconColor,
    required ThemeData theme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}