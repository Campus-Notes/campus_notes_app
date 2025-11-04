import 'package:flutter/material.dart';
import '../routes.dart'; 

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const Text(
                  'CampusNotes+',
                  style: TextStyle(
                    fontSize: 48,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 50),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(text: 'Unlock knowledge the \n smart way'),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/images/image.png',
                  width: 300,
                  height: 300,
                ),
                RichText(
                  textAlign: TextAlign.left,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: 'Your one-stop\n platform for buying\n and selling quality\n academic notes.',
                      ),
                    ],
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Keep your information in our app.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(123, 193, 226, 1),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text(
                          'Log in',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 171, 236, 95),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}