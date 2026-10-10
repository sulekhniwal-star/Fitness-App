import 'package:fitkarma/features/auth/domain/models/account_lifecycle_models.dart';

/// Contract for coordinating idempotent, complete wiping of local data upon
/// account deletion, explicit sign-out, or safe session termination.
abstract interface class ILocalDataWipeCoordinator {
  /// Wipes all registered client-side stores, memory caches, and persisted states.
  Future<LocalWipeResult> wipeAllLocalData();

  /// Registers a domain store's cleanup callback.
  void registerWipeableStore(String name, Future<void> Function() onWipe);

  /// Unregisters a domain store's cleanup callback.
  void unregisterWipeableStore(String name);
}

/// Implementation of [ILocalDataWipeCoordinator] that executes all registered
/// store cleanup callbacks sequentially and safely without throwing uncaught exceptions.
class LocalDataWipeCoordinator implements ILocalDataWipeCoordinator {
  final Map<String, Future<void> Function()> _stores = {};

  @override
  void registerWipeableStore(String name, Future<void> Function() onWipe) {
    _stores[name] = onWipe;
  }

  @override
  void unregisterWipeableStore(String name) {
    _stores.remove(name);
  }

  @override
  Future<LocalWipeResult> wipeAllLocalData() async {
    final List<String> successfullyWiped = [];
    String? firstError;

    for (final entry in _stores.entries) {
      try {
        await entry.value();
        successfullyWiped.add(entry.key);
      } catch (e) {
        firstError ??= 'Error wiping ${entry.key}: $e';
      }
    }

    if (firstError != null) {
      return LocalWipeResult.failure(firstError, successfullyWiped);
    }

    return LocalWipeResult.success(successfullyWiped);
  }
}
