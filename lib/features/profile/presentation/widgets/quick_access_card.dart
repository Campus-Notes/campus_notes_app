import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const QuickAccessCard({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: isDark 
              ? Border.all(color: AppColors.borderDark.withValues(alpha: 0.3))
              : null,
          boxShadow: isDark 
              ? null 
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            Icon(
              icon, 
              size: 28, 
              color: isDark 
                  ? AppColors.textSecondaryDark 
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isDark 
                    ? AppColors.textSecondaryDark 
                    : AppColors.textSecondaryLight,
              ),
            ),
            if (value != null) ...[
              const SizedBox(height: 4),
              Text(
                value!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark 
                      ? AppColors.textPrimaryDark 
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}