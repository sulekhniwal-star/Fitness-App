import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/festival_model.dart';

class FestivalState {
  final List<Festival> allFestivals;
  final Festival? todayFestival;
  final bool isFestivalDay;

  FestivalState({
    required this.allFestivals,
    this.todayFestival,
    this.isFestivalDay = false,
  });

  FestivalState copyWith({
    List<Festival>? allFestivals,
    Festival? todayFestival,
    bool? isFestivalDay,
  }) {
    return FestivalState(
      allFestivals: allFestivals ?? this.allFestivals,
      todayFestival: todayFestival, // Can be null
      isFestivalDay: isFestivalDay ?? this.isFestivalDay,
    );
  }
}

class FestivalNotifier extends StateNotifier<FestivalState> {
  FestivalNotifier() : super(FestivalState(allFestivals: [])) {
    _init();
  }

  void _init() {
    final now = DateTime.now();
    final festivals = FestivalRepository.getFestivalsForYear(now.year);

    // Check if today is a festival
    final today = festivals
        .where((f) => f.date.day == now.day && f.date.month == now.month)
        .firstOrNull;

    state = FestivalState(
      allFestivals: festivals,
      todayFestival: today,
      isFestivalDay: today != null,
    );
  }

  // Returns adjusted calorie goal based on festival multiplier
  double getAdjustedCalorieGoal(double baseGoal) {
    if (state.todayFestival != null) {
      return baseGoal * state.todayFestival!.calorieMultiplier;
    }
    return baseGoal;
  }
}

final festivalProvider =
    StateNotifierProvider<FestivalNotifier, FestivalState>((ref) {
  return FestivalNotifier();
});
