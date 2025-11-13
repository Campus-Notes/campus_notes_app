import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({
    super.key,
    this.message = 'Loading...',
  });

  static void show(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }
}
