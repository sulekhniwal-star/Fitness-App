import 'package:fitkarma/core/supabase/supabase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navigation authentication status.
enum AuthNavStatus { initial, authenticated, unauthenticated }

/// Provider managing the auth navigation state.
///
/// Binds to [isAuthenticatedProvider] from the Supabase client boundary.
final authNavStatusProvider = Provider<AuthNavStatus>(
  (ref) {
    final isAuth = ref.watch(isAuthenticatedProvider);
    return isAuth ? AuthNavStatus.authenticated : AuthNavStatus.unauthenticated;
  },
  name: 'authNavStatusProvider',
);
