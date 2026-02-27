import 'package:hive/hive.dart';

part 'activity_log_model.g.dart';

@HiveType(typeId: 15)
class ActivityLogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String activityType; // 'steps', 'workout', 'food', 'water', 'weight', 'medical'

  @HiveField(3)
  final String description;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final Map<String, dynamic> metadata; // Additional data like calories burned, duration, etc.

  @HiveField(6)
  final int? karmaPoints; // Points earned for this activity

  @HiveField(7)
  final String? relatedRecordId; // ID of the related record (workout_log, food_log, etc.)

  ActivityLogModel({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.description,
    required this.timestamp,
    this.metadata = const {},
    this.karmaPoints,
    this.relatedRecordId,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] as String,
      userId: json['user'] as String,
      activityType: json['activity_type'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      karmaPoints: json['karma_points'] as int?,
      relatedRecordId: json['related_record_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'activity_type': activityType,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'karma_points': karmaPoints,
      'related_record_id': relatedRecordId,
    };
  }

  ActivityLogModel copyWith({
    String? id,
    String? userId,
    String? activityType,
    String? description,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    int? karmaPoints,
    String? relatedRecordId,
  }) {
    return ActivityLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityType: activityType ?? this.activityType,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      karmaPoints: karmaPoints ?? this.karmaPoints,
      relatedRecordId: relatedRecordId ?? this.relatedRecordId,
    );
  }

  String get formattedTimestamp {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  String get icon {
    switch (activityType) {
      case 'steps':
        return '👟';
      case 'workout':
        return '💪';
      case 'food':
        return '🍽️';
      case 'water':
        return '💧';
      case 'weight':
        return '⚖️';
      case 'medical':
        return '📋';
      case 'karma':
        return '✨';
      case 'challenge':
        return '🏆';
      default:
        return '📱';
    }
  }

  String get colorHex {
    switch (activityType) {
      case 'steps':
        return '#4CAF50';
      case 'workout':
        return '#FF5722';
      case 'food':
        return '#FF9800';
      case 'water':
        return '#2196F3';
      case 'weight':
        return '#9C27B0';
      case 'medical':
        return '#F44336';
      case 'karma':
        return '#FFD700';
      case 'challenge':
        return '#00BCD4';
      default:
        return '#757575';
    }
  }
}
