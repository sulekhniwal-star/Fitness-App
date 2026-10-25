import 'package:fitkarma/features/health_tracking/domain/models/health_types.dart';

/// Provenance and attribution descriptor for a health observation.
class HealthDataSource {
  /// The underlying category or platform of the source.
  final HealthSourceOrigin origin;

  /// User-friendly label or brand name for display.
  final String name;

  /// Unique hardware or BLE peripheral identifier (if applicable).
  final String? deviceId;

  /// Hardware device model or firmware identifier.
  final String? deviceModel;

  /// Application package or bundle ID of the origin app.
  final String? appPackageName;

  /// Platform-specific source record identifier for deduplication (e.g. Health Connect record ID).
  final String? externalRecordId;

  /// Whether the data came through an OS-level aggregator platform (Health Connect / Apple Health).
  final bool isAggregator;

  const HealthDataSource({
    required this.origin,
    required this.name,
    this.deviceId,
    this.deviceModel,
    this.appPackageName,
    this.externalRecordId,
    this.isAggregator = false,
  });

  /// Factory creating attribution for manual in-app entry by the user.
  factory HealthDataSource.manual({String name = 'FitKarma Manual'}) {
    return HealthDataSource(
      origin: HealthSourceOrigin.manual,
      name: name,
    );
  }

  /// Factory creating attribution for Android Health Connect.
  factory HealthDataSource.healthConnect({
    String? deviceModel,
    String? externalRecordId,
    String? appPackageName,
  }) {
    return HealthDataSource(
      origin: HealthSourceOrigin.healthConnect,
      name: 'Health Connect',
      deviceModel: deviceModel,
      externalRecordId: externalRecordId,
      appPackageName: appPackageName ?? 'com.google.android.apps.healthdata',
      isAggregator: true,
    );
  }

  /// Factory creating attribution for iOS Apple Health / HealthKit.
  factory HealthDataSource.appleHealth({
    String? deviceModel,
    String? externalRecordId,
    String? appPackageName,
  }) {
    return HealthDataSource(
      origin: HealthSourceOrigin.appleHealth,
      name: 'Apple Health',
      deviceModel: deviceModel,
      externalRecordId: externalRecordId,
      appPackageName: appPackageName ?? 'com.apple.Health',
      isAggregator: true,
    );
  }

  /// Factory creating attribution for a Bluetooth Low Energy (BLE) peripheral (e.g. Omron BP, Accu-Chek).
  factory HealthDataSource.bleDevice({
    required String name,
    required String deviceId,
    String? deviceModel,
  }) {
    return HealthDataSource(
      origin: HealthSourceOrigin.bleDevice,
      name: name,
      deviceId: deviceId,
      deviceModel: deviceModel,
    );
  }

  /// Factory creating attribution for a smart wearable (e.g. Apple Watch, Galaxy Watch, Oura, Garmin).
  factory HealthDataSource.wearableDevice({
    required String name,
    String? deviceId,
    String? deviceModel,
    String? externalRecordId,
  }) {
    return HealthDataSource(
      origin: HealthSourceOrigin.wearableDevice,
      name: name,
      deviceId: deviceId,
      deviceModel: deviceModel,
      externalRecordId: externalRecordId,
    );
  }

  /// Factory creating attribution for a Continuous Glucose Monitor (CGM) sensor.
  factory HealthDataSource.cgm({
    required String name,
    String? deviceId,
    String? deviceModel,
    String? externalRecordId,
  }) {
    return HealthDataSource(
      origin: HealthSourceOrigin.cgmSensor,
      name: name,
      deviceId: deviceId,
      deviceModel: deviceModel,
      externalRecordId: externalRecordId,
    );
  }

  Map<String, dynamic> toJson() => {
        'origin': origin.value,
        'name': name,
        if (deviceId != null) 'device_id': deviceId,
        if (deviceModel != null) 'device_model': deviceModel,
        if (appPackageName != null) 'app_package_name': appPackageName,
        if (externalRecordId != null) 'external_record_id': externalRecordId,
        'is_aggregator': isAggregator,
      };

  factory HealthDataSource.fromJson(Map<String, dynamic> json) {
    return HealthDataSource(
      origin: HealthSourceOrigin.fromString(json['origin'] as String),
      name: json['name'] as String? ?? 'Unknown Source',
      deviceId: json['device_id'] as String?,
      deviceModel: json['device_model'] as String?,
      appPackageName: json['app_package_name'] as String?,
      externalRecordId: json['external_record_id'] as String?,
      isAggregator: json['is_aggregator'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthDataSource &&
          other.origin == origin &&
          other.name == name &&
          other.deviceId == deviceId &&
          other.deviceModel == deviceModel &&
          other.appPackageName == appPackageName &&
          other.externalRecordId == externalRecordId &&
          other.isAggregator == isAggregator;

  @override
  int get hashCode => Object.hash(
        origin,
        name,
        deviceId,
        deviceModel,
        appPackageName,
        externalRecordId,
        isAggregator,
      );

  @override
  String toString() => '$name (${origin.value})';
}
