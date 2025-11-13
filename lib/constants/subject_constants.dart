import 'package:flutter/material.dart';

/// Predefined subjects for note categorization
const List<String> subjects = [
  'Computer Science',
  'Biology',
  'Physics',
  'Chemistry',
  'English',
  'Mathematics',
  'Social',
  'Other',
];

class SubjectCategory {
  final String name;
  final IconData icon;

  const SubjectCategory({
    required this.name,
    required this.icon,
  });
}

/// Subject categories with corresponding icons
final List<SubjectCategory> subjectCategories = [
  const SubjectCategory(name: 'Computer Science', icon: Icons.computer),
  const SubjectCategory(name: 'Mathematics', icon: Icons.calculate),
  const SubjectCategory(name: 'Physics', icon: Icons.science),
  const SubjectCategory(name: 'Biology', icon: Icons.biotech),
  const SubjectCategory(name: 'Chemistry', icon: Icons.science_outlined),
  const SubjectCategory(name: 'English', icon: Icons.menu_book),
  const SubjectCategory(name: 'Social', icon: Icons.account_balance),
  const SubjectCategory(name: 'Other', icon: Icons.more_horiz),
];

/// Get icon for a subject
IconData getSubjectIcon(String subject) {
  final category = subjectCategories.firstWhere(
    (cat) => cat.name.toLowerCase() == subject.toLowerCase(),
    orElse: () => const SubjectCategory(name: 'Other', icon: Icons.book),
  );
  return category.icon;
}
