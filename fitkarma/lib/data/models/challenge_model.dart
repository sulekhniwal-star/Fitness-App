import 'package:hive/hive.dart';

part 'challenge_model.g.dart';

@HiveType(typeId: 6)
class ChallengeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String goalType; // e.g., 'steps', 'workout', 'calories'

  @HiveField(4)
  final double goalValue;

  @HiveField(5)
  final int rewardPoints;

  @HiveField(6)
  final DateTime startDate;

  @HiveField(7)
  final DateTime endDate;

  @HiveField(8)
  final List<String> participants;

  @HiveField(9)
  final String? imageUrl;

  @HiveField(10)
  final bool isTeamChallenge;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.goalType,
    required this.goalValue,
    required this.rewardPoints,
    required this.startDate,
    required this.endDate,
    this.participants = const [],
    this.imageUrl,
    this.isTeamChallenge = false,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      goalType: json['goal_type'] as String? ?? 'steps',
      goalValue: (json['goal_value'] as num?)?.toDouble() ?? 0.0,
      rewardPoints: json['reward_points'] as int? ?? 0,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      participants: List<String>.from(json['participants'] ?? []),
      imageUrl: json['image'] as String?,
      isTeamChallenge: json['is_team_challenge'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'goal_type': goalType,
      'goal_value': goalValue,
      'reward_points': rewardPoints,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'participants': participants,
      'image': imageUrl,
      'is_team_challenge': isTeamChallenge,
    };
  }

  ChallengeModel copyWith({
    List<String>? participants,
  }) {
    return ChallengeModel(
      id: id,
      title: title,
      description: description,
      goalType: goalType,
      goalValue: goalValue,
      rewardPoints: rewardPoints,
      startDate: startDate,
      endDate: endDate,
      participants: participants ?? this.participants,
      imageUrl: imageUrl ?? imageUrl,
      isTeamChallenge: isTeamChallenge,
    );
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  double get progressDays {
    final now = DateTime.now();
    if (!isActive) return 0.0;
    final total = endDate.difference(startDate).inSeconds;
    final elapsed = now.difference(startDate).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}
