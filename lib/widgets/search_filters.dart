import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SearchFilters extends StatefulWidget {
  const SearchFilters({super.key, required this.onChange});
  final void Function(String subject, String tag) onChange;

  @override
  State<SearchFilters> createState() => _SearchFiltersState();
}

class _SearchFiltersState extends State<SearchFilters> {
  final subjects = const ['All', 'CS', 'Math', 'Economics'];
  final tags = const ['All', 'semester-3', 'semester-4', 'first-year', 'dm', 'dsa'];

  String selectedSubject = 'All';
  String selectedTag = 'All';

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final s in subjects)
          FilterChip(
            label: Text(s),
            selected: selectedSubject == s,
            onSelected: (_) {
              setState(() => selectedSubject = s);
              widget.onChange(selectedSubject, selectedTag);
            },
            selectedColor: AppColors.primary.withOpacity(0.12),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        for (final t in tags)
          FilterChip(
            label: Text('#$t'),
            selected: selectedTag == t,
            onSelected: (_) {
              setState(() => selectedTag = t);
              widget.onChange(selectedSubject, selectedTag);
            },
            selectedColor: AppColors.primary.withOpacity(0.12),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
      ],
    );
  }
}
