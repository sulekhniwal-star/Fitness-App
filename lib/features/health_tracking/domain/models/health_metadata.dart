import 'package:fitkarma/features/health_tracking/domain/models/health_types.dart';

/// Contextual metadata associated with a health observation.
class HealthMetadata {
  /// Hardware model or sensor version (e.g. "HEM-7600T", "Dexcom G7").
  final String? deviceModel;

  /// Sensor technology used (e.g. "photoplethysmography", "oscillometric", "enzymatic").
  final String? sensorType;

  /// Anatomical location where measurement was taken (e.g. "left_wrist", "left_upper_arm").
  final String? bodyLocation;

  /// Meal context if relevant (fasting, pre_meal, post_meal, bedtime).
  final MealContext? mealContext;

  /// Whether the user was in an active fasting state during observation.
  final bool? isFasting;

  /// Categorical tags (e.g. ["resting", "post_workout", "ayurveda_pitta"]).
  final List<String> tags;

  /// Arbitrary custom key-value pairs for future extension without schema breakage.
  final Map<String, dynamic> custom;

  const HealthMetadata({
    this.deviceModel,
    this.sensorType,
    this.bodyLocation,
    this.mealContext,
    this.isFasting,
    this.tags = const [],
    this.custom = const {},
  });

  Map<String, dynamic> toJson() => {
        if (deviceModel != null) 'device_model': deviceModel,
        if (sensorType != null) 'sensor_type': sensorType,
        if (bodyLocation != null) 'body_location': bodyLocation,
        if (mealContext != null) 'meal_context': mealContext!.value,
        if (isFasting != null) 'is_fasting': isFasting,
        if (tags.isNotEmpty) 'tags': tags,
        if (custom.isNotEmpty) 'custom': custom,
      };

  factory HealthMetadata.fromJson(Map<String, dynamic> json) {
    return HealthMetadata(
      deviceModel: json['device_model'] as String?,
      sensorType: json['sensor_type'] as String?,
      bodyLocation: json['body_location'] as String?,
      mealContext: json['meal_context'] != null
          ? MealContext.fromString(json['meal_context'] as String)
          : null,
      isFasting: json['is_fasting'] as bool?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      custom: (json['custom'] as Map<String, dynamic>?) ?? const {},
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthMetadata &&
          other.deviceModel == deviceModel &&
          other.sensorType == sensorType &&
          other.bodyLocation == bodyLocation &&
          other.mealContext == mealContext &&
          other.isFasting == isFasting;

  @override
  int get hashCode => Object.hash(
        deviceModel,
        sensorType,
        bodyLocation,
        mealContext,
        isFasting,
      );
}
