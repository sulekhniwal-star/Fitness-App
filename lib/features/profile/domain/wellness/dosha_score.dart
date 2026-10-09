import 'package:fitkarma/features/profile/domain/models/profile_enums.dart';

/// Represents the calculated statistical and constitutional breakdown of
/// an Ayurvedic Prakriti assessment.
///
/// NOTE: Non-medical wellness classification per ADR-011 and Brain/pdr.md.
class DoshaScore {
  final int vataPoints;
  final int pittaPoints;
  final int kaphaPoints;
  final int totalQuestions;
  final int answeredQuestions;
  final double vataPercentage;
  final double pittaPercentage;
  final double kaphaPercentage;
  final AyurvedicDosha dominantDosha;
  final AyurvedicDosha? secondaryDosha;
  final bool isTridoshic;
  final bool isDualDosha;

  const DoshaScore({
    required this.vataPoints,
    required this.pittaPoints,
    required this.kaphaPoints,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.vataPercentage,
    required this.pittaPercentage,
    required this.kaphaPercentage,
    required this.dominantDosha,
    this.secondaryDosha,
    required this.isTridoshic,
    required this.isDualDosha,
  });

  /// Factory for an unassessed or skipped score state.
  factory DoshaScore.empty({int totalQuestions = 7}) {
    return DoshaScore(
      vataPoints: 0,
      pittaPoints: 0,
      kaphaPoints: 0,
      totalQuestions: totalQuestions,
      answeredQuestions: 0,
      vataPercentage: 0.0,
      pittaPercentage: 0.0,
      kaphaPercentage: 0.0,
      dominantDosha: AyurvedicDosha.unknown,
      secondaryDosha: null,
      isTridoshic: false,
      isDualDosha: false,
    );
  }

  Map<String, dynamic> toJson() => {
        'vata_points': vataPoints,
        'pitta_points': pittaPoints,
        'kapha_points': kaphaPoints,
        'total_questions': totalQuestions,
        'answered_questions': answeredQuestions,
        'vata_percentage': vataPercentage,
        'pitta_percentage': pittaPercentage,
        'kapha_percentage': kaphaPercentage,
        'dominant_dosha': dominantDosha.name,
        'secondary_dosha': secondaryDosha?.name,
        'is_tridoshic': isTridoshic,
        'is_dual_dosha': isDualDosha,
      };

  factory DoshaScore.fromJson(Map<String, dynamic> json) => DoshaScore(
        vataPoints: json['vata_points'] as int? ?? 0,
        pittaPoints: json['pitta_points'] as int? ?? 0,
        kaphaPoints: json['kapha_points'] as int? ?? 0,
        totalQuestions: json['total_questions'] as int? ?? 7,
        answeredQuestions: json['answered_questions'] as int? ?? 0,
        vataPercentage: (json['vata_percentage'] as num?)?.toDouble() ?? 0.0,
        pittaPercentage: (json['pitta_percentage'] as num?)?.toDouble() ?? 0.0,
        kaphaPercentage: (json['kapha_percentage'] as num?)?.toDouble() ?? 0.0,
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
        isTridoshic: json['is_tridoshic'] as bool? ?? false,
        isDualDosha: json['is_dual_dosha'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoshaScore &&
          runtimeType == other.runtimeType &&
          vataPoints == other.vataPoints &&
          pittaPoints == other.pittaPoints &&
          kaphaPoints == other.kaphaPoints &&
          totalQuestions == other.totalQuestions &&
          answeredQuestions == other.answeredQuestions &&
          dominantDosha == other.dominantDosha &&
          secondaryDosha == other.secondaryDosha &&
          isTridoshic == other.isTridoshic &&
          isDualDosha == other.isDualDosha;

  @override
  int get hashCode => Object.hash(
        vataPoints,
        pittaPoints,
        kaphaPoints,
        totalQuestions,
        answeredQuestions,
        dominantDosha,
        secondaryDosha,
        isTridoshic,
        isDualDosha,
      );
}
