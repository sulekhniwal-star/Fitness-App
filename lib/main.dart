import 'package:flutter/material.dart';

void main() {
  runApp(const FitKarmaApp());
}

/// Root widget for the FitKarma application.
class FitKarmaApp extends StatelessWidget {
  const FitKarmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitKarma',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0F12),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E599),
          surface: Color(0xFF161A22),
        ),
        useMaterial3: true,
      ),
      home: const FitKarmaShell(),
    );
  }
}

/// Minimal initial shell demonstrating bootstrap launch.
class FitKarmaShell extends StatelessWidget {
  const FitKarmaShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FitKarma',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "India's Intelligent Health Operating System",
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
