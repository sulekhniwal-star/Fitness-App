import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dosha_model.dart';
import 'auth_provider.dart';
import '../../../core/network/pocketbase_client.dart';

class DoshaState {
  final DoshaResult? result;
  final bool isLoading;
  final String? error;

  DoshaState({this.result, this.isLoading = false, this.error});

  DoshaState copyWith({DoshaResult? result, bool? isLoading, String? error}) {
    return DoshaState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DoshaNotifier extends StateNotifier<DoshaState> {
  final Ref _ref;

  DoshaNotifier(this._ref) : super(DoshaState());

  Future<void> setResult(DoshaResult result) async {
    state = state.copyWith(result: result, isLoading: true);

    try {
      final pb = _ref.read(pocketBaseProvider);
      final user = _ref.read(authStateProvider).user;

      if (user != null) {
        // 1. Update PocketBase
        await pb.collection('users').update(user.id, body: {
          'dosha': result.dominantDosha.name,
        });

        // 2. Update Local State & Hive
        final updatedUser = user.copyWith(dosha: result.dominantDosha.name);
        _ref.read(authStateProvider.notifier).updateUser(updatedUser);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearResult() {
    state = DoshaState();
  }
}

final doshaProvider = StateNotifierProvider<DoshaNotifier, DoshaState>((ref) {
  return DoshaNotifier(ref);
});
