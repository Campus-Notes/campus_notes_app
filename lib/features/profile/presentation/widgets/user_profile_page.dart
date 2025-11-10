import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
                Positioned(
                  right: -6,
                  bottom: -6,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 26),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _inputField("First Name", "John"),
          _inputField("Last Name", "Doe"),
          _inputField("Email", "you@example.com"),
          _inputField("Mobile", "+91-123456789"),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("SAVE"),
          )
        ],
      ),
    );
  }

  Widget _inputField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(labelText: label, filled: true),
      ),
    );
  }
}
