import 'package:fitkarma/core/supabase/supabase_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reusable generic shell for top-level product area placeholders.
class AreaPlaceholderScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Scaffold(
      key: semanticKey,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        actions: [
          if (isAuthenticated)
            IconButton(
              key: const Key('logout_button'),
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Sign Out',
              onPressed: () async {
                await ref.read(supabaseAuthServiceProvider).signOut();
              },
            ),
        ],
      ),
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
