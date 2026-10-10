// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalProfilesTable extends LocalProfiles
    with TableInfo<$LocalProfilesTable, LocalProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _biologicalSexMeta = const VerificationMeta(
    'biologicalSex',
  );
  @override
  late final GeneratedColumn<String> biologicalSex = GeneratedColumn<String>(
    'biological_sex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalsJsonMeta = const VerificationMeta(
    'goalsJson',
  );
  @override
  late final GeneratedColumn<String> goalsJson = GeneratedColumn<String>(
    'goals_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _activityLevelMeta = const VerificationMeta(
    'activityLevel',
  );
  @override
  late final GeneratedColumn<String> activityLevel = GeneratedColumn<String>(
    'activity_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dietaryIdentityMeta = const VerificationMeta(
    'dietaryIdentity',
  );
  @override
  late final GeneratedColumn<String> dietaryIdentity = GeneratedColumn<String>(
    'dietary_identity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mealFrequencyMeta = const VerificationMeta(
    'mealFrequency',
  );
  @override
  late final GeneratedColumn<int> mealFrequency = GeneratedColumn<int>(
    'meal_frequency',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fastingProtocolMeta = const VerificationMeta(
    'fastingProtocol',
  );
  @override
  late final GeneratedColumn<String> fastingProtocol = GeneratedColumn<String>(
    'fasting_protocol',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allergiesJsonMeta = const VerificationMeta(
    'allergiesJson',
  );
  @override
  late final GeneratedColumn<String> allergiesJson = GeneratedColumn<String>(
    'allergies_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _targetCaloriesMeta = const VerificationMeta(
    'targetCalories',
  );
  @override
  late final GeneratedColumn<int> targetCalories = GeneratedColumn<int>(
    'target_calories',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _isConsentGivenMeta = const VerificationMeta(
    'isConsentGiven',
  );
  @override
  late final GeneratedColumn<bool> isConsentGiven = GeneratedColumn<bool>(
    'is_consent_given',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_consent_given" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    displayName,
    age,
    biologicalSex,
    heightCm,
    weightKg,
    goalsJson,
    activityLevel,
    dietaryIdentity,
    mealFrequency,
    fastingProtocol,
    allergiesJson,
    targetCalories,
    locale,
    isConsentGiven,
    metadataJson,
    createdAt,
    updatedAt,
    isSynced,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    }
    if (data.containsKey('biological_sex')) {
      context.handle(
        _biologicalSexMeta,
        biologicalSex.isAcceptableOrUnknown(
          data['biological_sex']!,
          _biologicalSexMeta,
        ),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('goals_json')) {
      context.handle(
        _goalsJsonMeta,
        goalsJson.isAcceptableOrUnknown(data['goals_json']!, _goalsJsonMeta),
      );
    }
    if (data.containsKey('activity_level')) {
      context.handle(
        _activityLevelMeta,
        activityLevel.isAcceptableOrUnknown(
          data['activity_level']!,
          _activityLevelMeta,
        ),
      );
    }
    if (data.containsKey('dietary_identity')) {
      context.handle(
        _dietaryIdentityMeta,
        dietaryIdentity.isAcceptableOrUnknown(
          data['dietary_identity']!,
          _dietaryIdentityMeta,
        ),
      );
    }
    if (data.containsKey('meal_frequency')) {
      context.handle(
        _mealFrequencyMeta,
        mealFrequency.isAcceptableOrUnknown(
          data['meal_frequency']!,
          _mealFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('fasting_protocol')) {
      context.handle(
        _fastingProtocolMeta,
        fastingProtocol.isAcceptableOrUnknown(
          data['fasting_protocol']!,
          _fastingProtocolMeta,
        ),
      );
    }
    if (data.containsKey('allergies_json')) {
      context.handle(
        _allergiesJsonMeta,
        allergiesJson.isAcceptableOrUnknown(
          data['allergies_json']!,
          _allergiesJsonMeta,
        ),
      );
    }
    if (data.containsKey('target_calories')) {
      context.handle(
        _targetCaloriesMeta,
        targetCalories.isAcceptableOrUnknown(
          data['target_calories']!,
          _targetCaloriesMeta,
        ),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('is_consent_given')) {
      context.handle(
        _isConsentGivenMeta,
        isConsentGiven.isAcceptableOrUnknown(
          data['is_consent_given']!,
          _isConsentGivenMeta,
        ),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      ),
      biologicalSex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}biological_sex'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      goalsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goals_json'],
      )!,
      activityLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_level'],
      ),
      dietaryIdentity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dietary_identity'],
      ),
      mealFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meal_frequency'],
      ),
      fastingProtocol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fasting_protocol'],
      ),
      allergiesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allergies_json'],
      )!,
      targetCalories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_calories'],
      ),
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      isConsentGiven: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_consent_given'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $LocalProfilesTable createAlias(String alias) {
    return $LocalProfilesTable(attachedDatabase, alias);
  }
}

