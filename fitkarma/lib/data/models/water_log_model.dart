import 'package:hive/hive.dart';

part 'water_log_model.g.dart';

@HiveType(typeId: 18)
class WaterLogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final int amountMl;

  @HiveField(4)
  final int? goalMl;

  @HiveField(5)
  final DateTime? time;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  WaterLogModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.amountMl,
    this.goalMl,
    this.time,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WaterLogModel.fromJson(Map<String, dynamic> json) {
    return WaterLogModel(
      id: json['id'] as String,
      userId: json['user'] is String ? json['user'] as String : '',
      date: DateTime.parse(json['date'] as String),
      amountMl: (json['amount_ml'] as num).toInt(),
      goalMl: json['goal_ml'] != null ? (json['goal_ml'] as num).toInt() : null,
      time: json['time'] != null ? DateTime.parse(json['time'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'date': date.toIso8601String().split('T')[0],
      'amount_ml': amountMl,
      'goal_ml': goalMl,
      'time': time?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WaterLogModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? amountMl,
    int? goalMl,
    DateTime? time,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WaterLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      amountMl: amountMl ?? this.amountMl,
      goalMl: goalMl ?? this.goalMl,
      time: time ?? this.time,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
