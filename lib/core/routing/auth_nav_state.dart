import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navigation authentication status.
enum AuthNavStatus { initial, authenticated, unauthenticated }

/// Provider managing the auth navigation state.
///
/// Later in Phase 2 (Tasks 013-015), this will be connected to the
/// real Supabase session state.
final authNavStatusProvider = StateProvider<AuthNavStatus>(
  (ref) => AuthNavStatus.unauthenticated,
  name: 'authNavStatusProvider',
);
