import 'package:fitkarma/core/supabase/mock_supabase_service.dart';
import 'package:fitkarma/core/supabase/supabase_service_boundary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the root Supabase service boundary.
///
/// Overridden in [bootstrap()] with initialized [SupabaseClientService]
/// or [MockSupabaseService] in test and preview environments.
final supabaseServiceProvider = Provider<ISupabaseService>((ref) {
  // Default fallback to mock service ensuring safe boot without credentials
  return MockSupabaseService();
}, name: 'supabaseServiceProvider');

/// Provider for the Supabase authentication boundary.
final supabaseAuthServiceProvider = Provider<ISupabaseAuthService>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return supabase.auth;
}, name: 'supabaseAuthServiceProvider');

/// Stream provider for live authentication state transitions.
final supabaseAuthStateProvider = StreamProvider<FitKarmaAuthState>((ref) {
  final auth = ref.watch(supabaseAuthServiceProvider);
  return auth.authStateChanges;
}, name: 'supabaseAuthStateProvider');

/// Provider for the currently authenticated user.
final currentUserProvider = Provider<FitKarmaUser?>((ref) {
  final asyncState = ref.watch(supabaseAuthStateProvider);
  return asyncState.value?.user ??
      ref.watch(supabaseAuthServiceProvider).currentUser;
}, name: 'currentUserProvider');

/// Provider checking whether a user is currently logged in.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
}, name: 'isAuthenticatedProvider');
