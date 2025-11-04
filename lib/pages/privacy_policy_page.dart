import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: ${DateTime.now().toLocal().toString().split(' ').first}',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Text(
              '1. Introduction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Welcome to CampusNotes+! We are committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you visit our mobile application (the "App").',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '2. Information We Collect',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildPrivacyPoint(
              'Personal Data:',
              'We collect personal identification information (Name, email address, phone number, etc.) that you voluntarily provide to us when you register on the App, upload notes, or interact with other features.',
            ),
            _buildPrivacyPoint(
              'Derivative Data:',
              'Information our servers automatically collect when you access the App, such as your IP address, browser type, operating system, access times, and the pages you have viewed directly before and after accessing the App.',
            ),
            _buildPrivacyPoint(
              'Financial Data:',
              'Financial information, such as data related to your payment method (e.g., valid credit card number, card brand, expiration date) that we may collect when you purchase or upload notes.',
            ),
            const SizedBox(height: 16),
            const Text(
              '3. How We Use Your Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildPrivacyPoint(
              'To Create and Manage Your Account:',
              'To facilitate account creation and logon process, and to manage your account.',
            ),
            _buildPrivacyPoint(
              'To Process Transactions:',
              'To process payments for purchases and sales of notes.',
            ),
            _buildPrivacyPoint(
              'To Provide Services:',
              'To offer notes, facilitate chat communication, and manage your uploaded content.',
            ),
            _buildPrivacyPoint(
              'To Improve the App:',
              'To analyze usage trends and preferences to improve the functionality and user experience of the App.',
            ),
            const SizedBox(height: 16),
            const Text(
              '4. Disclosure of Your Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'We may share information we have collected about you in certain situations. Your information may be disclosed as follows:',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            _buildPrivacyPoint(
              'By Law or to Protect Rights:',
              'If we believe the release of information about you is necessary to respond to legal process, to investigate or remedy potential violations of our policies, or to protect the rights, property, and safety of others, we may share your information as permitted or required by any applicable law, rule, or regulation.',
            ),
            _buildPrivacyPoint(
              'Third-Party Service Providers:',
              'We may share your information with third parties that perform services for us or on our behalf, including payment processing, data analysis, email delivery, hosting services, customer service, and marketing assistance.',
            ),
            const SizedBox(height: 16),
            const Text(
              '5. Security of Your Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'We use administrative, technical, and physical security measures to help protect your personal information. While we have taken reasonable steps to secure the personal information you provide to us, please be aware that despite our efforts, no security measures are perfect or impenetrable, and no method of data transmission can be guaranteed against any interception or other type of misuse.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '6. Contact Us',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'If you have questions or comments about this Privacy Policy, please contact us at: support@campusnotes.com',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $title',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            description,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
