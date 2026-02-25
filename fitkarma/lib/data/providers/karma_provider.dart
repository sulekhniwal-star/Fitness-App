import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/sync/sync_service.dart';
import 'auth_provider.dart';

class KarmaNotifier extends StateNotifier<int> {
  final Ref _ref;

  KarmaNotifier(this._ref) : super(0) {
    // initialize from auth state
    final authState = _ref.read(authStateProvider);
    if (authState.user != null) {
      state = authState.user!.karmaPoints;
    }

    // Listen to changes in authstate
    _ref.listen(authStateProvider, (previous, next) {
      if (next.user != null && next.user!.karmaPoints != state) {
        state = next.user!.karmaPoints;
      } else if (next.user == null) {
        state = 0;
      }
    });
  }

  void earnKarma(int amount, String reason) {
    if (amount <= 0) return;

    final authState = _ref.read(authStateProvider);
    final currentUser = authState.user;
    if (currentUser == null) return;

    final newKarma = currentUser.karmaPoints + amount;

    // Update local state and auth model
    state = newKarma;
    final updatedUser = currentUser.copyWith(karmaPoints: newKarma);

    // Update AuthNotifier to save to Hive & notify overarching UI
    _ref.read(authStateProvider.notifier).updateUser(updatedUser);

    // Queue update operation to SyncService targeting the users PocketBase
    _ref.read(syncServiceProvider).enqueueAction(
      collection: 'users',
      operation: 'update',
      recordId: updatedUser.id,
      data: {'karma_points': newKarma},
    );
  }
}

final karmaProvider = StateNotifierProvider<KarmaNotifier, int>((ref) {
  return KarmaNotifier(ref);
});
