import 'package:flutter/material.dart';
import 'package:flutter_auth_ui/routes.dart';
import '../theme/app_theme.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Frequently Asked Questions'),
          _buildFaqItem(
            'How do I buy notes?',
            'Browse the home page or use the search tab to find notes. Tap on a note to see details, then click "Buy Now" to proceed to checkout.',
          ),
          _buildFaqItem(
            'How do I sell my notes?',
            'Navigate to the "Upload" tab, fill in the details of your note, attach the file, and publish it. Your note will be available for others to purchase.',
          ),
          _buildFaqItem(
            'What payment methods are supported?',
            'We currently support payments via Razorpay, which includes various options like UPI, credit/debit cards, and net banking.',
          ),
          _buildFaqItem(
            'How do I contact a seller/buyer?',
            'You can use the chat feature to directly communicate with other users. Just tap on a note or a chat thread to start a conversation.',
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Contact Us'),
          ListTile(
            leading: const Icon(Icons.email_outlined, color: AppColors.primary),
            title: const Text('Email Support'),
            subtitle: const Text('support@campusnotes.com'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Launching email app ')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
            title: const Text('Live Chat'),
            subtitle: const Text('Connect with a support agent'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Launching live chat ')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined, color: AppColors.primary),
            title: const Text('Report an Issue'),
            subtitle: const Text('Help us improve by reporting bugs or problems'),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.reportIssue);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(answer, style: const TextStyle(color: AppColors.muted)),
        ),
      ],
    );
  }
}
