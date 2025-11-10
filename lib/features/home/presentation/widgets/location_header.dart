import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class LocationHeader extends StatelessWidget {
  final String selectedUniversity;
  final List<String> universities;
  final ValueChanged<String?> onUniversityChanged;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;

  const LocationHeader({
    super.key,
    required this.selectedUniversity,
    required this.universities,
    required this.onUniversityChanged,
    required this.onSearchTap,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 20, color: AppColors.muted),
        const SizedBox(width: 4),
        Expanded(
          child: DropdownButton<String>(
            value: selectedUniversity,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            items: universities.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onUniversityChanged,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search, size: 24),
          onPressed: onSearchTap,
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 24),
          onPressed: onNotificationTap,
        ),
      ],
    );
  }
}