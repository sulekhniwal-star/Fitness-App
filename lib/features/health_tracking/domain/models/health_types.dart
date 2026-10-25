/// Supported health observation metric types in FitKarma.
enum HealthMetricType {
  /// Cumulative or interval step count.
  steps('steps'),

  /// Heart rate in beats per minute (bpm).
  heartRate('heart_rate'),

  /// Heart rate variability (HRV), typically rMSSD in milliseconds.
  hrv('hrv'),

  /// Sleep sessions including duration, efficiency score, and stages.
  sleep('sleep'),

  /// Body weight in kilograms or pounds.
  weight('weight'),

  /// Blood pressure (systolic and diastolic) in mmHg.
  bloodPressure('blood_pressure'),

  /// Blood glucose (point-in-time or continuous CGM) in mg/dL or mmol/L.
  bloodGlucose('blood_glucose'),

  /// Active or workout minutes.
  activeMinutes('active_minutes'),

  /// Water hydration intake in milliliters.
  water('water'),

  /// Blood oxygen saturation (SpO2) percentage.
  oxygenSaturation('oxygen_saturation'),

  /// Resting respiratory rate in breaths per minute.
  respiratoryRate('respiratory_rate'),

  /// Body temperature in Celsius or Fahrenheit.
  bodyTemperature('body_temperature');

  final String value;
  const HealthMetricType(this.value);

  static HealthMetricType fromString(String raw) {
    return HealthMetricType.values.firstWhere(
      (e) => e.value.toLowerCase() == raw.toLowerCase() || e.name.toLowerCase() == raw.toLowerCase(),
      orElse: () => throw ArgumentError('Unsupported HealthMetricType: $raw'),
    );
  }

  static HealthMetricType? tryParse(String? raw) {
    if (raw == null) return null;
    try {
      return fromString(raw);
    } catch (_) {
      return null;
    }
  }
}

/// Standard measurement units with deterministic unit conversions.
enum HealthUnit {
  // Count
  count('count'),
  steps('steps'),

  // Frequency
  bpm('bpm'),

  // Time / Duration
  milliseconds('ms'),
  seconds('s'),
  minutes('min'),
  hours('h'),

  // Mass
  kilograms('kg'),
  grams('g'),
  pounds('lbs'),

  // Pressure
  mmHg('mmHg'),

  // Concentration
  mgPerDl('mg/dL'),
  mmolPerL('mmol/L'),

  // Ratio / Scale
  percentage('%'),
  score('score'),

  // Volume
  milliliters('ml'),
  liters('L'),

  // Energy
  kcal('kcal');

  final String symbol;
  const HealthUnit(this.symbol);

  static HealthUnit fromString(String raw) {
    final normalized = raw.trim().toLowerCase();
    for (final unit in HealthUnit.values) {
      if (unit.name.toLowerCase() == normalized || unit.symbol.toLowerCase() == normalized) {
        return unit;
      }
    }
    // Handle standard aliases
    switch (normalized) {
      case 'step':
        return HealthUnit.steps;
      case 'beat_per_minute':
      case 'beats/minute':
      case 'beats_per_minute':
        return HealthUnit.bpm;
      case 'millisecond':
        return HealthUnit.milliseconds;
      case 'second':
      case 'sec':
        return HealthUnit.seconds;
      case 'minute':
      case 'm':
        return HealthUnit.minutes;
      case 'hour':
      case 'hr':
        return HealthUnit.hours;
      case 'kg':
      case 'kilo':
        return HealthUnit.kilograms;
      case 'gram':
      case 'gm':
        return HealthUnit.grams;
      case 'lb':
      case 'pound':
        return HealthUnit.pounds;
      case 'mm_hg':
      case 'mmhg':
        return HealthUnit.mmHg;
      case 'mg/dl':
      case 'mgdl':
        return HealthUnit.mgPerDl;
      case 'mmol/l':
      case 'mmoll':
        return HealthUnit.mmolPerL;
      case 'percent':
        return HealthUnit.percentage;
      default:
        throw ArgumentError('Unsupported HealthUnit: $raw');
    }
  }

