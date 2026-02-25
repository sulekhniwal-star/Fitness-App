import 'package:hive/hive.dart';

part 'food_log_model.g.dart';

@HiveType(typeId: 1)
class FoodLogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String mealType; // breakfast, lunch, dinner, snack, chai

  @HiveField(4)
  final String foodItemId;

  @HiveField(5)
  final String foodName;

  @HiveField(6)
  final double quantityGrams;

  @HiveField(7)
  final double calories;

  @HiveField(8)
  final double proteinGrams;

  @HiveField(9)
  final double carbsGrams;

  @HiveField(10)
  final double fatGrams;

  @HiveField(11)
  final String loggedVia; // search, barcode, ocr, voice

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  final DateTime updatedAt;

  @HiveField(14)
  final bool isSynced;

  FoodLogModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.foodItemId,
    required this.foodName,
    required this.quantityGrams,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.loggedVia,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  factory FoodLogModel.fromJson(Map<String, dynamic> json) {
    return FoodLogModel(
      id: json['id'] as String,
      userId: json['user'] as String,
      date: DateTime.parse(json['date'] as String),
      mealType: json['meal_type'] as String,
      foodItemId: json['food_item'] as String,
      foodName: json['food_name'] as String,
      quantityGrams: (json['quantity_g'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      proteinGrams: (json['protein_g'] as num?)?.toDouble() ?? 0,
      carbsGrams: (json['carbs_g'] as num?)?.toDouble() ?? 0,
      fatGrams: (json['fat_g'] as num?)?.toDouble() ?? 0,
      loggedVia: json['logged_via'] as String? ?? 'search',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isSynced: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'date': date.toIso8601String(),
      'meal_type': mealType,
      'food_item': foodItemId,
      'food_name': foodName,
      'quantity_g': quantityGrams,
      'calories': calories,
      'protein_g': proteinGrams,
      'carbs_g': carbsGrams,
      'fat_g': fatGrams,
      'logged_via': loggedVia,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  FoodLogModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? mealType,
    String? foodItemId,
    String? foodName,
    double? quantityGrams,
    double? calories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    String? loggedVia,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return FoodLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      foodItemId: foodItemId ?? this.foodItemId,
      foodName: foodName ?? this.foodName,
      quantityGrams: quantityGrams ?? this.quantityGrams,
      calories: calories ?? this.calories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      loggedVia: loggedVia ?? this.loggedVia,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
