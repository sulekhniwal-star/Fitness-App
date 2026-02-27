import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/storage/hive_service.dart';
import '../../core/network/pocketbase_client.dart';
import '../../core/sync/sync_service.dart';
import '../models/activity_log_model.dart';
import 'auth_provider.dart';

class ActivityLogState {
  final List<ActivityLogModel> logs;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  ActivityLogState({
    this.logs = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  ActivityLogState copyWith({
    List<ActivityLogModel>? logs,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return ActivityLogState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }

  List<ActivityLogModel> get todayLogs {
    final now = DateTime.now();
    return logs.where((log) {
      return log.timestamp.year == now.year &&
          log.timestamp.month == now.month &&
          log.timestamp.day == now.day;
    }).toList();
  }

  List<ActivityLogModel> get thisWeekLogs {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return logs.where((log) => log.timestamp.isAfter(weekAgo)).toList();
  }

  Map<String, List<ActivityLogModel>> get groupedByDate {
    final grouped = <String, List<ActivityLogModel>>{};
    for (final log in logs) {
      final key = '${log.timestamp.year}-${log.timestamp.month.toString().padLeft(2, '0')}-${log.timestamp.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(log);
    }
    return grouped;
  }
}

class ActivityLogNotifier extends StateNotifier<ActivityLogState> {
  final Ref _ref;
  static const _uuid = Uuid();
  static const int _pageSize = 20;

  ActivityLogNotifier(this._ref) : super(ActivityLogState()) {
    _loadLocalLogs();
  }

  void _loadLocalLogs() {
    final logs = HiveService.activityLogBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    state = state.copyWith(logs: logs);
    fetchLogs();
  }

  Future<void> fetchLogs({bool refresh = false}) async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = _ref.read(authStateProvider).user;
      if (user == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final pb = _ref.read(pocketBaseProvider);
      final result = await pb.collection('activity_logs').getList(
        page: refresh ? 1 : (state.logs.length ~/ _pageSize) + 1,
        perPage: _pageSize,
        filter: 'user = "${user.id}"',
        sort: '-timestamp',
      );

      final fetchedLogs = result.items
          .map((item) => ActivityLogModel.fromJson(item.toJson()))
          .toList();

      if (refresh) {
        await HiveService.activityLogBox.clear();
      }

      for (final log in fetchedLogs) {
        await HiveService.activityLogBox.put(log.id, log);
      }

      final allLogs = HiveService.activityLogBox.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      state = state.copyWith(
        logs: allLogs,
        isLoading: false,
        hasMore: fetchedLogs.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch activity logs: $e',
      );
    }
  }

  Future<void> addActivityLog({
    required String activityType,
    required String description,
    Map<String, dynamic> metadata = const {},
    int? karmaPoints,
    String? relatedRecordId,
  }) async {
    final user = _ref.read(authStateProvider).user;
    if (user == null) return;

    final log = ActivityLogModel(
      id: _uuid.v4(),
      userId: user.id,
      activityType: activityType,
      description: description,
      timestamp: DateTime.now(),
      metadata: metadata,
      karmaPoints: karmaPoints,
      relatedRecordId: relatedRecordId,
    );

    // Save locally first
    await HiveService.activityLogBox.put(log.id, log);

    // Update state
    final updatedLogs = [log, ...state.logs];
    state = state.copyWith(logs: updatedLogs);

    // Queue for sync
    _ref.read(syncServiceProvider).enqueueAction(
      collection: 'activity_logs',
      operation: 'create',
      recordId: log.id,
      data: log.toJson(),
    );
  }

  Future<void> logStepActivity(int steps, int calories) async {
    await addActivityLog(
      activityType: 'steps',
      description: 'Walked $steps steps',
      metadata: {
        'steps': steps,
        'calories_burned': calories,
      },
    );
  }

  Future<void> logWorkoutActivity(String workoutName, int duration, int calories) async {
    await addActivityLog(
      activityType: 'workout',
      description: 'Completed $workoutName workout',
      metadata: {
        'workout_name': workoutName,
        'duration_minutes': duration,
        'calories_burned': calories,
      },
    );
  }

  Future<void> logFoodActivity(String foodName, double calories, String mealType) async {
    await addActivityLog(
      activityType: 'food',
      description: 'Logged $foodName ($mealType)',
      metadata: {
        'food_name': foodName,
        'calories': calories,
        'meal_type': mealType,
      },
    );
  }

  Future<void> logWaterActivity(int amount) async {
    await addActivityLog(
      activityType: 'water',
      description: 'Drank ${amount}ml water',
      metadata: {
        'amount_ml': amount,
      },
    );
  }

  Future<void> logWeightActivity(double weight) async {
    await addActivityLog(
      activityType: 'weight',
      description: 'Recorded weight: ${weight}kg',
      metadata: {
        'weight_kg': weight,
      },
    );
  }

  Future<void> logKarmaActivity(int points, String reason) async {
    await addActivityLog(
      activityType: 'karma',
      description: 'Earned $points karma points: $reason',
      karmaPoints: points,
      metadata: {
        'points': points,
        'reason': reason,
      },
    );
  }

  Future<void> logChallengeActivity(String challengeName, String action) async {
    await addActivityLog(
      activityType: 'challenge',
      description: '$action challenge: $challengeName',
      metadata: {
        'challenge_name': challengeName,
        'action': action,
      },
    );
  }

  Future<void> deleteLog(String logId) async {
    await HiveService.activityLogBox.delete(logId);
    
    final updatedLogs = state.logs.where((l) => l.id != logId).toList();
    state = state.copyWith(logs: updatedLogs);

    _ref.read(syncServiceProvider).enqueueAction(
      collection: 'activity_logs',
      operation: 'delete',
      recordId: logId,
      data: {},
    );
  }

  Future<void> clearAllLogs() async {
    await HiveService.activityLogBox.clear();
    state = state.copyWith(logs: [], hasMore: true);
  }
}

final activityLogProvider = StateNotifierProvider<ActivityLogNotifier, ActivityLogState>((ref) {
  return ActivityLogNotifier(ref);
});
