import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/providers/food_provider.dart';
import '../../../data/repositories/food_repository.dart';
import '../../../data/models/food_log_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/karma_provider.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/storage/hive_service.dart';

class FoodSearchDelegate extends SearchDelegate<void> {
  final WidgetRef ref;
  final String mealType;

  FoodSearchDelegate({required this.ref, required this.mealType});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            ref.read(foodSearchProvider.notifier).clear();
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Dispatch search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (query.isNotEmpty) {
        ref.read(foodSearchProvider.notifier).search(query);
      }
    });

    return _buildBody();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) {
      // Auto-search as they type isn't ideal for API rate limits unless debounced
      // For MVP we just show a hint to press enter, or we can trigger it
    }
    return Center(
      child: Text('Type a food name and press search...'),
    );
  }

  Widget _buildBody() {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(foodSearchProvider);

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(child: Text('Error: ${state.error}'));
        }

        if (state.items.isEmpty) {
          return const Center(child: Text('No results found.'));
        }

        return ListView.builder(
          itemCount: state.items.length,
          itemBuilder: (context, index) {
            final item = state.items[index];
            return ListTile(
              leading: item.imageUrl.isNotEmpty
                  ? Image.network(item.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.fastfood, size: 40))
                  : const Icon(Icons.fastfood, size: 40),
              title: Text(item.name),
              subtitle: Text(
                  '${item.calories.toStringAsFixed(0)} cal | P: ${item.proteinGrams.toStringAsFixed(1)} | C: ${item.carbsGrams.toStringAsFixed(1)} | F: ${item.fatGrams.toStringAsFixed(1)}'),
              onTap: () {
                _logFood(context, item);
              },
            );
          },
        );
      },
    );
  }

  void _logFood(BuildContext context, FoodItem item) async {
    // Log food with default 100g quantity for MVP
    final user = ref.read(authStateProvider).user;
    if (user == null) return;

    final log = FoodLogModel(
      id: const Uuid().v4(),
      userId: user.id,
      date: DateTime.now(),
      mealType: mealType,
      foodItemId: item.id,
      foodName: item.name,
      quantityGrams: 100.0,
      calories: item.calories,
      proteinGrams: item.proteinGrams,
      carbsGrams: item.carbsGrams,
      fatGrams: item.fatGrams,
      loggedVia: 'search',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to Hive
    await HiveService.foodLogBox.put(log.id, log);

    // Sync to backend
    ref.read(syncServiceProvider).enqueueAction(
          collection: 'food_logs',
          operation: 'create',
          data: log.toJson(),
        );

    // Grant Karma
    ref.read(karmaProvider.notifier).earnKarma(5, 'Logged meal');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged ${item.name}! +5 Karma'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );

    close(context, null);
  }
}
