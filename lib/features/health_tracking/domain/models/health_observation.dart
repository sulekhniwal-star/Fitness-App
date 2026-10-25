import 'package:fitkarma/core/sync/repository/sync_entity.dart';
import 'package:fitkarma/features/health_tracking/domain/models/health_confidence.dart';
import 'package:fitkarma/features/health_tracking/domain/models/health_metadata.dart';
import 'package:fitkarma/features/health_tracking/domain/models/health_quantity.dart';
import 'package:fitkarma/features/health_tracking/domain/models/health_source.dart';
import 'package:fitkarma/features/health_tracking/domain/models/health_timestamp.dart';
import 'package:fitkarma/features/health_tracking/domain/models/health_types.dart';

/// Normalized domain representation of a health observation in FitKarma.
///
/// Implements [SyncEntity] for seamless integration with Drift local encrypted
/// storage and Supabase remote synchronization.
class HealthObservation implements SyncEntity<String> {
  /// Unique identifier (UUID).
  final String id;

  /// Authenticated user identifier (UUID).
  final String userId;

  /// Classification type of health metric.
  final HealthMetricType metricType;

  /// Primary observation timestamp.
  final HealthTimestamp observedAt;

  /// Interval range for duration-based observations (sleep, workouts, step intervals).
  final HealthTimeRange? timeRange;

  /// Primary scalar quantity.
  final HealthQuantity quantity;

  /// Compound quantity for Blood Pressure (systolic/diastolic).
  final BloodPressureQuantity? bloodPressure;

  /// Compound quantity for Sleep sessions (stages and sleep score).
  final SleepQuantity? sleep;

  /// Compound quantity for Blood Glucose (meal timing context).
  final GlucoseQuantity? glucose;

  /// Provenance and attribution source.
  final HealthDataSource source;

  /// Measurement uncertainty and verification level.
  final HealthConfidence confidence;

  /// Sensor and environmental metadata.
  final HealthMetadata metadata;

  @override
  final bool isSynced;

  @override
  final DateTime? lastSyncedAt;

  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  const HealthObservation({
    required this.id,
    required this.userId,
    required this.metricType,
    required this.observedAt,
    this.timeRange,
    required this.quantity,
    this.bloodPressure,
    this.sleep,
    this.glucose,
    required this.source,
    required this.confidence,
    this.metadata = const HealthMetadata(),
    this.isSynced = false,
    this.lastSyncedAt,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
  });

  @override
  String get syncId => id;

  @override
  DateTime get syncUpdatedAt => updatedAt;

  @override
  int? get syncVersion => version;

  // ===========================================================================
  // Specialized Metric Factories
  // ===========================================================================

