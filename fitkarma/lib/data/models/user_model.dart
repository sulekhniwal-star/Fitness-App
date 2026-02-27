import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String? phone;

  @HiveField(3)
  final String name;

  @HiveField(4)
  final DateTime? dob;

  @HiveField(5)
  final String? gender;

  @HiveField(6)
  final double? heightCm;

  @HiveField(7)
  final double? weightKg;

  @HiveField(8)
  final String? dosha;

  @HiveField(9)
  final String? preferredLanguage;

  @HiveField(10)
  final String subscriptionTier;

  @HiveField(11)
  final int karmaPoints;

  @HiveField(12)
  final int streakDays;

  @HiveField(13)
  final DateTime? lastLoginDate;

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final DateTime updatedAt;

  @HiveField(16)
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.email,
    this.phone,
    required this.name,
    this.dob,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.dosha,
    this.preferredLanguage,
    this.subscriptionTier = 'free',
    this.karmaPoints = 0,
    this.streakDays = 0,
    this.lastLoginDate,
    required this.createdAt,
    required this.updatedAt,
    this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // PocketBase returns 'created'/'updated'; local Hive cache may use 'created_at'/'updated_at'
    final createdRaw = (json['created'] ?? json['created_at']) as String?;
    final updatedRaw = (json['updated'] ?? json['updated_at']) as String?;
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      name: json['name'] as String? ?? json['email'] as String,
      dob: json['dob'] != null ? DateTime.parse(json['dob'] as String) : null,
      gender: json['gender'] as String?,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      dosha: json['dosha'] as String?,
      preferredLanguage: json['preferred_language'] as String?,
      subscriptionTier: json['subscription_tier'] as String? ?? 'free',
      karmaPoints: json['karma_points'] as int? ?? 0,
      streakDays: json['streak_days'] as int? ?? 0,
      lastLoginDate: json['last_login_date'] != null
          ? DateTime.parse(json['last_login_date'] as String)
          : null,
      createdAt: createdRaw != null ? DateTime.parse(createdRaw) : DateTime.now(),
      updatedAt: updatedRaw != null ? DateTime.parse(updatedRaw) : DateTime.now(),
      profileImageUrl: json['profile_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'dob': dob?.toIso8601String(),
      'gender': gender,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'dosha': dosha,
      'preferred_language': preferredLanguage,
      'subscription_tier': subscriptionTier,
      'karma_points': karmaPoints,
      'streak_days': streakDays,
      'last_login_date': lastLoginDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'profile_image_url': profileImageUrl,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? name,
    DateTime? dob,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? dosha,
    String? preferredLanguage,
    String? subscriptionTier,
    int? karmaPoints,
    int? streakDays,
    DateTime? lastLoginDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      dosha: dosha ?? this.dosha,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      karmaPoints: karmaPoints ?? this.karmaPoints,
      streakDays: streakDays ?? this.streakDays,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  double? get bmi {
    if (heightCm == null || weightKg == null || heightCm! <= 0) return null;
    final heightM = heightCm! / 100;
    return weightKg! / (heightM * heightM);
  }

  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }
}
