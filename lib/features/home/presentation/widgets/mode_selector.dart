import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class ModeSelector extends StatelessWidget {
  final bool isBuyMode;
  final ValueChanged<bool> onModeChanged;

  const ModeSelector({
    super.key,
    required this.isBuyMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildModeButton(
            context,
            icon: Icons.shopping_bag_outlined,
            label: 'Buy Notes',
            isSelected: isBuyMode,
            onTap: () => onModeChanged(true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildModeButton(
            context,
            icon: Icons.sell_outlined,
            label: 'Sell Notes',
            isSelected: !isBuyMode,
            onTap: () => onModeChanged(false),
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
            ? AppColors.primary.withValues(alpha: 0.1) 
            : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected 
                ? AppColors.primary 
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                  ? AppColors.primary 
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}