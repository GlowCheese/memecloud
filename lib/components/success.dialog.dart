import 'package:flutter/material.dart';

showSuccessDialog(
  BuildContext context, {
  required String text,
  required int numOfPopContext,
}) {
  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 48),
                const SizedBox(height: 16),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    for (int i = 0; i < numOfPopContext; i++) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ),
  );
}
