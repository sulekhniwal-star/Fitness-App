import 'package:fitkarma/features/profile/domain/models/profile_enums.dart';
import 'package:fitkarma/features/profile/domain/models/user_profile.dart';
import 'package:fitkarma/features/profile/domain/wellness/dosha_question.dart';
import 'package:fitkarma/features/profile/domain/wellness/dosha_score.dart';
import 'package:fitkarma/features/profile/domain/wellness/wellness_profile.dart';
import 'package:fitkarma/features/profile/domain/wellness/wellness_recommendation.dart';

/// Testable domain service encapsulating deterministic scoring rules and
/// non-medical lifestyle guidance for the Ayurvedic wellness personalization layer.
///
/// NOTE: Strictly decoupled from clinical and evidence-based measurements
/// (BMR, TDEE, BMI, weight, vitals) per ADR-011 and Brain/pdr.md.
class DoshaWellnessService {
  final List<DoshaQuestion> questions;

  const DoshaWellnessService({
    this.questions = DoshaQuestion.standardQuestions,
  });

  /// Deterministically calculates the statistical DoshaScore from a map of
  /// answered questions (`questionId` -> `AyurvedicDosha`).
  DoshaScore calculateScore({
    required Map<String, AyurvedicDosha> answers,
    int? totalQuestions,
  }) {
    final total = totalQuestions ?? questions.length;
    final answered = answers.length;

    if (answered == 0) {
      return DoshaScore.empty(totalQuestions: total);
    }

    int vataPoints = 0;
    int pittaPoints = 0;
    int kaphaPoints = 0;

    for (final dosha in answers.values) {
      switch (dosha) {
        case AyurvedicDosha.vata:
          vataPoints++;
          break;
        case AyurvedicDosha.pitta:
          pittaPoints++;
          break;
        case AyurvedicDosha.kapha:
          kaphaPoints++;
          break;
        case AyurvedicDosha.tridoshic:
          // In rare questions offering a balanced option, increment all equally
          vataPoints++;
          pittaPoints++;
          kaphaPoints++;
          break;
        case AyurvedicDosha.unknown:
          break;
      }
    }

    final double totalPoints = (vataPoints + pittaPoints + kaphaPoints).toDouble();
    if (totalPoints == 0.0) {
      return DoshaScore.empty(totalQuestions: total);
    }

    final vataPct = vataPoints / totalPoints;
    final pittaPct = pittaPoints / totalPoints;
    final kaphaPct = kaphaPoints / totalPoints;

    final pcts = [
      (dosha: AyurvedicDosha.vata, pct: vataPct, points: vataPoints),
      (dosha: AyurvedicDosha.pitta, pct: pittaPct, points: pittaPoints),
      (dosha: AyurvedicDosha.kapha, pct: kaphaPct, points: kaphaPoints),
    ];

    // Find maximum and minimum percentages
    final maxPct = [vataPct, pittaPct, kaphaPct].reduce((a, b) => a > b ? a : b);
    final minPct = [vataPct, pittaPct, kaphaPct].reduce((a, b) => a < b ? a : b);

    // Rule 1: Tridoshic / Balanced Constitution
    // When all three doshas are within a narrow margin (<= 15% range)
    // or all three percentages fall between 25% and 40%.
    final bool isBalancedRange = (maxPct - minPct) <= 0.15;
    final bool isAllMidRange =
        vataPct >= 0.25 && vataPct <= 0.40 &&
        pittaPct >= 0.25 && pittaPct <= 0.40 &&
        kaphaPct >= 0.25 && kaphaPct <= 0.40;

    if (isBalancedRange || isAllMidRange) {
      return DoshaScore(
        vataPoints: vataPoints,
        pittaPoints: pittaPoints,
        kaphaPoints: kaphaPoints,
        totalQuestions: total,
        answeredQuestions: answered,
        vataPercentage: vataPct,
        pittaPercentage: pittaPct,
        kaphaPercentage: kaphaPct,
        dominantDosha: AyurvedicDosha.tridoshic,
        secondaryDosha: null,
        isTridoshic: true,
        isDualDosha: false,
      );
    }

    // Sort descending by percentage, using traditional priority (Vata -> Pitta -> Kapha)
    // as deterministic tie-breaker
    final sorted = List.of(pcts)..sort((a, b) {
      final cmp = b.pct.compareTo(a.pct);
      if (cmp != 0) return cmp;
      return a.dosha.index.compareTo(b.dosha.index);
    });

    final primary = sorted[0];
    final secondary = sorted[1];

    // Rule 2: Single Dominant vs Dual-Dosha
    // If primary exceeds secondary by > 15%, it is a single dominant constitution.
    // If the top two are within 15%, it is classified as a dual-dosha constitution.
    final bool isDual = (primary.pct - secondary.pct) <= 0.15;

    return DoshaScore(
      vataPoints: vataPoints,
      pittaPoints: pittaPoints,
      kaphaPoints: kaphaPoints,
      totalQuestions: total,
      answeredQuestions: answered,
      vataPercentage: vataPct,
      pittaPercentage: pittaPct,
      kaphaPercentage: kaphaPct,
      dominantDosha: primary.dosha,
      secondaryDosha: isDual ? secondary.dosha : null,
      isTridoshic: false,
      isDualDosha: isDual,
    );
  }

