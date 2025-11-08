import 'package:flutter/material.dart';
class AboutPage extends StatelessWidget{
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'CampusNotes+ is a student-focused notes marketplace emphasizing affordability, offline access, and direct buyer-seller interactions.'
        ),
      ),
    );
  }
}
