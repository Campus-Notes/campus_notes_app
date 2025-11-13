import 'package:flutter/material.dart';
import '../../../../common_widgets/app_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        text: 'About',
        sideIcon: Icons.info_outline,
        usePremiumBackIcon: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
            'CampusNotes+ is a student-focused notes marketplace emphasizing affordability, offline access, and direct buyer-seller interactions.'),
      ),
    );
  }
}
