import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/weight_log_model.dart';
import '../../core/storage/hive_service.dart';
import '../../core/sync/sync_service.dart';
import 'auth_provider.dart';

class WeightNotifier extends StateNotifier<List<WeightLogModel>> {
  final Ref _ref;

  WeightNotifier(this._ref) : super([]) {
    _loadHistory();
  }

  void _loadHistory() {
    final box = HiveService.weightBox;
    final logs = box.values.cast<WeightLogModel>().toList();
    logs.sort((a, b) => b.date.compareTo(a.date));
    state = logs;
  }

  Future<void> logWeight(double newWeightKg, double heightCm) async {
    final authState = _ref.read(authStateProvider);
    final user = authState.user;
    if (user == null) return;

    // Calculate BMI
    // BMI = weight(kg) / (height(m) * height(m))
    final heightM = heightCm / 100;
    final bmi = heightM > 0 ? (newWeightKg / (heightM * heightM)) : 0.0;

    final log = WeightLogModel(
      id: const Uuid().v4(),
      userId: user.id,
      weightKg: newWeightKg,
      bmi: bmi,
      date: DateTime.now(),
    );

    // Save to Hive locally
    await HiveService.weightBox.put(log.id, log);

    // Reload State
    _loadHistory();

    // Update global user model
    final updatedUser = user.copyWith(
      weightKg: newWeightKg,
      heightCm: heightCm,
    );
    _ref.read(authStateProvider.notifier).updateUser(updatedUser);

    // Sync log to PocketBase
    _ref.read(syncServiceProvider).enqueueAction(
          collection: 'weight_logs',
          operation: 'create',
          data: log.toJson(),
        );

    // Sync updated user globally to PocketBase
    _ref.read(syncServiceProvider).enqueueAction(
      collection: 'users',
      operation: 'update',
      recordId: updatedUser.id,
      data: {
        'weight_kg': newWeightKg,
        'height_cm': heightCm,
      },
    );
  }
}

final weightProvider =
    StateNotifierProvider<WeightNotifier, List<WeightLogModel>>((ref) {
  return WeightNotifier(ref);
});
