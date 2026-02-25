import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';
import '../constants/app_constants.dart';

/// Provider for the initial auth state string loaded from secure storage.
/// This MUST be overridden in the root ProviderScope in main.dart.
final initialPbAuthProvider = Provider<String?>((ref) => null);

/// A provider that exposes the PocketBase client.
final pocketBaseProvider = Provider<PocketBase>((ref) {
  final initialAuth = ref.watch(initialPbAuthProvider);
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final authStore = AsyncAuthStore(
    save: (String data) async {
      await secureStorage.write(key: 'pb_auth', value: data);
    },
    initial: initialAuth,
    clear: () async {
      await secureStorage.delete(key: 'pb_auth');
    },
  );

  return PocketBase(AppConstants.pocketBaseUrl, authStore: authStore);
});
