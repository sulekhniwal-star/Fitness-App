import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/health_insight_model.dart';
import '../../data/providers/insight_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class HealthTwinCard extends ConsumerWidget {
  const HealthTwinCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightState = ref.watch(insightProvider);

    // Find the most impactful unread insight
    final unreadInsights =
        insightState.insights.where((i) => !i.isRead).toList();
    if (unreadInsights.isEmpty) return const SizedBox.shrink();

    // Sort by score descending and then by creation date
    unreadInsights.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return b.createdAt.compareTo(a.createdAt);
    });

    final latestInsight = unreadInsights.first;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      elevation: 4,
      shadowColor:
          _getCategoryColor(latestInsight.category).withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        side: BorderSide(
          color:
              _getCategoryColor(latestInsight.category).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(latestInsight.category)
                  .withValues(alpha: 0.1),
              child: Icon(
                _getCategoryIcon(latestInsight.category),
                color: _getCategoryColor(latestInsight.category),
              ),
            ),
            title: Text(
              latestInsight.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              latestInsight.type.name.toUpperCase(),
              style: TextStyle(
                color: _getTypeColor(latestInsight.type),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => ref
                  .read(insightProvider.notifier)
                  .markAsRead(latestInsight.id),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              latestInsight.description,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(InsightCategory category) {
    switch (category) {
      case InsightCategory.diet:
        return Icons.restaurant;
      case InsightCategory.activity:
        return Icons.bolt;
      case InsightCategory.sleep:
        return Icons.bedtime;
      case InsightCategory.medical:
        return Icons.medical_services;
    }
  }

  Color _getCategoryColor(InsightCategory category) {
    switch (category) {
      case InsightCategory.diet:
        return AppTheme.saffronColor;
      case InsightCategory.activity:
        return AppTheme.mintColor;
      case InsightCategory.sleep:
        return AppTheme.primaryColor;
      case InsightCategory.medical:
        return AppTheme.secondaryColor;
    }
  }

  Color _getTypeColor(InsightType type) {
    switch (type) {
      case InsightType.warning:
        return AppTheme.errorColor;
      case InsightType.pattern:
        return AppTheme.primaryColor;
      case InsightType.recommendation:
      case InsightType.suggestion:
        return AppTheme.accentColor;
      case InsightType.achievement:
        return AppTheme.successColor;
    }
  }
}
