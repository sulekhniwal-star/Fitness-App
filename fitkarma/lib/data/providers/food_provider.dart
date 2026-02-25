import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../repositories/food_repository.dart';
import '../models/food_log_model.dart';
import '../../core/storage/hive_service.dart';
import '../../core/sync/sync_service.dart';
import 'auth_provider.dart';
import 'karma_provider.dart';

// Provides a singleton instance of FoodRepository
final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return FoodRepository();
});

class FoodSearchState {
  final bool isLoading;
  final List<FoodItem> items;
  final String? error;

  FoodSearchState({
    this.isLoading = false,
    this.items = const [],
    this.error,
  });

  FoodSearchState copyWith({
    bool? isLoading,
    List<FoodItem>? items,
    String? error,
  }) {
    return FoodSearchState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }
}

class FoodSearchNotifier extends StateNotifier<FoodSearchState> {
  final Ref _ref;

  FoodSearchNotifier(this._ref) : super(FoodSearchState());

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = FoodSearchState();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = _ref.read(foodRepositoryProvider);
      final results = await repo.searchFood(query);

      state = state.copyWith(
        isLoading: false,
        items: results,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchBarcode(String barcode) async {
    if (barcode.isEmpty) {
      state = FoodSearchState();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = _ref.read(foodRepositoryProvider);
      final item = await repo.getFoodByBarcode(barcode);

      state = state.copyWith(
        isLoading: false,
        items: item != null ? [item] : [],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clear() {
    state = FoodSearchState();
  }
}

final foodSearchProvider =
    StateNotifierProvider<FoodSearchNotifier, FoodSearchState>((ref) {
  return FoodSearchNotifier(ref);
});

class FoodLogNotifier extends StateNotifier<void> {
  final Ref _ref;

  FoodLogNotifier(this._ref) : super(null);

  Future<void> logFood({
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required String mealType,
    String? foodItemId,
    String loggedVia = 'manual',
  }) async {
    final user = _ref.read(authStateProvider).user;
    if (user == null) return;

    final log = FoodLogModel(
      id: const Uuid().v4(),
      userId: user.id,
      date: DateTime.now(),
      mealType: mealType,
      foodItemId: foodItemId ?? 'manual',
      foodName: name,
      quantityGrams: 100.0,
      calories: calories,
      proteinGrams: protein,
      carbsGrams: carbs,
      fatGrams: fat,
      loggedVia: loggedVia,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to Hive
    await HiveService.foodLogBox.put(log.id, log);

    // Sync to backend
    _ref.read(syncServiceProvider).enqueueAction(
          collection: 'food_logs',
          operation: 'create',
          data: log.toJson(),
        );

    // Grant Karma
    _ref.read(karmaProvider.notifier).earnKarma(5, 'Logged $name');
  }
}

final foodLogProvider = StateNotifierProvider<FoodLogNotifier, void>((ref) {
  return FoodLogNotifier(ref);
});
