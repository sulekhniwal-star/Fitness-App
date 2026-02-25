import 'package:hive/hive.dart';

part 'medical_record_model.g.dart';

@HiveType(typeId: 3)
class MedicalRecordModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final String value;

  @HiveField(4)
  final String unit;

  @HiveField(5)
  final DateTime date;

  MedicalRecordModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.value,
    required this.unit,
    required this.date,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      value: json['value'] as String,
      unit: json['unit'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'value': value,
      'unit': unit,
      'date': date.toIso8601String(),
    };
  }
}
