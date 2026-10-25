import 'package:fitkarma/features/health_tracking/domain/models/health_types.dart';

/// Normalized numerical quantity primitive for health measurements.
class HealthQuantity {
  /// The numeric measurement magnitude.
  final double value;

  /// The unit of measurement.
  final HealthUnit unit;

  const HealthQuantity({
    required this.value,
    required this.unit,
  });

  /// Factory creating an integer-based quantity (e.g. steps, count).
  factory HealthQuantity.fromInt(int val, HealthUnit unit) {
    return HealthQuantity(value: val.toDouble(), unit: unit);
  }

  /// Converts this quantity to a [targetUnit] using deterministic conversion rules.
  HealthQuantity convertTo(HealthUnit targetUnit) {
    if (unit == targetUnit) return this;

    // Mass conversions
    if (_isMass(unit) && _isMass(targetUnit)) {
      final inKg = _toKilograms(value, unit);
      final converted = _fromKilograms(inKg, targetUnit);
      return HealthQuantity(value: converted, unit: targetUnit);
    }

    // Blood glucose conversions
    if (_isGlucose(unit) && _isGlucose(targetUnit)) {
      final inMgDl = _toMgPerDl(value, unit);
      final converted = _fromMgPerDl(inMgDl, targetUnit);
      return HealthQuantity(value: converted, unit: targetUnit);
    }

    // Time conversions
    if (_isTime(unit) && _isTime(targetUnit)) {
      final inSeconds = _toSeconds(value, unit);
      final converted = _fromSeconds(inSeconds, targetUnit);
      return HealthQuantity(value: converted, unit: targetUnit);
    }

    // Volume conversions
    if (_isVolume(unit) && _isVolume(targetUnit)) {
      final inMilliliters = _toMilliliters(value, unit);
      final converted = _fromMilliliters(inMilliliters, targetUnit);
      return HealthQuantity(value: converted, unit: targetUnit);
    }

    throw UnsupportedError('Cannot convert from $unit to $targetUnit');
  }

  /// Normalizes this quantity into its canonical FitKarma standard unit:
  /// - Mass -> kilograms
  /// - Glucose -> mg/dL
  /// - Time / Sleep -> minutes
  /// - Volume -> milliliters
  HealthQuantity toCanonical() {
    if (_isMass(unit)) return convertTo(HealthUnit.kilograms);
    if (_isGlucose(unit)) return convertTo(HealthUnit.mgPerDl);
    if (_isTime(unit) && unit != HealthUnit.milliseconds) {
      return convertTo(HealthUnit.minutes);
    }
    if (_isVolume(unit)) return convertTo(HealthUnit.milliliters);
    return this;
  }

  // --- Mass Conversion Math ---
  static bool _isMass(HealthUnit u) =>
      u == HealthUnit.kilograms || u == HealthUnit.grams || u == HealthUnit.pounds;

  static double _toKilograms(double val, HealthUnit u) {
    switch (u) {
      case HealthUnit.kilograms:
        return val;
      case HealthUnit.grams:
        return val / 1000.0;
      case HealthUnit.pounds:
        return val * 0.45359237;
      default:
        throw ArgumentError('Not a mass unit: $u');
    }
  }

  static double _fromKilograms(double kg, HealthUnit target) {
    switch (target) {
      case HealthUnit.kilograms:
        return kg;
      case HealthUnit.grams:
        return kg * 1000.0;
      case HealthUnit.pounds:
        return kg / 0.45359237;
      default:
        throw ArgumentError('Not a mass unit: $target');
    }
  }

  // --- Glucose Conversion Math ---
  static bool _isGlucose(HealthUnit u) =>
      u == HealthUnit.mgPerDl || u == HealthUnit.mmolPerL;

  static double _toMgPerDl(double val, HealthUnit u) {
    switch (u) {
      case HealthUnit.mgPerDl:
        return val;
      case HealthUnit.mmolPerL:
        return val * 18.0182;
      default:
        throw ArgumentError('Not a glucose unit: $u');
    }
  }

  static double _fromMgPerDl(double mgDl, HealthUnit target) {
    switch (target) {
      case HealthUnit.mgPerDl:
        return mgDl;
      case HealthUnit.mmolPerL:
        return mgDl / 18.0182;
      default:
        throw ArgumentError('Not a glucose unit: $target');
    }
  }

  // --- Time Conversion Math ---
  static bool _isTime(HealthUnit u) =>
      u == HealthUnit.milliseconds ||
      u == HealthUnit.seconds ||
      u == HealthUnit.minutes ||
      u == HealthUnit.hours;

  static double _toSeconds(double val, HealthUnit u) {
    switch (u) {
      case HealthUnit.milliseconds:
        return val / 1000.0;
      case HealthUnit.seconds:
        return val;
      case HealthUnit.minutes:
        return val * 60.0;
      case HealthUnit.hours:
        return val * 3600.0;
      default:
        throw ArgumentError('Not a time unit: $u');
    }
  }

  static double _fromSeconds(double s, HealthUnit target) {
    switch (target) {
      case HealthUnit.milliseconds:
        return s * 1000.0;
      case HealthUnit.seconds:
        return s;
      case HealthUnit.minutes:
        return s / 60.0;
      case HealthUnit.hours:
        return s / 3600.0;
      default:
        throw ArgumentError('Not a time unit: $target');
    }
  }

  // --- Volume Conversion Math ---
  static bool _isVolume(HealthUnit u) =>
      u == HealthUnit.milliliters || u == HealthUnit.liters;

