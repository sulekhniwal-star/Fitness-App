import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../../core/network/pocketbase_client.dart';

class LeaderboardState {
  final List<UserModel> topUsers;
  final bool isLoading;
  final String? error;

  LeaderboardState({
    this.topUsers = const [],
    this.isLoading = false,
    this.error,
  });

  LeaderboardState copyWith({
    List<UserModel>? topUsers,
    bool? isLoading,
    String? error,
  }) {
    return LeaderboardState(
      topUsers: topUsers ?? this.topUsers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final Ref _ref;

  LeaderboardNotifier(this._ref) : super(LeaderboardState()) {
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final pb = _ref.read(pocketBaseProvider);

      // Fetch top 50 users by karma_points
      final result = await pb.collection('users').getList(
            page: 1,
            perPage: 50,
            sort: '-karma_points',
          );

      final users = result.items
          .map((item) => UserModel.fromJson(item.toJson()))
          .toList();
      state = state.copyWith(topUsers: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  return LeaderboardNotifier(ref);
});