  static HealthUnit? tryParse(String? raw) {
    if (raw == null) return null;
    try {
      return fromString(raw);
    } catch (_) {
      return null;
    }
  }
}

/// Provider-neutral origins for health observation provenance.
enum HealthSourceOrigin {
  /// Manually logged by the user in FitKarma UI.
  manual('manual'),

  /// Android Health Connect aggregator platform.
  healthConnect('health_connect'),

  /// iOS Apple Health / HealthKit aggregator platform.
  appleHealth('apple_health'),

  /// Bluetooth Low Energy (BLE) peripheral (e.g. Omron BP cuff, Accu-Chek).
  bleDevice('ble_device'),

  /// Smart wearable hardware (Fitbit, Garmin, Apple Watch, Galaxy Watch).
  wearableDevice('wearable_device'),

  /// Continuous Glucose Monitor (CGM) sensor (Freestyle Libre, Dexcom).
  cgmSensor('cgm_sensor'),

  /// Third-party integrated app.
  thirdPartyApp('third_party_app'),

  /// Inferred or calculated by FitKarma engine (e.g. estimated TDEE).
  inferred('inferred');

  final String value;
  const HealthSourceOrigin(this.value);

  static HealthSourceOrigin fromString(String raw) {
    return HealthSourceOrigin.values.firstWhere(
      (e) => e.value.toLowerCase() == raw.toLowerCase() || e.name.toLowerCase() == raw.toLowerCase(),
      orElse: () => HealthSourceOrigin.thirdPartyApp,
    );
  }
}

/// Qualitative confidence level for health observations.
enum HealthConfidenceLevel {
  /// Verified directly by an FDA/CDSCO cleared medical device or clinical measurement.
  verified(1.0),

  /// High accuracy from a reputable consumer wearable sensor or calibrated meter.
  high(0.9),

  /// Moderate accuracy, consumer estimation, or optical sensor with possible motion artifacts.
  medium(0.7),

  /// Approximate, user estimate, or uncalibrated reading.
  low(0.5),

  /// Unvalidated estimate or inferred prediction.
  unvalidated(0.3);

  final double defaultScore;
  const HealthConfidenceLevel(this.defaultScore);

  static HealthConfidenceLevel fromScore(double score) {
    if (score >= 0.95) return HealthConfidenceLevel.verified;
    if (score >= 0.8) return HealthConfidenceLevel.high;
    if (score >= 0.6) return HealthConfidenceLevel.medium;
    if (score >= 0.4) return HealthConfidenceLevel.low;
    return HealthConfidenceLevel.unvalidated;
  }
}

/// Meal and fasting timing context (especially critical for blood glucose and India-first fasting/vrat).
enum MealContext {
  /// Fasting state (minimum 8 hours of fasting or religious fasting/vrat).
  fasting('fasting'),

  /// Immediately before a meal.
  preMeal('pre_meal'),

  /// 1-2 hours after a meal (postprandial).
  postMeal('post_meal'),

  /// Before going to bed.
  bedtime('bedtime'),

  /// Random or unassociated with a specific meal.
  random('random');

  final String value;
  const MealContext(this.value);

  static MealContext fromString(String raw) {
    return MealContext.values.firstWhere(
      (e) => e.value.toLowerCase() == raw.toLowerCase() || e.name.toLowerCase() == raw.toLowerCase(),
      orElse: () => MealContext.random,
    );
  }
}

/// Sleep stage classification.
enum SleepStage {
  awake('awake'),
  light('light'),
  deep('deep'),
  rem('rem'),
  outOfBed('out_of_bed');

  final String value;
  const SleepStage(this.value);

  static SleepStage fromString(String raw) {
    return SleepStage.values.firstWhere(
      (e) => e.value.toLowerCase() == raw.toLowerCase() || e.name.toLowerCase() == raw.toLowerCase(),
      orElse: () => SleepStage.light,
    );
  }
}
