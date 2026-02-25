import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../models/user_model.dart';
import 'pocketbase_provider.dart';
import 'hive_provider.dart';

/// Auth state
enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      // Check Hive for cached user
      final cachedUser = HiveProvider.getCurrentUser();
      if (cachedUser != null && PocketBaseProvider.isAuthenticated) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: cachedUser,
        );
        return;
      }
      
      // Check PocketBase auth
      if (PocketBaseProvider.isAuthenticated) {
        final pb = PocketBaseProvider.instance;
        final userId = PocketBaseProvider.currentUserId;
        
        if (userId != null) {
          final record = await pb.collection('users').getOne(userId);
          final user = UserModel.fromJson(record.toJson());
          await HiveProvider.saveUser(user);
          
          state = AuthState(
            status: AuthStatus.authenticated,
            user: user,
          );
          return;
        }
      }
      
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final pb = PocketBaseProvider.instance;
      final authData = await pb.collection('users').authWithPassword(
        email,
        password,
      );
      
      final user = UserModel.fromJson(authData.record.toJson());
      await HiveProvider.saveUser(user);
      await PocketBaseProvider.saveAuth(authData.token, user.id);
      
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } on ClientException catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.response['message'] ?? 'Login failed',
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signUpWithEmail(String email, String password, String name) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final pb = PocketBaseProvider.instance;
      
      // Create user
      await pb.collection('users').create({
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'name': name,
      });
      
      // Auto-login after registration
      await signInWithEmail(email, password);
    } on ClientException catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.response['message'] ?? 'Registration failed',
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    // Note: OAuth2 requires additional setup in PocketBase
    // This is a placeholder - implement with actual OAuth flow
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      error: 'Google OAuth requires additional setup. Use email login.',
    );
  }

  Future<void> signOut() async {
    await PocketBaseProvider.clearAuth();
    await HiveProvider.deleteUser();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

/// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
