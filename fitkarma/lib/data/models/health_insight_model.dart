import 'package:hive/hive.dart';

part 'health_insight_model.g.dart';

@HiveType(typeId: 10)
enum InsightType {
  @HiveField(0)
  pattern,
  @HiveField(1)
  warning,
  @HiveField(2)
  recommendation,
  @HiveField(3)
  achievement,
  @HiveField(4)
  suggestion,
}

@HiveType(typeId: 11)
enum InsightCategory {
  @HiveField(0)
  diet,
  @HiveField(1)
  activity,
  @HiveField(2)
  sleep,
  @HiveField(3)
  medical,
}

@HiveType(typeId: 12)
class HealthInsight extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final InsightType type;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final InsightCategory category;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final bool isRead;

  @HiveField(7)
  final double score;

  HealthInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    this.isRead = false,
    this.score = 1.0,
  });

  HealthInsight copyWith({
    bool? isRead,
  }) {
    return HealthInsight(
      id: id,
      type: type,
      title: title,
      description: description,
      category: category,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      score: score,
    );
  }
}
