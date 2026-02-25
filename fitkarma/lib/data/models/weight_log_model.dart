import 'package:hive/hive.dart';

part 'weight_log_model.g.dart';

@HiveType(typeId: 4)
class WeightLogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final double weightKg;

  @HiveField(3)
  final double bmi;

  @HiveField(4)
  final DateTime date;

  WeightLogModel({
    required this.id,
    required this.userId,
    required this.weightKg,
    required this.bmi,
    required this.date,
  });

  factory WeightLogModel.fromJson(Map<String, dynamic> json) {
    return WeightLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      weightKg: (json['weight_kg'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'weight_kg': weightKg,
      'bmi': bmi,
      'date': date.toIso8601String(),
    };
  }
}
