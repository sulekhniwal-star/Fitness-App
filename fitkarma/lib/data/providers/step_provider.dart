import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import '../../core/storage/hive_service.dart';
import 'karma_provider.dart';

class StepState {
  final int steps;
  final String status;
  final String error;

  StepState({
    this.steps = 0,
    this.status = 'unknown',
    this.error = '',
  });

  /// Every 6 steps = 0.1 over. e.g. 500 steps = 83.2 overs.
  String get overs {
    final int oversCount = steps ~/ 6;
    final int ballsCount = steps % 6;
    return '$oversCount.$ballsCount';
  }

  StepState copyWith({
    int? steps,
    String? status,
    String? error,
  }) {
    return StepState(
      steps: steps ?? this.steps,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

class StepNotifier extends StateNotifier<StepState> {
  final Ref _ref;
  StreamSubscription<StepCount>? _stepSubscription;
  StreamSubscription<PedestrianStatus>? _statusSubscription;

  StepNotifier(this._ref) : super(StepState()) {
    _initPedometer();
  }

  String _getDateStr(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _initPedometer() {
    final box = HiveService.stepsBox;
    final todayStr = _getDateStr(DateTime.now());

    // Load existing state for today
    final lastDateStr = box.get('last_date', defaultValue: todayStr);
    int todaySteps = box.get('today_steps', defaultValue: 0);

    if (lastDateStr != todayStr) {
      // It's a new day, rollover
      todaySteps = 0;
      box.put('today_steps', 0);
      box.put('last_date', todayStr);
    }

    state = state.copyWith(steps: todaySteps, status: 'initializing');

    try {
      _statusSubscription = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatusChanged,
        onError: _onPedestrianStatusError,
      );

      _stepSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
      );
    } catch (e) {
      state = state.copyWith(status: 'error', error: e.toString());
    }
  }

  void _onStepCount(StepCount event) {
    final box = HiveService.stepsBox;
    final todayStr = _getDateStr(DateTime.now());

    int newValue = event.steps;

    String lastDateStr = box.get('last_date', defaultValue: todayStr);
    int lastValue = box.get('last_pedometer_value', defaultValue: newValue);

    if (lastDateStr != todayStr) {
      // Rollover crossing midnight
      box.put('today_steps', 0);
      box.put('last_date', todayStr);
      lastValue = newValue; // New baseline
    }

    int diff = newValue - lastValue;
    if (diff < 0) {
      // Phone rebooted, pedometer reset
      diff = newValue;
    }

    int todaySteps = box.get('today_steps', defaultValue: 0) as int;
    int previousMilestones = (todaySteps ~/ 1000);

    todaySteps += diff;

    int newMilestones = (todaySteps ~/ 1000);
    if (newMilestones > previousMilestones) {
      try {
        _importKarmaAndAward(newMilestones - previousMilestones);
      } catch (_) {}
    }

    box.put('today_steps', todaySteps);
    box.put('last_pedometer_value', newValue);

    // Also store historical in a separate key for graphs (e.g., 'history_2026-02-23': 4500)
    box.put('history_$todayStr', todaySteps);

    state = state.copyWith(steps: todaySteps);
  }

  void _importKarmaAndAward(int milestonesCrossed) {
    if (milestonesCrossed <= 0) return;
    try {
      final karmaPoints = milestonesCrossed * 5; // 5 Karma per 1,000 steps
      _ref.read(karmaProvider.notifier).earnKarma(
          karmaPoints, 'Milestone: Reached ${milestonesCrossed * 1000} steps');
    } catch (_) {}
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    state = state.copyWith(status: event.status);
  }

  void _onPedestrianStatusError(error) {
    state = state.copyWith(status: 'error', error: error.toString());
  }

  void _onStepCountError(error) {
    state = state.copyWith(status: 'error', error: error.toString());
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }
}

final stepProvider = StateNotifierProvider<StepNotifier, StepState>((ref) {
  return StepNotifier(ref);
});