  static double _toMilliliters(double val, HealthUnit u) {
    switch (u) {
      case HealthUnit.milliliters:
        return val;
      case HealthUnit.liters:
        return val * 1000.0;
      default:
        throw ArgumentError('Not a volume unit: $u');
    }
  }

  static double _fromMilliliters(double ml, HealthUnit target) {
    switch (target) {
      case HealthUnit.milliliters:
        return ml;
      case HealthUnit.liters:
        return ml / 1000.0;
      default:
        throw ArgumentError('Not a volume unit: $target');
    }
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'unit': unit.symbol,
      };

  factory HealthQuantity.fromJson(Map<String, dynamic> json) {
    return HealthQuantity(
      value: (json['value'] as num).toDouble(),
      unit: HealthUnit.fromString(json['unit'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthQuantity &&
        (other.value - value).abs() < 1e-6 &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(value.toStringAsFixed(4), unit);

  @override
  String toString() => '${value.toStringAsFixed(1)} ${unit.symbol}';
}

/// Compound quantity for Blood Pressure measurements (systolic & diastolic in mmHg).
class BloodPressureQuantity {
  final int systolic;
  final int diastolic;
  final HealthUnit unit;

  const BloodPressureQuantity({
    required this.systolic,
    required this.diastolic,
    this.unit = HealthUnit.mmHg,
  });

  Map<String, dynamic> toJson() => {
        'systolic': systolic,
        'diastolic': diastolic,
        'unit': unit.symbol,
      };

  factory BloodPressureQuantity.fromJson(Map<String, dynamic> json) {
    return BloodPressureQuantity(
      systolic: json['systolic'] as int,
      diastolic: json['diastolic'] as int,
      unit: HealthUnit.tryParse(json['unit'] as String?) ?? HealthUnit.mmHg,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BloodPressureQuantity &&
          other.systolic == systolic &&
          other.diastolic == diastolic &&
          other.unit == unit;

  @override
  int get hashCode => Object.hash(systolic, diastolic, unit);

  @override
  String toString() => '$systolic/$diastolic ${unit.symbol}';
}

/// Compound quantity for Sleep sessions with duration, quality score, and stage breakdowns.
class SleepQuantity {
  final int durationMinutes;
  final int? sleepScore;
  final int? deepMinutes;
  final int? remMinutes;
  final int? lightMinutes;
  final int? awakeMinutes;

  const SleepQuantity({
    required this.durationMinutes,
    this.sleepScore,
    this.deepMinutes,
    this.remMinutes,
    this.lightMinutes,
    this.awakeMinutes,
  });

  Map<String, dynamic> toJson() => {
        'duration_minutes': durationMinutes,
        if (sleepScore != null) 'sleep_score': sleepScore,
        if (deepMinutes != null) 'deep_minutes': deepMinutes,
        if (remMinutes != null) 'rem_minutes': remMinutes,
        if (lightMinutes != null) 'light_minutes': lightMinutes,
        if (awakeMinutes != null) 'awake_minutes': awakeMinutes,
      };

  factory SleepQuantity.fromJson(Map<String, dynamic> json) {
    return SleepQuantity(
      durationMinutes: json['duration_minutes'] as int,
      sleepScore: json['sleep_score'] as int?,
      deepMinutes: json['deep_minutes'] as int?,
      remMinutes: json['rem_minutes'] as int?,
      lightMinutes: json['light_minutes'] as int?,
      awakeMinutes: json['awake_minutes'] as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepQuantity &&
          other.durationMinutes == durationMinutes &&
          other.sleepScore == sleepScore &&
          other.deepMinutes == deepMinutes &&
          other.remMinutes == remMinutes &&
          other.lightMinutes == lightMinutes &&
          other.awakeMinutes == awakeMinutes;

  @override
  int get hashCode => Object.hash(
        durationMinutes,
        sleepScore,
        deepMinutes,
        remMinutes,
        lightMinutes,
        awakeMinutes,
      );

  @override
  String toString() => '${durationMinutes}min (Score: ${sleepScore ?? "--"})';
}

/// Compound quantity for Blood Glucose measurements with meal context.
class GlucoseQuantity {
  final double value;
  final HealthUnit unit;
  final MealContext mealContext;

  const GlucoseQuantity({
    required this.value,
    this.unit = HealthUnit.mgPerDl,
    this.mealContext = MealContext.random,
  });

  /// Normalizes to standard mg/dL.
  GlucoseQuantity toCanonical() {
    if (unit == HealthUnit.mgPerDl) return this;
    final converted = HealthQuantity(value: value, unit: unit)
        .convertTo(HealthUnit.mgPerDl);
    return GlucoseQuantity(
      value: converted.value,
      unit: HealthUnit.mgPerDl,
      mealContext: mealContext,
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'unit': unit.symbol,
        'meal_context': mealContext.value,
      };

  factory GlucoseQuantity.fromJson(Map<String, dynamic> json) {
    return GlucoseQuantity(
      value: (json['value'] as num).toDouble(),
      unit: HealthUnit.tryParse(json['unit'] as String?) ?? HealthUnit.mgPerDl,
      mealContext: MealContext.fromString(json['meal_context'] as String? ?? 'random'),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlucoseQuantity &&
          (other.value - value).abs() < 1e-4 &&
          other.unit == unit &&
          other.mealContext == mealContext;

  @override
  int get hashCode => Object.hash(value.toStringAsFixed(2), unit, mealContext);

  @override
  String toString() => '${value.toStringAsFixed(1)} ${unit.symbol} (${mealContext.value})';
}
