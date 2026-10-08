import 'package:flutter/material.dart';

/// Reusable generic shell for top-level product area placeholders.
class AreaPlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final Key? semanticKey;

  const AreaPlaceholderScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.semanticKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: semanticKey,
      appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
