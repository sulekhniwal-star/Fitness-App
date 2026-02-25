import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_constants.dart';

/// PocketBase client provider
final pocketBaseProvider = Provider<PocketBase>((ref) {
  return PocketBase(AppConstants.pocketBaseUrl);
});

/// Secure storage provider for tokens
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
});

/// PocketBase authentication provider
class PocketBaseProvider {
  static PocketBase? _pb;
  static const String _tokenKey = 'pocketbase_auth_token';
  static const String _userKey = 'pocketbase_user_id';

  static Future<void> initialize() async {
    _pb = PocketBase(AppConstants.pocketBaseUrl);
    
    // Try to restore existing auth
    await _restoreAuth();
  }

  static PocketBase get instance {
    if (_pb == null) {
      throw Exception('PocketBase not initialized. Call initialize() first.');
    }
    return _pb!;
  }

  static Future<void> _restoreAuth() async {
    if (_pb == null) return;
    
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: _tokenKey);
    final userId = await storage.read(key: _userKey);
    
    if (token != null && userId != null) {
      _pb!.authStore.save(token, {'id': userId});
    }
  }

  static Future<void> saveAuth(String token, String userId) async {
    final storage = const FlutterSecureStorage();
    await storage.write(key: _tokenKey, value: token);
    await storage.write(key: _userKey, value: userId);
  }

  static Future<void> clearAuth() async {
    final storage = const FlutterSecureStorage();
    await storage.delete(key: _tokenKey);
    await storage.delete(key: _userKey);
    _pb?.authStore.clear();
  }

  static bool get isAuthenticated {
    return _pb?.authStore.isValid ?? false;
  }

  static String? get currentUserId {
    return _pb?.authStore.model?.id;
  }
}
