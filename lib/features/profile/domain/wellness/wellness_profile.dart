import 'package:fitkarma/features/profile/domain/models/profile_enums.dart';
import 'package:fitkarma/features/profile/domain/wellness/dosha_score.dart';
import 'package:fitkarma/features/profile/domain/wellness/wellness_recommendation.dart';

/// Represents a user's calculated Ayurvedic wellness and Prakriti profile.
///
/// NOTE: This entity belongs strictly to the holistic/traditional wellness layer,
/// completely decoupled from clinical health measurements (BMR, TDEE, BMI,
/// medication, vitals) per ADR-011 and Brain/pdr.md.
class WellnessProfile {
  final String id;
  final String userId;
  final AyurvedicDosha dominantDosha;
  final AyurvedicDosha? secondaryDosha;
  final DoshaScore score;
  final Map<String, String> rawAnswers;
  final List<WellnessRecommendation> recommendations;
  final bool isCompleted;
  final bool isSkipped;
  final DateTime? completedAt;
  final DateTime updatedAt;

  /// Prominent non-medical disclaimer string required across all consumer surfaces.
  static const String nonMedicalDisclaimer =
      'FitKarma Ayurvedic insights provide traditional lifestyle, dietary quality, '
      'and daily routine self-reflection suggestions. They are NOT clinical diagnoses, '
      'medical treatments, or healthcare advice. Always consult a licensed physician '
      'for any medical or nutritional concerns.';

  const WellnessProfile({
    required this.id,
    required this.userId,
    required this.dominantDosha,
    this.secondaryDosha,
    required this.score,
    required this.rawAnswers,
    required this.recommendations,
    required this.isCompleted,
    required this.isSkipped,
    this.completedAt,
    required this.updatedAt,
  });

  /// Factory for creating an initial, uncompleted, or skipped wellness profile.
  factory WellnessProfile.initial({
    required String userId,
    bool isSkipped = false,
  }) {
    return WellnessProfile(
      id: 'wp_$userId',
      userId: userId,
      dominantDosha: AyurvedicDosha.unknown,
      secondaryDosha: null,
      score: DoshaScore.empty(),
      rawAnswers: const {},
      recommendations: const [],
      isCompleted: false,
      isSkipped: isSkipped,
      completedAt: null,
      updatedAt: DateTime.now(),
    );
  }

  WellnessProfile copyWith({
    String? id,
    String? userId,
    AyurvedicDosha? dominantDosha,
    AyurvedicDosha? secondaryDosha,
    DoshaScore? score,
    Map<String, String>? rawAnswers,
    List<WellnessRecommendation>? recommendations,
    bool? isCompleted,
    bool? isSkipped,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return WellnessProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dominantDosha: dominantDosha ?? this.dominantDosha,
      secondaryDosha: secondaryDosha ?? this.secondaryDosha,
      score: score ?? this.score,
      rawAnswers: rawAnswers ?? this.rawAnswers,
      recommendations: recommendations ?? this.recommendations,
      isCompleted: isCompleted ?? this.isCompleted,
      isSkipped: isSkipped ?? this.isSkipped,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'dominant_dosha': dominantDosha.name,
        'secondary_dosha': secondaryDosha?.name,
        'score': score.toJson(),
        'raw_answers': rawAnswers,
        'recommendations': recommendations.map((r) => r.toJson()).toList(),
        'is_completed': isCompleted,
        'is_skipped': isSkipped,
        'completed_at': completedAt?.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'disclaimer': nonMedicalDisclaimer,
      };

  factory WellnessProfile.fromJson(Map<String, dynamic> json) =>
      WellnessProfile(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        dominantDosha: AyurvedicDosha.values.firstWhere(
          (e) => e.name == json['dominant_dosha'],
          orElse: () => AyurvedicDosha.unknown,
        ),
        secondaryDosha: json['secondary_dosha'] != null
            ? AyurvedicDosha.values.firstWhere(
                (e) => e.name == json['secondary_dosha'],
                orElse: () => AyurvedicDosha.unknown,
              )
            : null,
        score: json['score'] != null
            ? DoshaScore.fromJson(json['score'] as Map<String, dynamic>)
            : DoshaScore.empty(),
        rawAnswers: (json['raw_answers'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v.toString()),
            ) ??
            const {},
        recommendations: (json['recommendations'] as List<dynamic>?)
                ?.map((e) =>
                    WellnessRecommendation.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        isCompleted: json['is_completed'] as bool? ?? false,
        isSkipped: json['is_skipped'] as bool? ?? false,
        completedAt: json['completed_at'] != null
            ? DateTime.tryParse(json['completed_at'] as String)
            : null,
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
            DateTime.now(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WellnessProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          dominantDosha == other.dominantDosha &&
          secondaryDosha == other.secondaryDosha &&
          score == other.score &&
          isCompleted == other.isCompleted &&
          isSkipped == other.isSkipped;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        dominantDosha,
        secondaryDosha,
        score,
        isCompleted,
        isSkipped,
      );
}
