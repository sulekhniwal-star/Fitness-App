import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_insight_model.dart';
import '../../core/storage/hive_service.dart';

class InsightState {
  final List<HealthInsight> insights;
  final bool isLoading;

  InsightState({
    this.insights = const [],
    this.isLoading = false,
  });

  InsightState copyWith({
    List<HealthInsight>? insights,
    bool? isLoading,
  }) {
    return InsightState(
      insights: insights ?? this.insights,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class InsightNotifier extends StateNotifier<InsightState> {
  InsightNotifier() : super(InsightState()) {
    _loadInsights();
  }

  void _loadInsights() {
    final insights = HiveService.insightsBox.values.toList();
    // Sort by createdAt descending
    insights.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = state.copyWith(insights: insights);
  }

  Future<void> addInsight(HealthInsight insight) async {
    await HiveService.insightsBox.put(insight.id, insight);
    _loadInsights();
  }

  Future<void> markAsRead(String id) async {
    final insight = HiveService.insightsBox.get(id);
    if (insight != null) {
      final updated = insight.copyWith(isRead: true);
      await HiveService.insightsBox.put(id, updated);
      _loadInsights();
    }
  }

  Future<void> clearAll() async {
    await HiveService.insightsBox.clear();
    _loadInsights();
  }
}

final insightProvider =
    StateNotifierProvider<InsightNotifier, InsightState>((ref) {
  return InsightNotifier();
});
