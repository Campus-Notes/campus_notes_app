import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class LibraryEmptyView extends StatelessWidget {
  const LibraryEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
}
