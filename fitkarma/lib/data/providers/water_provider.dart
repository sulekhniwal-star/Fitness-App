import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/water_log_model.dart';
import '../../core/storage/hive_service.dart';
import '../../core/sync/sync_service.dart';
import 'auth_provider.dart';
import 'karma_provider.dart';
import '../../core/constants/app_constants.dart';

class WaterState {
  final int todayAmount;
  final int goalMl;
  final List<WaterLogModel> logs;
  final bool isLoading;
  final String? error;

  WaterState({
    this.todayAmount = 0,
    this.goalMl = 2500,
    this.logs = const [],
    this.isLoading = false,
    this.error,
  });

  double get progressPercent {
    if (goalMl <= 0) return 0;
    return (todayAmount / goalMl).clamp(0.0, 1.0);
  }

  int get remainingMl => (goalMl - todayAmount).clamp(0, goalMl);

  WaterState copyWith({
    int? todayAmount,
    int? goalMl,
    List<WaterLogModel>? logs,
    bool? isLoading,
    String? error,
  }) {
    return WaterState(
      todayAmount: todayAmount ?? this.todayAmount,
      goalMl: goalMl ?? this.goalMl,
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WaterNotifier extends StateNotifier<WaterState> {
  final Ref _ref;

  WaterNotifier(this._ref) : super(WaterState()) {
    _loadWaterData();
  }

  String _getDateStr(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadWaterData() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final box = HiveService.waterBox;
      final todayStr = _getDateStr(DateTime.now());
      
      // Get today's total
      int todayTotal = box.get('today_$todayStr', defaultValue: 0) as int;
      
      // Get goal
      int goal = HiveService.getSetting<int>('water_goal', defaultValue: AppConstants.defaultWaterGoalML) ?? AppConstants.defaultWaterGoalML;
      
      // Get logs for today
      final List<WaterLogModel> todayLogs = [];
      final keys = box.keys.where((k) => k.toString().startsWith('log_$todayStr'));
      for (final key in keys) {
        final log = box.get(key);
        if (log != null && log is WaterLogModel) {
          todayLogs.add(log);
        }
      }
      
      state = state.copyWith(
        todayAmount: todayTotal,
        goalMl: goal,
        logs: todayLogs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addWater(int amountMl) async {
    final user = _ref.read(authStateProvider).user;
    if (user == null) return;

    try {
      final now = DateTime.now();
      final todayStr = _getDateStr(now);
      
      final log = WaterLogModel(
        id: const Uuid().v4(),
        userId: user.id,
        date: now,
        amountMl: amountMl,
        goalMl: state.goalMl,
        time: now,
        createdAt: now,
        updatedAt: now,
      );

      // Save to Hive
      final box = HiveService.waterBox;
      await box.put('log_${log.id}', log);
      
      // Update today's total
      int newTotal = state.todayAmount + amountMl;
      await box.put('today_$todayStr', newTotal);
      
      // Update logs list
      final newLogs = [...state.logs, log];
      
      state = state.copyWith(
        todayAmount: newTotal,
        logs: newLogs,
      );

      // Sync to backend
      _ref.read(syncServiceProvider).enqueueAction(
        collection: 'water_logs',
        operation: 'create',
        data: log.toJson(),
        recordId: log.id,
      );

      // Check if goal reached and award karma
      if (state.todayAmount >= state.goalMl && newTotal - amountMl < state.goalMl) {
        _ref.read(karmaProvider.notifier).earnKarma(
          AppConstants.karmaStepGoal, // Reuse this constant for water goal
          'Reached daily water goal',
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> setGoal(int goalMl) async {
    await HiveService.saveSetting('water_goal', goalMl);
    state = state.copyWith(goalMl: goalMl);
  }

  Future<void> removeLastEntry() async {
    if (state.logs.isEmpty) return;

    try {
      final lastLog = state.logs.last;
      final box = HiveService.waterBox;
      final todayStr = _getDateStr(DateTime.now());
      
      // Remove from Hive
      await box.delete('log_${lastLog.id}');
      
      // Update today's total
      int newTotal = (state.todayAmount - lastLog.amountMl).clamp(0, state.todayAmount);
      await box.put('today_$todayStr', newTotal);
      
      // Update logs list
      final newLogs = [...state.logs]..removeLast();
      
      state = state.copyWith(
        todayAmount: newTotal,
        logs: newLogs,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> resetToday() async {
    try {
      final box = HiveService.waterBox;
      final todayStr = _getDateStr(DateTime.now());
      
      // Clear today's data
      await box.put('today_$todayStr', 0);
      
      // Remove all logs for today
      final keys = box.keys.where((k) => k.toString().startsWith('log_$todayStr')).toList();
      for (final key in keys) {
        await box.delete(key);
      }
      
      state = state.copyWith(
        todayAmount: 0,
        logs: [],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final waterProvider = StateNotifierProvider<WaterNotifier, WaterState>((ref) {
  return WaterNotifier(ref);
});
