import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}

void showErrorSnackBar(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context); // Capture messenger to avoid context errors
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(15),
      action: SnackBarAction(
        label: 'Close',
        textColor: Colors.white,
        onPressed: () {
          messenger.hideCurrentSnackBar(); // Use captured messenger
        },
      ),
    ),
  );
}

void showSuccessSnackBar(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context); // Capture messenger to avoid context errors
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(15),
      action: SnackBarAction(
        label: 'Close',
        textColor: Colors.white,
        onPressed: () {
          messenger.hideCurrentSnackBar(); // Use captured messenger
        },
      ),
    ),
  );
}