  /// Builds a complete [WellnessProfile] from raw option selections (`questionId` -> `optionId`).
  WellnessProfile buildProfile({
    required String userId,
    required Map<String, String> rawAnswers,
    bool isSkipped = false,
  }) {
    if (isSkipped || rawAnswers.isEmpty) {
      return WellnessProfile.initial(userId: userId, isSkipped: isSkipped);
    }

    // Resolve each optionId to its corresponding AyurvedicDosha
    final Map<String, AyurvedicDosha> resolvedAnswers = {};
    for (final entry in rawAnswers.entries) {
      final questionId = entry.key;
      final optionId = entry.value;

      final question = questions.cast<DoshaQuestion?>().firstWhere(
            (q) => q?.id == questionId,
            orElse: () => null,
          );
      if (question != null) {
        final option = question.options.cast<DoshaQuestionOption?>().firstWhere(
              (o) => o?.id == optionId,
              orElse: () => null,
            );
        if (option != null) {
          resolvedAnswers[questionId] = option.dosha;
        }
      }
    }

    final score = calculateScore(answers: resolvedAnswers);
    final recommendations = generateRecommendations(
      dominantDosha: score.dominantDosha,
      secondaryDosha: score.secondaryDosha,
      isTridoshic: score.isTridoshic,
    );

    return WellnessProfile(
      id: 'wp_$userId',
      userId: userId,
      dominantDosha: score.dominantDosha,
      secondaryDosha: score.secondaryDosha,
      score: score,
      rawAnswers: rawAnswers,
      recommendations: recommendations,
      isCompleted: resolvedAnswers.isNotEmpty,
      isSkipped: false,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Curates traditional non-medical lifestyle and routine guidance.
  List<WellnessRecommendation> generateRecommendations({
    required AyurvedicDosha dominantDosha,
    AyurvedicDosha? secondaryDosha,
    bool isTridoshic = false,
  }) {
    final List<WellnessRecommendation> list = [];

    if (isTridoshic || dominantDosha == AyurvedicDosha.tridoshic) {
      list.addAll(const [
        WellnessRecommendation(
          id: 'rec_tridoshic_season',
          category: 'Seasonal Adaptation (Ritucharya)',
          title: 'Seasonal Harmonization',
          description:
              'Adjust your routine with the seasons: favor cooling foods in summer, warming stews in winter, and lighter meals during spring.',
          iconName: 'wb_sunny',
        ),
        WellnessRecommendation(
          id: 'rec_tridoshic_rhythm',
          category: 'Daily Routine (Dinacharya)',
          title: 'Consistent Daily Rhythm',
          description:
              'Maintain regular waking, eating, and sleeping hours to preserve your natural constitutional equilibrium.',
          iconName: 'schedule',
        ),
        WellnessRecommendation(
          id: 'rec_tridoshic_balance',
          category: 'Nutritional Quality (Shad Rasa)',
          title: 'Diverse Flavor Palette',
          description:
              'Incorporate all six Ayurvedic tastes (sweet, sour, salty, pungent, bitter, astringent) in balanced proportions across your daily meals.',
          iconName: 'restaurant',
        ),
      ]);
      return list;
    }

    // Add recommendations for primary dosha
    list.addAll(_getDoshaSpecificRecommendations(dominantDosha));

    // If dual-dosha, add secondary balancing recommendation
    if (secondaryDosha != null && secondaryDosha != dominantDosha) {
      final secondaryRecs = _getDoshaSpecificRecommendations(secondaryDosha);
      if (secondaryRecs.isNotEmpty) {
        list.add(secondaryRecs.first);
      }
    }

    return list;
  }

  List<WellnessRecommendation> _getDoshaSpecificRecommendations(
    AyurvedicDosha dosha,
  ) {
    switch (dosha) {
      case AyurvedicDosha.vata:
        return const [
          WellnessRecommendation(
            id: 'rec_vata_food',
            category: 'Dietary Qualities (Gunas)',
            title: 'Warm & Grounding Nutrition',
            description:
                'Favor warm, well-cooked, hydrating meals like khichdi, dals, soups, and healthy fats (ghee, sesame oil). Minimize dry, cold snacks.',
            iconName: 'soup_kitchen',
          ),
          WellnessRecommendation(
            id: 'rec_vata_routine',
            category: 'Daily Routine',
            title: 'Grounding Evening Routine',
            description:
                'Aim for sleep before 10:30 PM. Warm foot baths, calming herbal teas, and reduced screen exposure promote restorative rest.',
            iconName: 'nightlight_round',
          ),
          WellnessRecommendation(
            id: 'rec_vata_movement',
            category: 'Movement & Mindfulness',
            title: 'Gentle, Rhythmic Exercise',
            description:
                'Focus on steady, mindful movement such as grounding yoga, calm walks in nature, and slow diaphragmatic breathing.',
            iconName: 'self_improvement',
          ),
        ];

      case AyurvedicDosha.pitta:
        return const [
          WellnessRecommendation(
            id: 'rec_pitta_food',
            category: 'Dietary Qualities (Gunas)',
            title: 'Cooling & Nourishing Foods',
            description:
                'Favor naturally sweet, cooling, and bitter flavors (coconut water, coriander, mint, cucumbers, leafy greens). Avoid excessive chili heat and fried items.',
            iconName: 'ac_unit',
          ),
          WellnessRecommendation(
            id: 'rec_pitta_pace',
            category: 'Daily Routine',
            title: 'Midday Heat Moderation',
            description:
                'Avoid strenuous outdoor activity during the peak noon heat. Balance intense productivity with scheduled mental pauses.',
            iconName: 'timer',
          ),
          WellnessRecommendation(
            id: 'rec_pitta_movement',
            category: 'Movement & Mindfulness',
            title: 'Cooling Physical Activities',
            description:
                'Engage in swimming, evening nature walks under moonlight, and Sheetali cooling breathwork to moderate internal intensity.',
            iconName: 'pool',
          ),
        ];

      case AyurvedicDosha.kapha:
        return const [
          WellnessRecommendation(
            id: 'rec_kapha_food',
            category: 'Dietary Qualities (Gunas)',
            title: 'Light, Spiced & Stimulating Meals',
            description:
                'Favor warm, pungent, bitter, and astringent foods spiced with black pepper, ginger, and turmeric. Minimize heavy sweets and oily dishes.',
            iconName: 'local_fire_department',
          ),
          WellnessRecommendation(
            id: 'rec_kapha_routine',
            category: 'Daily Routine',
            title: 'Early Morning Rising',
            description:
                'Awaken before sunrise (around 6:00 AM) to dispel morning sluggishness. Avoid daytime naps to maintain vital alertness.',
            iconName: 'wb_twilight',
          ),
          WellnessRecommendation(
            id: 'rec_kapha_movement',
            category: 'Movement & Mindfulness',
            title: 'Vigorous Daily Movement',
            description:
                'Prioritize dynamic, energetic exercise such as brisk walking, Surya Namaskar, cycling, or strength circuits to elevate metabolic momentum.',
            iconName: 'directions_run',
          ),
        ];

      case AyurvedicDosha.tridoshic:
      case AyurvedicDosha.unknown:
        return const [];
    }
  }

  /// Explicit domain safeguard verifying that clinical and evidence-based
  /// metrics (BMR, TDEE, BMI, macro split) remain strictly independent of
  /// traditional Ayurvedic wellness scoring.
  static void verifyDecoupledFromClinicalCalculations({
    required UserProfile profile,
    required double expectedBmr,
    required double expectedTdee,
  }) {
    assert(
      (profile.calculateBmr() - expectedBmr).abs() < 0.001,
      'Clinical BMR calculation must NOT be altered by traditional wellness state.',
    );
    assert(
      (profile.calculateTdee() - expectedTdee).abs() < 0.001,
      'Clinical TDEE calculation must NOT be altered by traditional wellness state.',
    );
  }
}
