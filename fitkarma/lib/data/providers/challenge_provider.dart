import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_model.dart';
import '../../core/network/pocketbase_client.dart';
import '../../core/storage/hive_service.dart';

class ChallengeState {
  final List<ChallengeModel> challenges;
  final bool isLoading;
  final String? error;

  ChallengeState({
    this.challenges = const [],
    this.isLoading = false,
    this.error,
  });

  ChallengeState copyWith({
    List<ChallengeModel>? challenges,
    bool? isLoading,
    String? error,
  }) {
    return ChallengeState(
      challenges: challenges ?? this.challenges,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChallengeNotifier extends StateNotifier<ChallengeState> {
  final Ref _ref;

  ChallengeNotifier(this._ref) : super(ChallengeState()) {
    _loadFromCache();
    fetchChallenges();
  }

  void _loadFromCache() {
    final cached = HiveService.challengesBox.values.toList();
    if (cached.isNotEmpty) {
      state = state.copyWith(challenges: cached);
    }
  }

  Future<void> fetchChallenges() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final pb = _ref.read(pocketBaseProvider);
      final result = await pb.collection('challenges').getList(
            sort: '-created',
            filter: 'end_date > @now', // Only active or upcoming
          );

      final challenges = result.items
          .map((item) => ChallengeModel.fromJson(item.toJson()))
          .toList();

      // Update cache
      await HiveService.challengesBox.clear();
      await HiveService.challengesBox.addAll(challenges);

      state = state.copyWith(challenges: challenges, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> joinChallenge(String challengeId) async {
    try {
      final pb = _ref.read(pocketBaseProvider);
      final userId = pb.authStore.record?.id;
      if (userId == null) throw Exception('User not authenticated');

      final challenge = state.challenges.firstWhere((c) => c.id == challengeId);
      final participants = List<String>.from(challenge.participants);

      if (!participants.contains(userId)) {
        participants.add(userId);
        await pb.collection('challenges').update(challengeId, body: {
          'participants+': userId,
        });

        // Optimistic UI update
        state = state.copyWith(
          challenges: state.challenges
              .map((c) => c.id == challengeId
                  ? c.copyWith(participants: participants)
                  : c)
              .toList(),
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to join challenge: $e');
    }
  }
}

final challengeProvider =
    StateNotifierProvider<ChallengeNotifier, ChallengeState>((ref) {
  return ChallengeNotifier(ref);
});
