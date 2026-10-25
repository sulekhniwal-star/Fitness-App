import 'package:fitkarma/features/health_tracking/health_tracking_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HealthUnit & HealthQuantity Normalization Tests', () {
    test('converts mass units correctly (lbs -> kg, g -> kg, kg -> lbs)', () {
      // 150 pounds to kg: 150 * 0.45359237 = ~68.0388 kg
      final lbsQty = HealthQuantity(value: 150.0, unit: HealthUnit.pounds);
      final inKg = lbsQty.convertTo(HealthUnit.kilograms);
      expect(inKg.unit, equals(HealthUnit.kilograms));
      expect(inKg.value, closeTo(68.0388, 0.001));

      // 500 grams to kg
      final gramQty = HealthQuantity(value: 500.0, unit: HealthUnit.grams);
      expect(gramQty.convertTo(HealthUnit.kilograms).value, equals(0.5));

      // 70 kg to lbs: 70 / 0.45359237 = ~154.3235 lbs
      final kgQty = HealthQuantity(value: 70.0, unit: HealthUnit.kilograms);
      final inLbs = kgQty.convertTo(HealthUnit.pounds);
      expect(inLbs.unit, equals(HealthUnit.pounds));
      expect(inLbs.value, closeTo(154.3235, 0.001));

      // toCanonical() normalizes to kg
      expect(lbsQty.toCanonical().unit, equals(HealthUnit.kilograms));
    });

    test('converts glucose units correctly (mmol/L <-> mg/dL)', () {
      // 5.5 mmol/L to mg/dL: 5.5 * 18.0182 = ~99.10 mg/dL
      final mmolQty = HealthQuantity(value: 5.5, unit: HealthUnit.mmolPerL);
      final inMgDl = mmolQty.convertTo(HealthUnit.mgPerDl);
      expect(inMgDl.unit, equals(HealthUnit.mgPerDl));
      expect(inMgDl.value, closeTo(99.10, 0.05));

      // 100 mg/dL to mmol/L: 100 / 18.0182 = ~5.55 mmol/L
      final mgDlQty = HealthQuantity(value: 100.0, unit: HealthUnit.mgPerDl);
      final inMmol = mgDlQty.convertTo(HealthUnit.mmolPerL);
      expect(inMmol.unit, equals(HealthUnit.mmolPerL));
      expect(inMmol.value, closeTo(5.55, 0.05));

      // toCanonical() normalizes to mg/dL
      expect(mmolQty.toCanonical().unit, equals(HealthUnit.mgPerDl));
    });

    test('converts time duration units correctly (ms, s, min, h)', () {
      final secQty = HealthQuantity(value: 120.0, unit: HealthUnit.seconds);
      expect(secQty.convertTo(HealthUnit.minutes).value, equals(2.0));

      final hourQty = HealthQuantity(value: 1.5, unit: HealthUnit.hours);
      expect(hourQty.convertTo(HealthUnit.minutes).value, equals(90.0));

      final msQty = HealthQuantity(value: 45000.0, unit: HealthUnit.milliseconds);
      expect(msQty.convertTo(HealthUnit.seconds).value, equals(45.0));

      // toCanonical() normalizes to minutes
      expect(secQty.toCanonical().unit, equals(HealthUnit.minutes));
    });

    test('converts volume units correctly (ml <-> L)', () {
      final mlQty = HealthQuantity(value: 250.0, unit: HealthUnit.milliliters);
      expect(mlQty.convertTo(HealthUnit.liters).value, equals(0.25));

      final lQty = HealthQuantity(value: 1.5, unit: HealthUnit.liters);
      expect(lQty.convertTo(HealthUnit.milliliters).value, equals(1500.0));

      // toCanonical() normalizes to ml
      expect(lQty.toCanonical().unit, equals(HealthUnit.milliliters));
    });

    test('throws UnsupportedError when attempting invalid unit cross-conversions', () {
      final weight = HealthQuantity(value: 70.0, unit: HealthUnit.kilograms);
      expect(() => weight.convertTo(HealthUnit.bpm), throwsUnsupportedError);
      expect(() => weight.convertTo(HealthUnit.minutes), throwsUnsupportedError);
    });

    test('HealthUnit.fromString parses symbols, names, and aliases cleanly', () {
      expect(HealthUnit.fromString('bpm'), equals(HealthUnit.bpm));
      expect(HealthUnit.fromString('beats_per_minute'), equals(HealthUnit.bpm));
      expect(HealthUnit.fromString('kg'), equals(HealthUnit.kilograms));
      expect(HealthUnit.fromString('lbs'), equals(HealthUnit.pounds));
      expect(HealthUnit.fromString('mg/dl'), equals(HealthUnit.mgPerDl));
      expect(HealthUnit.fromString('mmol/L'), equals(HealthUnit.mmolPerL));
      expect(HealthUnit.fromString('mmHg'), equals(HealthUnit.mmHg));
      expect(HealthUnit.fromString('steps'), equals(HealthUnit.steps));
    });

    test('round-trips HealthQuantity JSON serialization', () {
      final qty = HealthQuantity(value: 72.5, unit: HealthUnit.kilograms);
      final json = qty.toJson();
      final parsed = HealthQuantity.fromJson(json);
      expect(parsed, equals(qty));
    });
  });

  group('Compound Quantities Tests', () {
    test('BloodPressureQuantity serializes and formats correctly', () {
      const bp = BloodPressureQuantity(systolic: 120, diastolic: 80);
      expect(bp.toString(), equals('120/80 mmHg'));

      final json = bp.toJson();
      final parsed = BloodPressureQuantity.fromJson(json);
      expect(parsed, equals(bp));
    });

    test('SleepQuantity serializes and preserves stage breakdowns', () {
      const sleep = SleepQuantity(
        durationMinutes: 465,
        sleepScore: 88,
        deepMinutes: 95,
        remMinutes: 110,
        lightMinutes: 220,
        awakeMinutes: 40,
      );

      final json = sleep.toJson();
      final parsed = SleepQuantity.fromJson(json);
      expect(parsed, equals(sleep));
      expect(parsed.durationMinutes, equals(465));
      expect(parsed.sleepScore, equals(88));
      expect(parsed.deepMinutes, equals(95));
    });

    test('GlucoseQuantity serializes, converts canonical, and tracks meal context', () {
      const glucoseMmol = GlucoseQuantity(
        value: 5.6,
        unit: HealthUnit.mmolPerL,
        mealContext: MealContext.fasting,
      );

      final canonical = glucoseMmol.toCanonical();
      expect(canonical.unit, equals(HealthUnit.mgPerDl));
      expect(canonical.value, closeTo(100.9, 0.1));
      expect(canonical.mealContext, equals(MealContext.fasting));

      final json = canonical.toJson();
      final parsed = GlucoseQuantity.fromJson(json);
      expect(parsed, equals(canonical));
    });
  });

  group('HealthTimestamp & HealthTimeRange Tests', () {
    test('HealthTimestamp preserves DateTime and timezone offset minutes', () {
      final now = DateTime.parse('2026-10-25T08:30:00+05:30');
      final ts = HealthTimestamp(
        dateTime: now,
        timeZoneOffset: const Duration(hours: 5, minutes: 30),
      );

      final json = ts.toJson();
      expect(json['timezone_offset_minutes'], equals(330));

      final parsed = HealthTimestamp.fromJson(json);
      expect(parsed, equals(ts));
    });

    test('HealthTimeRange computes duration, contains moment, and validates boundaries', () {
      final start = DateTime.parse('2026-10-25T22:00:00Z');
      final end = DateTime.parse('2026-10-26T06:30:00Z');
      final range = HealthTimeRange(start: start, end: end);

      expect(range.durationMinutes, equals(510));
      expect(range.contains(DateTime.parse('2026-10-26T02:00:00Z')), isTrue);
      expect(range.contains(DateTime.parse('2026-10-26T07:00:00Z')), isFalse);

      final json = range.toJson();
      final parsed = HealthTimeRange.fromJson(json);
      expect(parsed, equals(range));

      // Boundary check: end before start throws ArgumentError
      expect(
        () => HealthTimeRange(start: end, end: start),
        throwsArgumentError,
      );
    });
  });

  group('HealthDataSource Attribution Tests', () {
    test('serializes and preserves manual, healthConnect, appleHealth, and BLE origins', () {
      final manualSource = HealthDataSource.manual();
      expect(manualSource.origin, equals(HealthSourceOrigin.manual));
      expect(HealthDataSource.fromJson(manualSource.toJson()), equals(manualSource));

      final hcSource = HealthDataSource.healthConnect(
        deviceModel: 'Pixel Watch 3',
        externalRecordId: 'hc_rec_9988',
      );
      expect(hcSource.isAggregator, isTrue);
      expect(hcSource.externalRecordId, equals('hc_rec_9988'));
      expect(HealthDataSource.fromJson(hcSource.toJson()), equals(hcSource));

      final ahSource = HealthDataSource.appleHealth(
        deviceModel: 'Apple Watch Ultra',
        externalRecordId: 'ah_rec_1122',
      );
      expect(ahSource.isAggregator, isTrue);
      expect(HealthDataSource.fromJson(ahSource.toJson()), equals(ahSource));

      final bleSource = HealthDataSource.bleDevice(
        name: 'Omron HEM-7600T',
        deviceId: 'BLE:00:1A:7D:DA:71:13',
        deviceModel: 'Evolv',
      );
      expect(bleSource.origin, equals(HealthSourceOrigin.bleDevice));
      expect(HealthDataSource.fromJson(bleSource.toJson()), equals(bleSource));

      final cgmSource = HealthDataSource.cgm(
        name: 'Dexcom G7',
        deviceId: 'CGM-SN-49821',
      );
      expect(cgmSource.origin, equals(HealthSourceOrigin.cgmSensor));
      expect(HealthDataSource.fromJson(cgmSource.toJson()), equals(cgmSource));
    });
  });

  group('HealthConfidence & HealthMetadata Tests', () {
    test('HealthConfidence calculates levels from scores and handles user verification', () {
      expect(HealthConfidenceLevel.fromScore(0.98), equals(HealthConfidenceLevel.verified));
      expect(HealthConfidenceLevel.fromScore(0.85), equals(HealthConfidenceLevel.high));
      expect(HealthConfidenceLevel.fromScore(0.70), equals(HealthConfidenceLevel.medium));
      expect(HealthConfidenceLevel.fromScore(0.45), equals(HealthConfidenceLevel.low));
      expect(HealthConfidenceLevel.fromScore(0.20), equals(HealthConfidenceLevel.unvalidated));

      final initial = HealthConfidence.medium(notes: 'Optical sensor motion noise');
      expect(initial.isUserVerified, isFalse);

      final verified = initial.markUserVerified(verificationNotes: 'Confirmed by user with cuff');
      expect(verified.isUserVerified, isTrue);
      expect(verified.score, equals(1.0));
      expect(verified.level, equals(HealthConfidenceLevel.verified));

      final json = verified.toJson();
      final parsed = HealthConfidence.fromJson(json);
      expect(parsed, equals(verified));
    });

    test('HealthMetadata serializes context, sensor type, and tags', () {
      const meta = HealthMetadata(
        deviceModel: 'Omron Evolv',
        sensorType: 'oscillometric',
        bodyLocation: 'left_upper_arm',
        mealContext: MealContext.fasting,
        isFasting: true,
        tags: ['resting', 'morning_vitals'],
        custom: {'battery_level': 85},
      );

      final json = meta.toJson();
      final parsed = HealthMetadata.fromJson(json);
      expect(parsed, equals(meta));
      expect(parsed.custom['battery_level'], equals(85));
    });
  });

  group('HealthObservation Full Round-Trip Serialization for All 7 Core Metrics', () {
    final testTime = DateTime.parse('2026-10-25T07:15:00Z');
    const testUserId = 'usr_test_7788';

    test('1. Steps observation round-trips correctly', () {
      final stepsObs = HealthObservation.steps(
        id: 'obs_steps_01',
        userId: testUserId,
        steps: 8450,
        observedAt: testTime,
        timeRange: HealthTimeRange(
          start: testTime.subtract(const Duration(hours: 12)),
          end: testTime,
        ),
        source: HealthDataSource.healthConnect(),
      );

      expect(stepsObs.metricType, equals(HealthMetricType.steps));
      expect(stepsObs.quantity.value, equals(8450.0));
      expect(stepsObs.quantity.unit, equals(HealthUnit.steps));

      final json = stepsObs.toJson();
      final roundTrip = HealthObservation.fromJson(json);

      expect(roundTrip.id, equals(stepsObs.id));
      expect(roundTrip.userId, equals(stepsObs.userId));
      expect(roundTrip.metricType, equals(HealthMetricType.steps));
      expect(roundTrip.quantity, equals(stepsObs.quantity));
      expect(roundTrip.timeRange, equals(stepsObs.timeRange));
      expect(roundTrip.source, equals(stepsObs.source));
    });

    test('2. Heart Rate observation round-trips correctly', () {
      final hrObs = HealthObservation.heartRate(
        id: 'obs_hr_01',
        userId: testUserId,
        bpm: 68.0,
        observedAt: testTime,
        source: HealthDataSource.appleHealth(),
        metadata: const HealthMetadata(tags: ['resting_heart_rate']),
      );

      expect(hrObs.metricType, equals(HealthMetricType.heartRate));
      expect(hrObs.quantity.unit, equals(HealthUnit.bpm));

      final json = hrObs.toJson();
      final roundTrip = HealthObservation.fromJson(json);

      expect(roundTrip.id, equals(hrObs.id));
      expect(roundTrip.quantity.value, equals(68.0));
      expect(roundTrip.quantity.unit, equals(HealthUnit.bpm));
      expect(roundTrip.source.origin, equals(HealthSourceOrigin.appleHealth));
    });

    test('3. HRV observation round-trips correctly', () {
      final hrvObs = HealthObservation.hrv(
        id: 'obs_hrv_01',
        userId: testUserId,
        rmssdMs: 46.5,
        observedAt: testTime,
        source: HealthDataSource.wearableDevice(name: 'Oura Ring Gen 3'),
      );

      expect(hrvObs.metricType, equals(HealthMetricType.hrv));
      expect(hrvObs.quantity.unit, equals(HealthUnit.milliseconds));

      final json = hrvObs.toJson();
      final roundTrip = HealthObservation.fromJson(json);

      expect(roundTrip.id, equals(hrvObs.id));
      expect(roundTrip.quantity.value, equals(46.5));
      expect(roundTrip.quantity.unit, equals(HealthUnit.milliseconds));
    });

    test('4. Sleep observation round-trips correctly with compound quantity', () {
      final sleepStart = DateTime.parse('2026-10-24T22:30:00Z');
      final sleepEnd = DateTime.parse('2026-10-25T06:30:00Z');

      final sleepObs = HealthObservation.sleep(
        id: 'obs_sleep_01',
        userId: testUserId,
        start: sleepStart,
        end: sleepEnd,
        sleepScore: 84,
        deepMinutes: 90,
        remMinutes: 105,
        lightMinutes: 245,
        awakeMinutes: 40,
        source: HealthDataSource.healthConnect(),
      );

      expect(sleepObs.metricType, equals(HealthMetricType.sleep));
      expect(sleepObs.sleep, isNotNull);
      expect(sleepObs.sleep!.durationMinutes, equals(480));
      expect(sleepObs.sleep!.sleepScore, equals(84));

      final json = sleepObs.toJson();
      final roundTrip = HealthObservation.fromJson(json);

      expect(roundTrip.id, equals(sleepObs.id));
      expect(roundTrip.sleep, equals(sleepObs.sleep));
      expect(roundTrip.timeRange!.durationMinutes, equals(480));
    });

    test('5. Weight observation normalizes pounds to kg and round-trips correctly', () {
      // Input in pounds: 154.3235 lbs -> normalizes to 70.0 kg
      final weightObs = HealthObservation.weight(
        id: 'obs_wt_01',
        userId: testUserId,
        weight: 154.32358,
        unit: HealthUnit.pounds,
        observedAt: testTime,
        source: HealthDataSource.manual(),
      );

      expect(weightObs.metricType, equals(HealthMetricType.weight));
      expect(weightObs.quantity.unit, equals(HealthUnit.kilograms));
      expect(weightObs.quantity.value, closeTo(70.0, 0.01));

      final json = weightObs.toJson();
      final roundTrip = HealthObservation.fromJson(json);

      expect(roundTrip.id, equals(weightObs.id));
      expect(roundTrip.quantity.value, closeTo(70.0, 0.01));
      expect(roundTrip.quantity.unit, equals(HealthUnit.kilograms));
    });

    test('6. Blood Pressure observation round-trips correctly with compound quantity', () {
      final bpObs = HealthObservation.bloodPressure(
        id: 'obs_bp_01',
        userId: testUserId,
        systolic: 118,
        diastolic: 76,
        observedAt: testTime,
        source: HealthDataSource.bleDevice(
          name: 'Omron Evolv',
          deviceId: 'BLE:00:1A:7D:DA:71:13',
        ),
      );

      expect(bpObs.metricType, equals(HealthMetricType.bloodPressure));
      expect(bpObs.bloodPressure, isNotNull);
      expect(bpObs.bloodPressure!.systolic, equals(118));
      expect(bpObs.bloodPressure!.diastolic, equals(76));

      final json = bpObs.toJson();
      final roundTrip = HealthObservation.fromJson(json);

      expect(roundTrip.id, equals(bpObs.id));
      expect(roundTrip.bloodPressure, equals(bpObs.bloodPressure));
      expect(roundTrip.source.origin, equals(HealthSourceOrigin.bleDevice));
    });

    test('7. Blood Glucose observation normalizes mmol/L to mg/dL and round-trips correctly', () {
      // Input in mmol/L: 5.55 mmol/L -> normalizes to ~100.0 mg/dL
      final glucoseObs = HealthObservation.glucose(
        id: 'obs_cgm_01',
        userId: testUserId,
        value: 5.55,
        unit: HealthUnit.mmolPerL,
        mealContext: MealContext.fasting,
        observedAt: testTime,
        source: HealthDataSource.cgm(name: 'Freestyle Libre 3'),
      );

      expect(glucoseObs.metricType, equals(HealthMetricType.bloodGlucose));
      expect(glucoseObs.glucose, isNotNull);
      expect(glucoseObs.glucose!.unit, equals(HealthUnit.mgPerDl));
      expect(glucoseObs.glucose!.value, closeTo(100.0, 0.1));
      expect(glucoseObs.glucose!.mealContext, equals(MealContext.fasting));

      final json = glucoseObs.toJson();
      final roundTrip = HealthObservation.fromJson(json);

      expect(roundTrip.id, equals(glucoseObs.id));
      expect(roundTrip.glucose, equals(glucoseObs.glucose));
      expect(roundTrip.source.origin, equals(HealthSourceOrigin.cgmSensor));
    });

    test('SyncEntity metadata and copyWithSyncMetadata behave correctly', () {
      final obs = HealthObservation.heartRate(
        id: 'obs_sync_01',
        userId: testUserId,
        bpm: 72.0,
        observedAt: testTime,
        source: HealthDataSource.manual(),
      );

      expect(obs.syncId, equals('obs_sync_01'));
      expect(obs.isSynced, isFalse);
      expect(obs.syncVersion, equals(1));

      final syncTime = DateTime.parse('2026-10-25T10:00:00Z');
      final updated = obs.copyWithSyncMetadata(
        isSynced: true,
        lastSyncedAt: syncTime,
        syncVersion: 2,
      );

      expect(updated.isSynced, isTrue);
      expect(updated.lastSyncedAt, equals(syncTime));
      expect(updated.syncVersion, equals(2));
      expect(updated.quantity.value, equals(72.0));
    });
  });
}
