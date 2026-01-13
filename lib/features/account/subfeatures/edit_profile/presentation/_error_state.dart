import 'package:flutter/material.dart';

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    required this.title,
    required this.message,
    required this.details,
    required this.onRetry,
  });

  final String title;
  final String message;
  final Object details;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
          const SizedBox(height: 12),
          // Keep details hidden behind small text (still useful for debugging)
          ExpansionTile(
            title: const Text('Details'),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(details.toString()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
