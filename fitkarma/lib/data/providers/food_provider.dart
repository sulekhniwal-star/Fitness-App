import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/food_repository.dart';

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