  /// Factory creating a normalized Steps observation.
  factory HealthObservation.steps({
    required String id,
    required String userId,
    required int steps,
    required DateTime observedAt,
    HealthTimeRange? timeRange,
    required HealthDataSource source,
    HealthConfidence? confidence,
    HealthMetadata? metadata,
    bool isSynced = false,
  }) {
    final now = DateTime.now();
    return HealthObservation(
      id: id,
      userId: userId,
      metricType: HealthMetricType.steps,
      observedAt: HealthTimestamp.fromDateTime(observedAt),
      timeRange: timeRange,
      quantity: HealthQuantity.fromInt(steps, HealthUnit.steps),
      source: source,
      confidence: confidence ?? HealthConfidence.high(),
      metadata: metadata ?? const HealthMetadata(),
      isSynced: isSynced,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Factory creating a normalized Heart Rate observation (bpm).
  factory HealthObservation.heartRate({
    required String id,
    required String userId,
    required double bpm,
    required DateTime observedAt,
    required HealthDataSource source,
    HealthConfidence? confidence,
    HealthMetadata? metadata,
    bool isSynced = false,
  }) {
    final now = DateTime.now();
    return HealthObservation(
      id: id,
      userId: userId,
      metricType: HealthMetricType.heartRate,
      observedAt: HealthTimestamp.fromDateTime(observedAt),
      quantity: HealthQuantity(value: bpm, unit: HealthUnit.bpm),
      source: source,
      confidence: confidence ?? HealthConfidence.high(),
      metadata: metadata ?? const HealthMetadata(),
      isSynced: isSynced,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Factory creating a normalized Heart Rate Variability (HRV) observation (rMSSD in ms).
  factory HealthObservation.hrv({
    required String id,
    required String userId,
    required double rmssdMs,
    required DateTime observedAt,
    required HealthDataSource source,
    HealthConfidence? confidence,
    HealthMetadata? metadata,
    bool isSynced = false,
  }) {
    final now = DateTime.now();
    return HealthObservation(
      id: id,
      userId: userId,
      metricType: HealthMetricType.hrv,
      observedAt: HealthTimestamp.fromDateTime(observedAt),
      quantity: HealthQuantity(value: rmssdMs, unit: HealthUnit.milliseconds),
      source: source,
      confidence: confidence ?? HealthConfidence.high(),
      metadata: metadata ?? const HealthMetadata(),
      isSynced: isSynced,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Factory creating a normalized Sleep session observation.
  factory HealthObservation.sleep({
    required String id,
    required String userId,
    required DateTime start,
    required DateTime end,
    int? sleepScore,
    int? deepMinutes,
    int? remMinutes,
    int? lightMinutes,
    int? awakeMinutes,
    required HealthDataSource source,
    HealthConfidence? confidence,
    HealthMetadata? metadata,
    bool isSynced = false,
  }) {
    final now = DateTime.now();
    final timeRange = HealthTimeRange(start: start, end: end);
    final sleepQuantity = SleepQuantity(
      durationMinutes: timeRange.durationMinutes,
      sleepScore: sleepScore,
      deepMinutes: deepMinutes,
      remMinutes: remMinutes,
      lightMinutes: lightMinutes,
      awakeMinutes: awakeMinutes,
    );

    return HealthObservation(
      id: id,
      userId: userId,
      metricType: HealthMetricType.sleep,
      observedAt: HealthTimestamp.fromDateTime(end),
      timeRange: timeRange,
      quantity: HealthQuantity(
        value: timeRange.durationMinutes.toDouble(),
        unit: HealthUnit.minutes,
      ),
      sleep: sleepQuantity,
      source: source,
      confidence: confidence ?? HealthConfidence.high(),
      metadata: metadata ?? const HealthMetadata(),
      isSynced: isSynced,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Factory creating a normalized Weight observation in kilograms (converts lbs if needed).
  factory HealthObservation.weight({
    required String id,
    required String userId,
    required double weight,
    HealthUnit unit = HealthUnit.kilograms,
    required DateTime observedAt,
    required HealthDataSource source,
    HealthConfidence? confidence,
    HealthMetadata? metadata,
    bool isSynced = false,
  }) {
    final now = DateTime.now();
    final rawQty = HealthQuantity(value: weight, unit: unit);
    final canonicalQty = rawQty.toCanonical();

    return HealthObservation(
      id: id,
      userId: userId,
      metricType: HealthMetricType.weight,
      observedAt: HealthTimestamp.fromDateTime(observedAt),
      quantity: canonicalQty,
      source: source,
      confidence: confidence ?? HealthConfidence.high(),
      metadata: metadata ?? const HealthMetadata(),
      isSynced: isSynced,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Factory creating a normalized Blood Pressure observation in mmHg.
  factory HealthObservation.bloodPressure({
    required String id,
    required String userId,
    required int systolic,
    required int diastolic,
    required DateTime observedAt,
    required HealthDataSource source,
    HealthConfidence? confidence,
    HealthMetadata? metadata,
    bool isSynced = false,
  }) {
    final now = DateTime.now();
    final bp = BloodPressureQuantity(
      systolic: systolic,
      diastolic: diastolic,
      unit: HealthUnit.mmHg,
    );

    return HealthObservation(
      id: id,
      userId: userId,
      metricType: HealthMetricType.bloodPressure,
      observedAt: HealthTimestamp.fromDateTime(observedAt),
      quantity: HealthQuantity(value: systolic.toDouble(), unit: HealthUnit.mmHg),
      bloodPressure: bp,
      source: source,
      confidence: confidence ?? HealthConfidence.high(),
      metadata: metadata ?? const HealthMetadata(),
      isSynced: isSynced,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Factory creating a normalized Blood Glucose observation in mg/dL (converts mmol/L if needed).
  factory HealthObservation.glucose({
    required String id,
    required String userId,
    required double value,
    HealthUnit unit = HealthUnit.mgPerDl,
    MealContext mealContext = MealContext.random,
    required DateTime observedAt,
    required HealthDataSource source,
    HealthConfidence? confidence,
    HealthMetadata? metadata,
    bool isSynced = false,
  }) {
    final now = DateTime.now();
    final glucoseQty = GlucoseQuantity(
      value: value,
      unit: unit,
      mealContext: mealContext,
    ).toCanonical();

    return HealthObservation(
      id: id,
      userId: userId,
      metricType: HealthMetricType.bloodGlucose,
      observedAt: HealthTimestamp.fromDateTime(observedAt),
      quantity: HealthQuantity(value: glucoseQty.value, unit: HealthUnit.mgPerDl),
      glucose: glucoseQty,
      source: source,
      confidence: confidence ?? HealthConfidence.high(),
      metadata: metadata ?? const HealthMetadata(mealContext: MealContext.random),
      isSynced: isSynced,
      createdAt: now,
      updatedAt: now,
    );
  }

  // ===========================================================================
  // Serialization & Sync Metadata
  // ===========================================================================

  @override
  Map<String, dynamic> toRemoteJson() => toJson();

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'metric_type': metricType.value,
        'observed_at': observedAt.toJson(),
        if (timeRange != null) 'time_range': timeRange!.toJson(),
        'quantity': quantity.toJson(),
        if (bloodPressure != null) 'blood_pressure': bloodPressure!.toJson(),
        if (sleep != null) 'sleep': sleep!.toJson(),
        if (glucose != null) 'glucose': glucose!.toJson(),
        'source': source.toJson(),
        'confidence': confidence.toJson(),
        'metadata': metadata.toJson(),
        'is_synced': isSynced,
        if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt!.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'version': version,
      };

  factory HealthObservation.fromJson(Map<String, dynamic> json) {
    return HealthObservation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      metricType: HealthMetricType.fromString(json['metric_type'] as String),
      observedAt: HealthTimestamp.fromJson(json['observed_at'] as Map<String, dynamic>),
      timeRange: json['time_range'] != null
          ? HealthTimeRange.fromJson(json['time_range'] as Map<String, dynamic>)
          : null,
      quantity: HealthQuantity.fromJson(json['quantity'] as Map<String, dynamic>),
      bloodPressure: json['blood_pressure'] != null
          ? BloodPressureQuantity.fromJson(json['blood_pressure'] as Map<String, dynamic>)
          : null,
      sleep: json['sleep'] != null
          ? SleepQuantity.fromJson(json['sleep'] as Map<String, dynamic>)
          : null,
      glucose: json['glucose'] != null
          ? GlucoseQuantity.fromJson(json['glucose'] as Map<String, dynamic>)
          : null,
      source: HealthDataSource.fromJson(json['source'] as Map<String, dynamic>),
      confidence: HealthConfidence.fromJson(json['confidence'] as Map<String, dynamic>),
      metadata: json['metadata'] != null
          ? HealthMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : const HealthMetadata(),
      isSynced: json['is_synced'] as bool? ?? false,
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      version: json['version'] as int? ?? 1,
    );
  }

  @override
  HealthObservation copyWithSyncMetadata({
    bool? isSynced,
    DateTime? lastSyncedAt,
    int? syncVersion,
    DateTime? syncUpdatedAt,
  }) {
    return HealthObservation(
      id: id,
      userId: userId,
      metricType: metricType,
      observedAt: observedAt,
      timeRange: timeRange,
      quantity: quantity,
      bloodPressure: bloodPressure,
      sleep: sleep,
      glucose: glucose,
      source: source,
      confidence: confidence,
      metadata: metadata,
      isSynced: isSynced ?? this.isSynced,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt,
      updatedAt: syncUpdatedAt ?? updatedAt,
      version: syncVersion ?? version,
    );
  }
}