class LocalProfile extends DataClass implements Insertable<LocalProfile> {
  final String id;
  final String userId;
  final String displayName;
  final int? age;
  final String? biologicalSex;
  final double? heightCm;
  final double? weightKg;
  final String goalsJson;
  final String? activityLevel;
  final String? dietaryIdentity;
  final int? mealFrequency;
  final String? fastingProtocol;
  final String allergiesJson;
  final int? targetCalories;
  final String locale;
  final bool isConsentGiven;
  final String? metadataJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final DateTime? lastSyncedAt;
  const LocalProfile({
    required this.id,
    required this.userId,
    required this.displayName,
    this.age,
    this.biologicalSex,
    this.heightCm,
    this.weightKg,
    required this.goalsJson,
    this.activityLevel,
    this.dietaryIdentity,
    this.mealFrequency,
    this.fastingProtocol,
    required this.allergiesJson,
    this.targetCalories,
    required this.locale,
    required this.isConsentGiven,
    this.metadataJson,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || biologicalSex != null) {
      map['biological_sex'] = Variable<String>(biologicalSex);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    map['goals_json'] = Variable<String>(goalsJson);
    if (!nullToAbsent || activityLevel != null) {
      map['activity_level'] = Variable<String>(activityLevel);
    }
    if (!nullToAbsent || dietaryIdentity != null) {
      map['dietary_identity'] = Variable<String>(dietaryIdentity);
    }
    if (!nullToAbsent || mealFrequency != null) {
      map['meal_frequency'] = Variable<int>(mealFrequency);
    }
    if (!nullToAbsent || fastingProtocol != null) {
      map['fasting_protocol'] = Variable<String>(fastingProtocol);
    }
    map['allergies_json'] = Variable<String>(allergiesJson);
    if (!nullToAbsent || targetCalories != null) {
      map['target_calories'] = Variable<int>(targetCalories);
    }
    map['locale'] = Variable<String>(locale);
    map['is_consent_given'] = Variable<bool>(isConsentGiven);
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LocalProfilesCompanion toCompanion(bool nullToAbsent) {
    return LocalProfilesCompanion(
      id: Value(id),
      userId: Value(userId),
      displayName: Value(displayName),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      biologicalSex: biologicalSex == null && nullToAbsent
          ? const Value.absent()
          : Value(biologicalSex),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      goalsJson: Value(goalsJson),
      activityLevel: activityLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(activityLevel),
      dietaryIdentity: dietaryIdentity == null && nullToAbsent
          ? const Value.absent()
          : Value(dietaryIdentity),
      mealFrequency: mealFrequency == null && nullToAbsent
          ? const Value.absent()
          : Value(mealFrequency),
      fastingProtocol: fastingProtocol == null && nullToAbsent
          ? const Value.absent()
          : Value(fastingProtocol),
      allergiesJson: Value(allergiesJson),
      targetCalories: targetCalories == null && nullToAbsent
          ? const Value.absent()
          : Value(targetCalories),
      locale: Value(locale),
      isConsentGiven: Value(isConsentGiven),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProfile(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      age: serializer.fromJson<int?>(json['age']),
      biologicalSex: serializer.fromJson<String?>(json['biologicalSex']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      goalsJson: serializer.fromJson<String>(json['goalsJson']),
      activityLevel: serializer.fromJson<String?>(json['activityLevel']),
      dietaryIdentity: serializer.fromJson<String?>(json['dietaryIdentity']),
      mealFrequency: serializer.fromJson<int?>(json['mealFrequency']),
      fastingProtocol: serializer.fromJson<String?>(json['fastingProtocol']),
      allergiesJson: serializer.fromJson<String>(json['allergiesJson']),
      targetCalories: serializer.fromJson<int?>(json['targetCalories']),
      locale: serializer.fromJson<String>(json['locale']),
      isConsentGiven: serializer.fromJson<bool>(json['isConsentGiven']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'displayName': serializer.toJson<String>(displayName),
      'age': serializer.toJson<int?>(age),
      'biologicalSex': serializer.toJson<String?>(biologicalSex),
      'heightCm': serializer.toJson<double?>(heightCm),
      'weightKg': serializer.toJson<double?>(weightKg),
      'goalsJson': serializer.toJson<String>(goalsJson),
      'activityLevel': serializer.toJson<String?>(activityLevel),
      'dietaryIdentity': serializer.toJson<String?>(dietaryIdentity),
      'mealFrequency': serializer.toJson<int?>(mealFrequency),
      'fastingProtocol': serializer.toJson<String?>(fastingProtocol),
      'allergiesJson': serializer.toJson<String>(allergiesJson),
      'targetCalories': serializer.toJson<int?>(targetCalories),
      'locale': serializer.toJson<String>(locale),
      'isConsentGiven': serializer.toJson<bool>(isConsentGiven),
      'metadataJson': serializer.toJson<String?>(metadataJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalProfile copyWith({
    String? id,
    String? userId,
    String? displayName,
    Value<int?> age = const Value.absent(),
    Value<String?> biologicalSex = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    String? goalsJson,
    Value<String?> activityLevel = const Value.absent(),
    Value<String?> dietaryIdentity = const Value.absent(),
    Value<int?> mealFrequency = const Value.absent(),
    Value<String?> fastingProtocol = const Value.absent(),
    String? allergiesJson,
    Value<int?> targetCalories = const Value.absent(),
    String? locale,
    bool? isConsentGiven,
    Value<String?> metadataJson = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => LocalProfile(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    displayName: displayName ?? this.displayName,
    age: age.present ? age.value : this.age,
    biologicalSex: biologicalSex.present
        ? biologicalSex.value
        : this.biologicalSex,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    goalsJson: goalsJson ?? this.goalsJson,
    activityLevel: activityLevel.present
        ? activityLevel.value
        : this.activityLevel,
    dietaryIdentity: dietaryIdentity.present
        ? dietaryIdentity.value
        : this.dietaryIdentity,
    mealFrequency: mealFrequency.present
        ? mealFrequency.value
        : this.mealFrequency,
    fastingProtocol: fastingProtocol.present
        ? fastingProtocol.value
        : this.fastingProtocol,
    allergiesJson: allergiesJson ?? this.allergiesJson,
    targetCalories: targetCalories.present
        ? targetCalories.value
        : this.targetCalories,
    locale: locale ?? this.locale,
    isConsentGiven: isConsentGiven ?? this.isConsentGiven,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  LocalProfile copyWithCompanion(LocalProfilesCompanion data) {
    return LocalProfile(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      age: data.age.present ? data.age.value : this.age,
      biologicalSex: data.biologicalSex.present
          ? data.biologicalSex.value
          : this.biologicalSex,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      goalsJson: data.goalsJson.present ? data.goalsJson.value : this.goalsJson,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      dietaryIdentity: data.dietaryIdentity.present
          ? data.dietaryIdentity.value
          : this.dietaryIdentity,
      mealFrequency: data.mealFrequency.present
          ? data.mealFrequency.value
          : this.mealFrequency,
      fastingProtocol: data.fastingProtocol.present
          ? data.fastingProtocol.value
          : this.fastingProtocol,
      allergiesJson: data.allergiesJson.present
          ? data.allergiesJson.value
          : this.allergiesJson,
      targetCalories: data.targetCalories.present
          ? data.targetCalories.value
          : this.targetCalories,
      locale: data.locale.present ? data.locale.value : this.locale,
      isConsentGiven: data.isConsentGiven.present
          ? data.isConsentGiven.value
          : this.isConsentGiven,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfile(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('age: $age, ')
          ..write('biologicalSex: $biologicalSex, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('goalsJson: $goalsJson, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('dietaryIdentity: $dietaryIdentity, ')
          ..write('mealFrequency: $mealFrequency, ')
          ..write('fastingProtocol: $fastingProtocol, ')
          ..write('allergiesJson: $allergiesJson, ')
          ..write('targetCalories: $targetCalories, ')
          ..write('locale: $locale, ')
          ..write('isConsentGiven: $isConsentGiven, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    displayName,
    age,
    biologicalSex,
    heightCm,
    weightKg,
    goalsJson,
    activityLevel,
    dietaryIdentity,
    mealFrequency,
    fastingProtocol,
    allergiesJson,
    targetCalories,
    locale,
    isConsentGiven,
    metadataJson,
    createdAt,
    updatedAt,
    isSynced,
    lastSyncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProfile &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.age == this.age &&
          other.biologicalSex == this.biologicalSex &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.goalsJson == this.goalsJson &&
          other.activityLevel == this.activityLevel &&
          other.dietaryIdentity == this.dietaryIdentity &&
          other.mealFrequency == this.mealFrequency &&
          other.fastingProtocol == this.fastingProtocol &&
          other.allergiesJson == this.allergiesJson &&
          other.targetCalories == this.targetCalories &&
          other.locale == this.locale &&
          other.isConsentGiven == this.isConsentGiven &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalProfilesCompanion extends UpdateCompanion<LocalProfile> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> displayName;
  final Value<int?> age;
  final Value<String?> biologicalSex;
  final Value<double?> heightCm;
  final Value<double?> weightKg;
  final Value<String> goalsJson;
  final Value<String?> activityLevel;
  final Value<String?> dietaryIdentity;
  final Value<int?> mealFrequency;
  final Value<String?> fastingProtocol;
  final Value<String> allergiesJson;
  final Value<int?> targetCalories;
  final Value<String> locale;
  final Value<bool> isConsentGiven;
  final Value<String?> metadataJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const LocalProfilesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.age = const Value.absent(),
    this.biologicalSex = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.goalsJson = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.dietaryIdentity = const Value.absent(),
    this.mealFrequency = const Value.absent(),
    this.fastingProtocol = const Value.absent(),
    this.allergiesJson = const Value.absent(),
    this.targetCalories = const Value.absent(),
    this.locale = const Value.absent(),
    this.isConsentGiven = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProfilesCompanion.insert({
    required String id,
    required String userId,
    required String displayName,
    this.age = const Value.absent(),
    this.biologicalSex = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.goalsJson = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.dietaryIdentity = const Value.absent(),
    this.mealFrequency = const Value.absent(),
    this.fastingProtocol = const Value.absent(),
    this.allergiesJson = const Value.absent(),
    this.targetCalories = const Value.absent(),
    this.locale = const Value.absent(),
    this.isConsentGiven = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isSynced = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       displayName = Value(displayName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalProfile> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<int>? age,
    Expression<String>? biologicalSex,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<String>? goalsJson,
    Expression<String>? activityLevel,
    Expression<String>? dietaryIdentity,
    Expression<int>? mealFrequency,
    Expression<String>? fastingProtocol,
    Expression<String>? allergiesJson,
    Expression<int>? targetCalories,
    Expression<String>? locale,
    Expression<bool>? isConsentGiven,
    Expression<String>? metadataJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (age != null) 'age': age,
      if (biologicalSex != null) 'biological_sex': biologicalSex,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (goalsJson != null) 'goals_json': goalsJson,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (dietaryIdentity != null) 'dietary_identity': dietaryIdentity,
      if (mealFrequency != null) 'meal_frequency': mealFrequency,
      if (fastingProtocol != null) 'fasting_protocol': fastingProtocol,
      if (allergiesJson != null) 'allergies_json': allergiesJson,
      if (targetCalories != null) 'target_calories': targetCalories,
      if (locale != null) 'locale': locale,
      if (isConsentGiven != null) 'is_consent_given': isConsentGiven,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? displayName,
    Value<int?>? age,
    Value<String?>? biologicalSex,
    Value<double?>? heightCm,
    Value<double?>? weightKg,
    Value<String>? goalsJson,
    Value<String?>? activityLevel,
    Value<String?>? dietaryIdentity,
    Value<int?>? mealFrequency,
    Value<String?>? fastingProtocol,
    Value<String>? allergiesJson,
    Value<int?>? targetCalories,
    Value<String>? locale,
    Value<bool>? isConsentGiven,
    Value<String?>? metadataJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isSynced,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return LocalProfilesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      biologicalSex: biologicalSex ?? this.biologicalSex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goalsJson: goalsJson ?? this.goalsJson,
      activityLevel: activityLevel ?? this.activityLevel,
      dietaryIdentity: dietaryIdentity ?? this.dietaryIdentity,
      mealFrequency: mealFrequency ?? this.mealFrequency,
      fastingProtocol: fastingProtocol ?? this.fastingProtocol,
      allergiesJson: allergiesJson ?? this.allergiesJson,
      targetCalories: targetCalories ?? this.targetCalories,
      locale: locale ?? this.locale,
      isConsentGiven: isConsentGiven ?? this.isConsentGiven,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (biologicalSex.present) {
      map['biological_sex'] = Variable<String>(biologicalSex.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (goalsJson.present) {
      map['goals_json'] = Variable<String>(goalsJson.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(activityLevel.value);
    }
    if (dietaryIdentity.present) {
      map['dietary_identity'] = Variable<String>(dietaryIdentity.value);
    }
    if (mealFrequency.present) {
      map['meal_frequency'] = Variable<int>(mealFrequency.value);
    }
    if (fastingProtocol.present) {
      map['fasting_protocol'] = Variable<String>(fastingProtocol.value);
    }
    if (allergiesJson.present) {
      map['allergies_json'] = Variable<String>(allergiesJson.value);
    }
    if (targetCalories.present) {
      map['target_calories'] = Variable<int>(targetCalories.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (isConsentGiven.present) {
      map['is_consent_given'] = Variable<bool>(isConsentGiven.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfilesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('age: $age, ')
          ..write('biologicalSex: $biologicalSex, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('goalsJson: $goalsJson, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('dietaryIdentity: $dietaryIdentity, ')
          ..write('mealFrequency: $mealFrequency, ')
          ..write('fastingProtocol: $fastingProtocol, ')
          ..write('allergiesJson: $allergiesJson, ')
          ..write('targetCalories: $targetCalories, ')
          ..write('locale: $locale, ')
          ..write('isConsentGiven: $isConsentGiven, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalWellnessProfilesTable extends LocalWellnessProfiles
    with TableInfo<$LocalWellnessProfilesTable, LocalWellnessProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalWellnessProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _dominantDoshaMeta = const VerificationMeta(
    'dominantDosha',
  );
  @override
  late final GeneratedColumn<String> dominantDosha = GeneratedColumn<String>(
    'dominant_dosha',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secondaryDoshaMeta = const VerificationMeta(
    'secondaryDosha',
  );
  @override
  late final GeneratedColumn<String> secondaryDosha = GeneratedColumn<String>(
    'secondary_dosha',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isTridoshicMeta = const VerificationMeta(
    'isTridoshic',
  );
  @override
  late final GeneratedColumn<bool> isTridoshic = GeneratedColumn<bool>(
    'is_tridoshic',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_tridoshic" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _vataPercentageMeta = const VerificationMeta(
    'vataPercentage',
  );
  @override
  late final GeneratedColumn<double> vataPercentage = GeneratedColumn<double>(
    'vata_percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pittaPercentageMeta = const VerificationMeta(
    'pittaPercentage',
  );
  @override
  late final GeneratedColumn<double> pittaPercentage = GeneratedColumn<double>(
    'pitta_percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kaphaPercentageMeta = const VerificationMeta(
    'kaphaPercentage',
  );
  @override
  late final GeneratedColumn<double> kaphaPercentage = GeneratedColumn<double>(
    'kapha_percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answersJsonMeta = const VerificationMeta(
    'answersJson',
  );
  @override
  late final GeneratedColumn<String> answersJson = GeneratedColumn<String>(
    'answers_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _recommendationsJsonMeta =
      const VerificationMeta('recommendationsJson');
  @override
  late final GeneratedColumn<String> recommendationsJson =
      GeneratedColumn<String>(
        'recommendations_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _isSkippedMeta = const VerificationMeta(
    'isSkipped',
  );
  @override
  late final GeneratedColumn<bool> isSkipped = GeneratedColumn<bool>(
    'is_skipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_skipped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    dominantDosha,
    secondaryDosha,
    isTridoshic,
    vataPercentage,
    pittaPercentage,
    kaphaPercentage,
    answersJson,
    recommendationsJson,
    isSkipped,
    completedAt,
    updatedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_wellness_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalWellnessProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('dominant_dosha')) {
      context.handle(
        _dominantDoshaMeta,
        dominantDosha.isAcceptableOrUnknown(
          data['dominant_dosha']!,
          _dominantDoshaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dominantDoshaMeta);
    }
    if (data.containsKey('secondary_dosha')) {
      context.handle(
        _secondaryDoshaMeta,
        secondaryDosha.isAcceptableOrUnknown(
          data['secondary_dosha']!,
          _secondaryDoshaMeta,
        ),
      );
    }
    if (data.containsKey('is_tridoshic')) {
      context.handle(
        _isTridoshicMeta,
        isTridoshic.isAcceptableOrUnknown(
          data['is_tridoshic']!,
          _isTridoshicMeta,
        ),
      );
    }
    if (data.containsKey('vata_percentage')) {
      context.handle(
        _vataPercentageMeta,
        vataPercentage.isAcceptableOrUnknown(
          data['vata_percentage']!,
          _vataPercentageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vataPercentageMeta);
    }
    if (data.containsKey('pitta_percentage')) {
      context.handle(
        _pittaPercentageMeta,
        pittaPercentage.isAcceptableOrUnknown(
          data['pitta_percentage']!,
          _pittaPercentageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pittaPercentageMeta);
    }
    if (data.containsKey('kapha_percentage')) {
      context.handle(
        _kaphaPercentageMeta,
        kaphaPercentage.isAcceptableOrUnknown(
          data['kapha_percentage']!,
          _kaphaPercentageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kaphaPercentageMeta);
    }
    if (data.containsKey('answers_json')) {
      context.handle(
        _answersJsonMeta,
        answersJson.isAcceptableOrUnknown(
          data['answers_json']!,
          _answersJsonMeta,
        ),
      );
    }
    if (data.containsKey('recommendations_json')) {
      context.handle(
        _recommendationsJsonMeta,
        recommendationsJson.isAcceptableOrUnknown(
          data['recommendations_json']!,
          _recommendationsJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_skipped')) {
      context.handle(
        _isSkippedMeta,
        isSkipped.isAcceptableOrUnknown(data['is_skipped']!, _isSkippedMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalWellnessProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalWellnessProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      dominantDosha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dominant_dosha'],
      )!,
      secondaryDosha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secondary_dosha'],
      ),
      isTridoshic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_tridoshic'],
      )!,
      vataPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vata_percentage'],
      )!,
      pittaPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pitta_percentage'],
      )!,
      kaphaPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kapha_percentage'],
      )!,
      answersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answers_json'],
      )!,
      recommendationsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recommendations_json'],
      )!,
      isSkipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_skipped'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $LocalWellnessProfilesTable createAlias(String alias) {
    return $LocalWellnessProfilesTable(attachedDatabase, alias);
  }
}

class LocalWellnessProfile extends DataClass
    implements Insertable<LocalWellnessProfile> {
  final String id;
  final String userId;
  final String dominantDosha;
  final String? secondaryDosha;
  final bool isTridoshic;
  final double vataPercentage;
  final double pittaPercentage;
  final double kaphaPercentage;
  final String answersJson;
  final String recommendationsJson;
  final bool isSkipped;
  final DateTime? completedAt;
  final DateTime updatedAt;
  final bool isSynced;
  const LocalWellnessProfile({
    required this.id,
    required this.userId,
    required this.dominantDosha,
    this.secondaryDosha,
    required this.isTridoshic,
    required this.vataPercentage,
    required this.pittaPercentage,
    required this.kaphaPercentage,
    required this.answersJson,
    required this.recommendationsJson,
    required this.isSkipped,
    this.completedAt,
    required this.updatedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['dominant_dosha'] = Variable<String>(dominantDosha);
    if (!nullToAbsent || secondaryDosha != null) {
      map['secondary_dosha'] = Variable<String>(secondaryDosha);
    }
    map['is_tridoshic'] = Variable<bool>(isTridoshic);
    map['vata_percentage'] = Variable<double>(vataPercentage);
    map['pitta_percentage'] = Variable<double>(pittaPercentage);
    map['kapha_percentage'] = Variable<double>(kaphaPercentage);
    map['answers_json'] = Variable<String>(answersJson);
    map['recommendations_json'] = Variable<String>(recommendationsJson);
    map['is_skipped'] = Variable<bool>(isSkipped);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  LocalWellnessProfilesCompanion toCompanion(bool nullToAbsent) {
    return LocalWellnessProfilesCompanion(
      id: Value(id),
      userId: Value(userId),
      dominantDosha: Value(dominantDosha),
      secondaryDosha: secondaryDosha == null && nullToAbsent
          ? const Value.absent()
          : Value(secondaryDosha),
      isTridoshic: Value(isTridoshic),
      vataPercentage: Value(vataPercentage),
      pittaPercentage: Value(pittaPercentage),
      kaphaPercentage: Value(kaphaPercentage),
      answersJson: Value(answersJson),
      recommendationsJson: Value(recommendationsJson),
      isSkipped: Value(isSkipped),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
    );
  }

  factory LocalWellnessProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalWellnessProfile(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      dominantDosha: serializer.fromJson<String>(json['dominantDosha']),
      secondaryDosha: serializer.fromJson<String?>(json['secondaryDosha']),
      isTridoshic: serializer.fromJson<bool>(json['isTridoshic']),
      vataPercentage: serializer.fromJson<double>(json['vataPercentage']),
      pittaPercentage: serializer.fromJson<double>(json['pittaPercentage']),
      kaphaPercentage: serializer.fromJson<double>(json['kaphaPercentage']),
      answersJson: serializer.fromJson<String>(json['answersJson']),
      recommendationsJson: serializer.fromJson<String>(
        json['recommendationsJson'],
      ),
      isSkipped: serializer.fromJson<bool>(json['isSkipped']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'dominantDosha': serializer.toJson<String>(dominantDosha),
      'secondaryDosha': serializer.toJson<String?>(secondaryDosha),
      'isTridoshic': serializer.toJson<bool>(isTridoshic),
      'vataPercentage': serializer.toJson<double>(vataPercentage),
      'pittaPercentage': serializer.toJson<double>(pittaPercentage),
      'kaphaPercentage': serializer.toJson<double>(kaphaPercentage),
      'answersJson': serializer.toJson<String>(answersJson),
      'recommendationsJson': serializer.toJson<String>(recommendationsJson),
      'isSkipped': serializer.toJson<bool>(isSkipped),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  LocalWellnessProfile copyWith({
    String? id,
    String? userId,
    String? dominantDosha,
    Value<String?> secondaryDosha = const Value.absent(),
    bool? isTridoshic,
    double? vataPercentage,
    double? pittaPercentage,
    double? kaphaPercentage,
    String? answersJson,
    String? recommendationsJson,
    bool? isSkipped,
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? updatedAt,
    bool? isSynced,
  }) => LocalWellnessProfile(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    dominantDosha: dominantDosha ?? this.dominantDosha,
    secondaryDosha: secondaryDosha.present
        ? secondaryDosha.value
        : this.secondaryDosha,
    isTridoshic: isTridoshic ?? this.isTridoshic,
    vataPercentage: vataPercentage ?? this.vataPercentage,
    pittaPercentage: pittaPercentage ?? this.pittaPercentage,
    kaphaPercentage: kaphaPercentage ?? this.kaphaPercentage,
    answersJson: answersJson ?? this.answersJson,
    recommendationsJson: recommendationsJson ?? this.recommendationsJson,
    isSkipped: isSkipped ?? this.isSkipped,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  LocalWellnessProfile copyWithCompanion(LocalWellnessProfilesCompanion data) {
    return LocalWellnessProfile(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      dominantDosha: data.dominantDosha.present
          ? data.dominantDosha.value
          : this.dominantDosha,
      secondaryDosha: data.secondaryDosha.present
          ? data.secondaryDosha.value
          : this.secondaryDosha,
      isTridoshic: data.isTridoshic.present
          ? data.isTridoshic.value
          : this.isTridoshic,
      vataPercentage: data.vataPercentage.present
          ? data.vataPercentage.value
          : this.vataPercentage,
      pittaPercentage: data.pittaPercentage.present
          ? data.pittaPercentage.value
          : this.pittaPercentage,
      kaphaPercentage: data.kaphaPercentage.present
          ? data.kaphaPercentage.value
          : this.kaphaPercentage,
      answersJson: data.answersJson.present
          ? data.answersJson.value
          : this.answersJson,
      recommendationsJson: data.recommendationsJson.present
          ? data.recommendationsJson.value
          : this.recommendationsJson,
      isSkipped: data.isSkipped.present ? data.isSkipped.value : this.isSkipped,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalWellnessProfile(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dominantDosha: $dominantDosha, ')
          ..write('secondaryDosha: $secondaryDosha, ')
          ..write('isTridoshic: $isTridoshic, ')
          ..write('vataPercentage: $vataPercentage, ')
          ..write('pittaPercentage: $pittaPercentage, ')
          ..write('kaphaPercentage: $kaphaPercentage, ')
          ..write('answersJson: $answersJson, ')
          ..write('recommendationsJson: $recommendationsJson, ')
          ..write('isSkipped: $isSkipped, ')
          ..write('completedAt: $completedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    dominantDosha,
    secondaryDosha,
    isTridoshic,
    vataPercentage,
    pittaPercentage,
    kaphaPercentage,
    answersJson,
    recommendationsJson,
    isSkipped,
    completedAt,
    updatedAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalWellnessProfile &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.dominantDosha == this.dominantDosha &&
          other.secondaryDosha == this.secondaryDosha &&
          other.isTridoshic == this.isTridoshic &&
          other.vataPercentage == this.vataPercentage &&
          other.pittaPercentage == this.pittaPercentage &&
          other.kaphaPercentage == this.kaphaPercentage &&
          other.answersJson == this.answersJson &&
          other.recommendationsJson == this.recommendationsJson &&
          other.isSkipped == this.isSkipped &&
          other.completedAt == this.completedAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced);
}

class LocalWellnessProfilesCompanion
    extends UpdateCompanion<LocalWellnessProfile> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> dominantDosha;
  final Value<String?> secondaryDosha;
  final Value<bool> isTridoshic;
  final Value<double> vataPercentage;
  final Value<double> pittaPercentage;
  final Value<double> kaphaPercentage;
  final Value<String> answersJson;
  final Value<String> recommendationsJson;
  final Value<bool> isSkipped;
  final Value<DateTime?> completedAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const LocalWellnessProfilesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.dominantDosha = const Value.absent(),
    this.secondaryDosha = const Value.absent(),
    this.isTridoshic = const Value.absent(),
    this.vataPercentage = const Value.absent(),
    this.pittaPercentage = const Value.absent(),
    this.kaphaPercentage = const Value.absent(),
    this.answersJson = const Value.absent(),
    this.recommendationsJson = const Value.absent(),
    this.isSkipped = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalWellnessProfilesCompanion.insert({
    required String id,
    required String userId,
    required String dominantDosha,
    this.secondaryDosha = const Value.absent(),
    this.isTridoshic = const Value.absent(),
    required double vataPercentage,
    required double pittaPercentage,
    required double kaphaPercentage,
    this.answersJson = const Value.absent(),
    this.recommendationsJson = const Value.absent(),
    this.isSkipped = const Value.absent(),
    this.completedAt = const Value.absent(),
    required DateTime updatedAt,
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       dominantDosha = Value(dominantDosha),
       vataPercentage = Value(vataPercentage),
       pittaPercentage = Value(pittaPercentage),
       kaphaPercentage = Value(kaphaPercentage),
       updatedAt = Value(updatedAt);
  static Insertable<LocalWellnessProfile> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? dominantDosha,
    Expression<String>? secondaryDosha,
    Expression<bool>? isTridoshic,
    Expression<double>? vataPercentage,
    Expression<double>? pittaPercentage,
    Expression<double>? kaphaPercentage,
    Expression<String>? answersJson,
    Expression<String>? recommendationsJson,
    Expression<bool>? isSkipped,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (dominantDosha != null) 'dominant_dosha': dominantDosha,
      if (secondaryDosha != null) 'secondary_dosha': secondaryDosha,
      if (isTridoshic != null) 'is_tridoshic': isTridoshic,
      if (vataPercentage != null) 'vata_percentage': vataPercentage,
      if (pittaPercentage != null) 'pitta_percentage': pittaPercentage,
      if (kaphaPercentage != null) 'kapha_percentage': kaphaPercentage,
      if (answersJson != null) 'answers_json': answersJson,
      if (recommendationsJson != null)
        'recommendations_json': recommendationsJson,
      if (isSkipped != null) 'is_skipped': isSkipped,
      if (completedAt != null) 'completed_at': completedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalWellnessProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? dominantDosha,
    Value<String?>? secondaryDosha,
    Value<bool>? isTridoshic,
    Value<double>? vataPercentage,
    Value<double>? pittaPercentage,
    Value<double>? kaphaPercentage,
    Value<String>? answersJson,
    Value<String>? recommendationsJson,
    Value<bool>? isSkipped,
    Value<DateTime?>? completedAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return LocalWellnessProfilesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dominantDosha: dominantDosha ?? this.dominantDosha,
      secondaryDosha: secondaryDosha ?? this.secondaryDosha,
      isTridoshic: isTridoshic ?? this.isTridoshic,
      vataPercentage: vataPercentage ?? this.vataPercentage,
      pittaPercentage: pittaPercentage ?? this.pittaPercentage,
      kaphaPercentage: kaphaPercentage ?? this.kaphaPercentage,
      answersJson: answersJson ?? this.answersJson,
      recommendationsJson: recommendationsJson ?? this.recommendationsJson,
      isSkipped: isSkipped ?? this.isSkipped,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (dominantDosha.present) {
      map['dominant_dosha'] = Variable<String>(dominantDosha.value);
    }
    if (secondaryDosha.present) {
      map['secondary_dosha'] = Variable<String>(secondaryDosha.value);
    }
    if (isTridoshic.present) {
      map['is_tridoshic'] = Variable<bool>(isTridoshic.value);
    }
    if (vataPercentage.present) {
      map['vata_percentage'] = Variable<double>(vataPercentage.value);
    }
    if (pittaPercentage.present) {
      map['pitta_percentage'] = Variable<double>(pittaPercentage.value);
    }
    if (kaphaPercentage.present) {
      map['kapha_percentage'] = Variable<double>(kaphaPercentage.value);
    }
    if (answersJson.present) {
      map['answers_json'] = Variable<String>(answersJson.value);
    }
    if (recommendationsJson.present) {
      map['recommendations_json'] = Variable<String>(recommendationsJson.value);
    }
    if (isSkipped.present) {
      map['is_skipped'] = Variable<bool>(isSkipped.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalWellnessProfilesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dominantDosha: $dominantDosha, ')
          ..write('secondaryDosha: $secondaryDosha, ')
          ..write('isTridoshic: $isTridoshic, ')
          ..write('vataPercentage: $vataPercentage, ')
          ..write('pittaPercentage: $pittaPercentage, ')
          ..write('kaphaPercentage: $kaphaPercentage, ')
          ..write('answersJson: $answersJson, ')
          ..write('recommendationsJson: $recommendationsJson, ')
          ..write('isSkipped: $isSkipped, ')
          ..write('completedAt: $completedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSyncOutboxTable extends LocalSyncOutbox
    with TableInfo<$LocalSyncOutboxTable, LocalSyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    operation,
    payloadJson,
    idempotencyKey,
    retryCount,
    lastError,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSyncOutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalSyncOutboxTable createAlias(String alias) {
    return $LocalSyncOutboxTable(attachedDatabase, alias);
  }
}

class LocalSyncOutboxData extends DataClass
    implements Insertable<LocalSyncOutboxData> {
  final String id;
  final String entityType;
  final String entityId;
  final String operation;
  final String payloadJson;
  final String idempotencyKey;
  final int retryCount;
  final String? lastError;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalSyncOutboxData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payloadJson,
    required this.idempotencyKey,
    required this.retryCount,
    this.lastError,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalSyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return LocalSyncOutboxCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      idempotencyKey: Value(idempotencyKey),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalSyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSyncOutboxData(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalSyncOutboxData copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? operation,
    String? payloadJson,
    String? idempotencyKey,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalSyncOutboxData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalSyncOutboxData copyWithCompanion(LocalSyncOutboxCompanion data) {
    return LocalSyncOutboxData(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncOutboxData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    operation,
    payloadJson,
    idempotencyKey,
    retryCount,
    lastError,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSyncOutboxData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.idempotencyKey == this.idempotencyKey &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalSyncOutboxCompanion extends UpdateCompanion<LocalSyncOutboxData> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<String> idempotencyKey;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalSyncOutboxCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSyncOutboxCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String operation,
    required String payloadJson,
    required String idempotencyKey,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       payloadJson = Value(payloadJson),
       idempotencyKey = Value(idempotencyKey),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalSyncOutboxData> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<String>? idempotencyKey,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSyncOutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payloadJson,
    Value<String>? idempotencyKey,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalSyncOutboxCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAppSettingsTable extends LocalAppSettings
    with TableInfo<$LocalAppSettingsTable, LocalAppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LocalAppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalAppSettingsTable createAlias(String alias) {
    return $LocalAppSettingsTable(attachedDatabase, alias);
  }
}

class LocalAppSetting extends DataClass implements Insertable<LocalAppSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const LocalAppSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalAppSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocalAppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalAppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalAppSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      LocalAppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalAppSetting copyWithCompanion(LocalAppSettingsCompanion data) {
    return LocalAppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class LocalAppSettingsCompanion extends UpdateCompanion<LocalAppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalAppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAppSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<LocalAppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalAppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalProfilesTable localProfiles = $LocalProfilesTable(this);
  late final $LocalWellnessProfilesTable localWellnessProfiles =
      $LocalWellnessProfilesTable(this);
  late final $LocalSyncOutboxTable localSyncOutbox = $LocalSyncOutboxTable(
    this,
  );
  late final $LocalAppSettingsTable localAppSettings = $LocalAppSettingsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localProfiles,
    localWellnessProfiles,
    localSyncOutbox,
    localAppSettings,
  ];
}

typedef $$LocalProfilesTableCreateCompanionBuilder =
    LocalProfilesCompanion Function({
      required String id,
      required String userId,
      required String displayName,
      Value<int?> age,
      Value<String?> biologicalSex,
      Value<double?> heightCm,
      Value<double?> weightKg,
      Value<String> goalsJson,
      Value<String?> activityLevel,
      Value<String?> dietaryIdentity,
      Value<int?> mealFrequency,
      Value<String?> fastingProtocol,
      Value<String> allergiesJson,
      Value<int?> targetCalories,
      Value<String> locale,
      Value<bool> isConsentGiven,
      Value<String?> metadataJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isSynced,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$LocalProfilesTableUpdateCompanionBuilder =
    LocalProfilesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> displayName,
      Value<int?> age,
      Value<String?> biologicalSex,
      Value<double?> heightCm,
      Value<double?> weightKg,
      Value<String> goalsJson,
      Value<String?> activityLevel,
      Value<String?> dietaryIdentity,
      Value<int?> mealFrequency,
      Value<String?> fastingProtocol,
      Value<String> allergiesJson,
      Value<int?> targetCalories,
      Value<String> locale,
      Value<bool> isConsentGiven,
      Value<String?> metadataJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isSynced,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

class $$LocalProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get biologicalSex => $composableBuilder(
    column: $table.biologicalSex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalsJson => $composableBuilder(
    column: $table.goalsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dietaryIdentity => $composableBuilder(
    column: $table.dietaryIdentity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mealFrequency => $composableBuilder(
    column: $table.mealFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fastingProtocol => $composableBuilder(
    column: $table.fastingProtocol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allergiesJson => $composableBuilder(
    column: $table.allergiesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCalories => $composableBuilder(
    column: $table.targetCalories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isConsentGiven => $composableBuilder(
    column: $table.isConsentGiven,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get biologicalSex => $composableBuilder(
    column: $table.biologicalSex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalsJson => $composableBuilder(
    column: $table.goalsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dietaryIdentity => $composableBuilder(
    column: $table.dietaryIdentity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mealFrequency => $composableBuilder(
    column: $table.mealFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fastingProtocol => $composableBuilder(
    column: $table.fastingProtocol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allergiesJson => $composableBuilder(
    column: $table.allergiesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCalories => $composableBuilder(
    column: $table.targetCalories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isConsentGiven => $composableBuilder(
    column: $table.isConsentGiven,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get biologicalSex => $composableBuilder(
    column: $table.biologicalSex,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get goalsJson =>
      $composableBuilder(column: $table.goalsJson, builder: (column) => column);

  GeneratedColumn<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dietaryIdentity => $composableBuilder(
    column: $table.dietaryIdentity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mealFrequency => $composableBuilder(
    column: $table.mealFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fastingProtocol => $composableBuilder(
    column: $table.fastingProtocol,
    builder: (column) => column,
  );

  GeneratedColumn<String> get allergiesJson => $composableBuilder(
    column: $table.allergiesJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetCalories => $composableBuilder(
    column: $table.targetCalories,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<bool> get isConsentGiven => $composableBuilder(
    column: $table.isConsentGiven,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$LocalProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalProfilesTable,
          LocalProfile,
          $$LocalProfilesTableFilterComposer,
          $$LocalProfilesTableOrderingComposer,
          $$LocalProfilesTableAnnotationComposer,
          $$LocalProfilesTableCreateCompanionBuilder,
          $$LocalProfilesTableUpdateCompanionBuilder,
          (
            LocalProfile,
            BaseReferences<_$AppDatabase, $LocalProfilesTable, LocalProfile>,
          ),
          LocalProfile,
          PrefetchHooks Function()
        > {
  $$LocalProfilesTableTableManager(_$AppDatabase db, $LocalProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<String?> biologicalSex = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String> goalsJson = const Value.absent(),
                Value<String?> activityLevel = const Value.absent(),
                Value<String?> dietaryIdentity = const Value.absent(),
                Value<int?> mealFrequency = const Value.absent(),
                Value<String?> fastingProtocol = const Value.absent(),
                Value<String> allergiesJson = const Value.absent(),
                Value<int?> targetCalories = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<bool> isConsentGiven = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProfilesCompanion(
                id: id,
                userId: userId,
                displayName: displayName,
                age: age,
                biologicalSex: biologicalSex,
                heightCm: heightCm,
                weightKg: weightKg,
                goalsJson: goalsJson,
                activityLevel: activityLevel,
                dietaryIdentity: dietaryIdentity,
                mealFrequency: mealFrequency,
                fastingProtocol: fastingProtocol,
                allergiesJson: allergiesJson,
                targetCalories: targetCalories,
                locale: locale,
                isConsentGiven: isConsentGiven,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String displayName,
                Value<int?> age = const Value.absent(),
                Value<String?> biologicalSex = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String> goalsJson = const Value.absent(),
                Value<String?> activityLevel = const Value.absent(),
                Value<String?> dietaryIdentity = const Value.absent(),
                Value<int?> mealFrequency = const Value.absent(),
                Value<String?> fastingProtocol = const Value.absent(),
                Value<String> allergiesJson = const Value.absent(),
                Value<int?> targetCalories = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<bool> isConsentGiven = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProfilesCompanion.insert(
                id: id,
                userId: userId,
                displayName: displayName,
                age: age,
                biologicalSex: biologicalSex,
                heightCm: heightCm,
                weightKg: weightKg,
                goalsJson: goalsJson,
                activityLevel: activityLevel,
                dietaryIdentity: dietaryIdentity,
                mealFrequency: mealFrequency,
                fastingProtocol: fastingProtocol,
                allergiesJson: allergiesJson,
                targetCalories: targetCalories,
                locale: locale,
                isConsentGiven: isConsentGiven,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalProfilesTable, LocalProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalProfilesTable,
                    LocalProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalProfilesTable,
      LocalProfile,
      $$LocalProfilesTableFilterComposer,
      $$LocalProfilesTableOrderingComposer,
      $$LocalProfilesTableAnnotationComposer,
      $$LocalProfilesTableCreateCompanionBuilder,
      $$LocalProfilesTableUpdateCompanionBuilder,
      (
        LocalProfile,
        BaseReferences<_$AppDatabase, $LocalProfilesTable, LocalProfile>,
      ),
      LocalProfile,
      PrefetchHooks Function()
    >;
typedef $$LocalWellnessProfilesTableCreateCompanionBuilder =
    LocalWellnessProfilesCompanion Function({
      required String id,
      required String userId,
      required String dominantDosha,
      Value<String?> secondaryDosha,
      Value<bool> isTridoshic,
      required double vataPercentage,
      required double pittaPercentage,
      required double kaphaPercentage,
      Value<String> answersJson,
      Value<String> recommendationsJson,
      Value<bool> isSkipped,
      Value<DateTime?> completedAt,
      required DateTime updatedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$LocalWellnessProfilesTableUpdateCompanionBuilder =
    LocalWellnessProfilesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> dominantDosha,
      Value<String?> secondaryDosha,
      Value<bool> isTridoshic,
      Value<double> vataPercentage,
      Value<double> pittaPercentage,
      Value<double> kaphaPercentage,
      Value<String> answersJson,
      Value<String> recommendationsJson,
      Value<bool> isSkipped,
      Value<DateTime?> completedAt,
      Value<DateTime> updatedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$LocalWellnessProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalWellnessProfilesTable> {
  $$LocalWellnessProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dominantDosha => $composableBuilder(
    column: $table.dominantDosha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondaryDosha => $composableBuilder(
    column: $table.secondaryDosha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTridoshic => $composableBuilder(
    column: $table.isTridoshic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vataPercentage => $composableBuilder(
    column: $table.vataPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pittaPercentage => $composableBuilder(
    column: $table.pittaPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kaphaPercentage => $composableBuilder(
    column: $table.kaphaPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answersJson => $composableBuilder(
    column: $table.answersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recommendationsJson => $composableBuilder(
    column: $table.recommendationsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSkipped => $composableBuilder(
    column: $table.isSkipped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalWellnessProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalWellnessProfilesTable> {
  $$LocalWellnessProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dominantDosha => $composableBuilder(
    column: $table.dominantDosha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryDosha => $composableBuilder(
    column: $table.secondaryDosha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTridoshic => $composableBuilder(
    column: $table.isTridoshic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vataPercentage => $composableBuilder(
    column: $table.vataPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pittaPercentage => $composableBuilder(
    column: $table.pittaPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kaphaPercentage => $composableBuilder(
    column: $table.kaphaPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answersJson => $composableBuilder(
    column: $table.answersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recommendationsJson => $composableBuilder(
    column: $table.recommendationsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSkipped => $composableBuilder(
    column: $table.isSkipped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalWellnessProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalWellnessProfilesTable> {
  $$LocalWellnessProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get dominantDosha => $composableBuilder(
    column: $table.dominantDosha,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondaryDosha => $composableBuilder(
    column: $table.secondaryDosha,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTridoshic => $composableBuilder(
    column: $table.isTridoshic,
    builder: (column) => column,
  );

  GeneratedColumn<double> get vataPercentage => $composableBuilder(
    column: $table.vataPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pittaPercentage => $composableBuilder(
    column: $table.pittaPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get kaphaPercentage => $composableBuilder(
    column: $table.kaphaPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get answersJson => $composableBuilder(
    column: $table.answersJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recommendationsJson => $composableBuilder(
    column: $table.recommendationsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSkipped =>
      $composableBuilder(column: $table.isSkipped, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$LocalWellnessProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalWellnessProfilesTable,
          LocalWellnessProfile,
          $$LocalWellnessProfilesTableFilterComposer,
          $$LocalWellnessProfilesTableOrderingComposer,
          $$LocalWellnessProfilesTableAnnotationComposer,
          $$LocalWellnessProfilesTableCreateCompanionBuilder,
          $$LocalWellnessProfilesTableUpdateCompanionBuilder,
          (
            LocalWellnessProfile,
            BaseReferences<
              _$AppDatabase,
              $LocalWellnessProfilesTable,
              LocalWellnessProfile
            >,
          ),
          LocalWellnessProfile,
          PrefetchHooks Function()
        > {
  $$LocalWellnessProfilesTableTableManager(
    _$AppDatabase db,
    $LocalWellnessProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalWellnessProfilesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalWellnessProfilesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalWellnessProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> dominantDosha = const Value.absent(),
                Value<String?> secondaryDosha = const Value.absent(),
                Value<bool> isTridoshic = const Value.absent(),
                Value<double> vataPercentage = const Value.absent(),
                Value<double> pittaPercentage = const Value.absent(),
                Value<double> kaphaPercentage = const Value.absent(),
                Value<String> answersJson = const Value.absent(),
                Value<String> recommendationsJson = const Value.absent(),
                Value<bool> isSkipped = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWellnessProfilesCompanion(
                id: id,
                userId: userId,
                dominantDosha: dominantDosha,
                secondaryDosha: secondaryDosha,
                isTridoshic: isTridoshic,
                vataPercentage: vataPercentage,
                pittaPercentage: pittaPercentage,
                kaphaPercentage: kaphaPercentage,
                answersJson: answersJson,
                recommendationsJson: recommendationsJson,
                isSkipped: isSkipped,
                completedAt: completedAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String dominantDosha,
                Value<String?> secondaryDosha = const Value.absent(),
                Value<bool> isTridoshic = const Value.absent(),
                required double vataPercentage,
                required double pittaPercentage,
                required double kaphaPercentage,
                Value<String> answersJson = const Value.absent(),
                Value<String> recommendationsJson = const Value.absent(),
                Value<bool> isSkipped = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWellnessProfilesCompanion.insert(
                id: id,
                userId: userId,
                dominantDosha: dominantDosha,
                secondaryDosha: secondaryDosha,
                isTridoshic: isTridoshic,
                vataPercentage: vataPercentage,
                pittaPercentage: pittaPercentage,
                kaphaPercentage: kaphaPercentage,
                answersJson: answersJson,
                recommendationsJson: recommendationsJson,
                isSkipped: isSkipped,
                completedAt: completedAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $LocalWellnessProfilesTable,
                    LocalWellnessProfile
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalWellnessProfilesTable,
                    LocalWellnessProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalWellnessProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalWellnessProfilesTable,
      LocalWellnessProfile,
      $$LocalWellnessProfilesTableFilterComposer,
      $$LocalWellnessProfilesTableOrderingComposer,
      $$LocalWellnessProfilesTableAnnotationComposer,
      $$LocalWellnessProfilesTableCreateCompanionBuilder,
      $$LocalWellnessProfilesTableUpdateCompanionBuilder,
      (
        LocalWellnessProfile,
        BaseReferences<
          _$AppDatabase,
          $LocalWellnessProfilesTable,
          LocalWellnessProfile
        >,
      ),
      LocalWellnessProfile,
      PrefetchHooks Function()
    >;
typedef $$LocalSyncOutboxTableCreateCompanionBuilder =
    LocalSyncOutboxCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required String operation,
      required String payloadJson,
      required String idempotencyKey,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<String> status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalSyncOutboxTableUpdateCompanionBuilder =
    LocalSyncOutboxCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payloadJson,
      Value<String> idempotencyKey,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalSyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSyncOutboxTable> {
  $$LocalSyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSyncOutboxTable> {
  $$LocalSyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSyncOutboxTable> {
  $$LocalSyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalSyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSyncOutboxTable,
          LocalSyncOutboxData,
          $$LocalSyncOutboxTableFilterComposer,
          $$LocalSyncOutboxTableOrderingComposer,
          $$LocalSyncOutboxTableAnnotationComposer,
          $$LocalSyncOutboxTableCreateCompanionBuilder,
          $$LocalSyncOutboxTableUpdateCompanionBuilder,
          (
            LocalSyncOutboxData,
            BaseReferences<
              _$AppDatabase,
              $LocalSyncOutboxTable,
              LocalSyncOutboxData
            >,
          ),
          LocalSyncOutboxData,
          PrefetchHooks Function()
        > {
  $$LocalSyncOutboxTableTableManager(
    _$AppDatabase db,
    $LocalSyncOutboxTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSyncOutboxCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                idempotencyKey: idempotencyKey,
                retryCount: retryCount,
                lastError: lastError,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required String operation,
                required String payloadJson,
                required String idempotencyKey,
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalSyncOutboxCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                idempotencyKey: idempotencyKey,
                retryCount: retryCount,
                lastError: lastError,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalSyncOutboxTable, LocalSyncOutboxData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalSyncOutboxTable,
                    LocalSyncOutboxData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSyncOutboxTable,
      LocalSyncOutboxData,
      $$LocalSyncOutboxTableFilterComposer,
      $$LocalSyncOutboxTableOrderingComposer,
      $$LocalSyncOutboxTableAnnotationComposer,
      $$LocalSyncOutboxTableCreateCompanionBuilder,
      $$LocalSyncOutboxTableUpdateCompanionBuilder,
      (
        LocalSyncOutboxData,
        BaseReferences<
          _$AppDatabase,
          $LocalSyncOutboxTable,
          LocalSyncOutboxData
        >,
      ),
      LocalSyncOutboxData,
      PrefetchHooks Function()
    >;
typedef $$LocalAppSettingsTableCreateCompanionBuilder =
    LocalAppSettingsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalAppSettingsTableUpdateCompanionBuilder =
    LocalAppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalAppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAppSettingsTable> {
  $$LocalAppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAppSettingsTable> {
  $$LocalAppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAppSettingsTable> {
  $$LocalAppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalAppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAppSettingsTable,
          LocalAppSetting,
          $$LocalAppSettingsTableFilterComposer,
          $$LocalAppSettingsTableOrderingComposer,
          $$LocalAppSettingsTableAnnotationComposer,
          $$LocalAppSettingsTableCreateCompanionBuilder,
          $$LocalAppSettingsTableUpdateCompanionBuilder,
          (
            LocalAppSetting,
            BaseReferences<
              _$AppDatabase,
              $LocalAppSettingsTable,
              LocalAppSetting
            >,
          ),
          LocalAppSetting,
          PrefetchHooks Function()
        > {
  $$LocalAppSettingsTableTableManager(
    _$AppDatabase db,
    $LocalAppSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalAppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalAppSettingsTable, LocalAppSetting>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalAppSettingsTable,
                    LocalAppSetting
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAppSettingsTable,
      LocalAppSetting,
      $$LocalAppSettingsTableFilterComposer,
      $$LocalAppSettingsTableOrderingComposer,
      $$LocalAppSettingsTableAnnotationComposer,
      $$LocalAppSettingsTableCreateCompanionBuilder,
      $$LocalAppSettingsTableUpdateCompanionBuilder,
      (
        LocalAppSetting,
        BaseReferences<_$AppDatabase, $LocalAppSettingsTable, LocalAppSetting>,
      ),
      LocalAppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalProfilesTableTableManager get localProfiles =>
      $$LocalProfilesTableTableManager(_db, _db.localProfiles);
  $$LocalWellnessProfilesTableTableManager get localWellnessProfiles =>
      $$LocalWellnessProfilesTableTableManager(_db, _db.localWellnessProfiles);
  $$LocalSyncOutboxTableTableManager get localSyncOutbox =>
      $$LocalSyncOutboxTableTableManager(_db, _db.localSyncOutbox);
  $$LocalAppSettingsTableTableManager get localAppSettings =>
      $$LocalAppSettingsTableTableManager(_db, _db.localAppSettings);
}
