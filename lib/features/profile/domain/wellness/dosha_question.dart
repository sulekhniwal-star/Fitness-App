import 'package:fitkarma/features/profile/domain/models/profile_enums.dart';

/// Represents a single option for an Ayurvedic Prakriti assessment question.
class DoshaQuestionOption {
  final String id;
  final AyurvedicDosha dosha;
  final String label;
  final String description;

  const DoshaQuestionOption({
    required this.id,
    required this.dosha,
    required this.label,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dosha': dosha.name,
        'label': label,
        'description': description,
      };

  factory DoshaQuestionOption.fromJson(Map<String, dynamic> json) =>
      DoshaQuestionOption(
        id: json['id'] as String,
        dosha: AyurvedicDosha.values.firstWhere(
          (e) => e.name == json['dosha'],
          orElse: () => AyurvedicDosha.unknown,
        ),
        label: json['label'] as String,
        description: json['description'] as String,
      );
}

/// Represents a single question in the Ayurvedic Prakriti self-reflection questionnaire.
///
/// NOTE: Strictly non-medical wellness & lifestyle self-reflection per ADR-011 and Brain/pdr.md.
class DoshaQuestion {
  final String id;
  final String title;
  final String category;
  final List<DoshaQuestionOption> options;

  const DoshaQuestion({
    required this.id,
    required this.title,
    required this.category,
    required this.options,
  });

  /// The standard 7-dimensional classical Prakriti self-reflection questionnaire.
  static const List<DoshaQuestion> standardQuestions = [
    DoshaQuestion(
      id: 'body_frame',
      title: 'Physical Frame & Skeletal Build',
      category: 'Physical Structure',
      options: [
        DoshaQuestionOption(
          id: 'body_frame_vata',
          dosha: AyurvedicDosha.vata,
          label: 'Slender & Light',
          description:
              'Narrow shoulders, slender limbs, prominent joints, tends toward lightness.',
        ),
        DoshaQuestionOption(
          id: 'body_frame_pitta',
          dosha: AyurvedicDosha.pitta,
          label: 'Medium & Athletic',
          description:
              'Balanced proportions, defined muscle tone, moderate bone structure.',
        ),
        DoshaQuestionOption(
          id: 'body_frame_kapha',
          dosha: AyurvedicDosha.kapha,
          label: 'Broad & Sturdy',
          description:
              'Solid bone structure, broad shoulders/hips, tends toward natural density.',
        ),
      ],
    ),
    DoshaQuestion(
      id: 'skin_tendency',
      title: 'Skin Quality & Temperature',
      category: 'Sensory Constitution',
      options: [
        DoshaQuestionOption(
          id: 'skin_vata',
          dosha: AyurvedicDosha.vata,
          label: 'Dry & Cool',
          description:
              'Prone to dryness or chapping; hands and feet often feel cool.',
        ),
        DoshaQuestionOption(
          id: 'skin_pitta',
          dosha: AyurvedicDosha.pitta,
          label: 'Warm & Sensitive',
          description:
              'Warm to touch, prone to flushing, sensitivity, or sunburn.',
        ),
        DoshaQuestionOption(
          id: 'skin_kapha',
          dosha: AyurvedicDosha.kapha,
          label: 'Smooth & Cool',
          description:
              'Thick, soft, naturally supple and well-hydrated skin.',
        ),
      ],
    ),
    DoshaQuestion(
      id: 'appetite_digestion',
      title: 'Appetite & Digestive Pattern (Agni)',
      category: 'Digestive Rhythm',
      options: [
        DoshaQuestionOption(
          id: 'appetite_vata',
          dosha: AyurvedicDosha.vata,
          label: 'Variable & Irregular',
          description:
              'Appetite fluctuates day to day; sometimes hungry, sometimes forgets meals.',
        ),
        DoshaQuestionOption(
          id: 'appetite_pitta',
          dosha: AyurvedicDosha.pitta,
          label: 'Strong & Sharp',
          description:
              'Very consistent intense hunger; becomes irritable or tired if meals are delayed.',
        ),
        DoshaQuestionOption(
          id: 'appetite_kapha',
          dosha: AyurvedicDosha.kapha,
          label: 'Steady & Moderate',
          description:
              'Can easily skip meals without irritability; digestion feels slow and heavy.',
        ),
      ],
    ),
    DoshaQuestion(
      id: 'energy_movement',
      title: 'Physical Energy & Movement Rhythm',
      category: 'Activity Rhythm',
      options: [
        DoshaQuestionOption(
          id: 'energy_vata',
          dosha: AyurvedicDosha.vata,
          label: 'Quick Bursts',
          description:
              'Spur-of-the-moment enthusiasm; rapid movement, but tires quickly.',
        ),
        DoshaQuestionOption(
          id: 'energy_pitta',
          dosha: AyurvedicDosha.pitta,
          label: 'Focused & Goal-Driven',
          description:
              'Intense concentration, competitive drive, disciplined physical endurance.',
        ),
        DoshaQuestionOption(
          id: 'energy_kapha',
          dosha: AyurvedicDosha.kapha,
          label: 'Steady & Methodical',
          description:
              'High stamina once started; prefers smooth, sustained, unhurried pacing.',
        ),
      ],
    ),
    DoshaQuestion(
      id: 'sleep_pattern',
      title: 'Sleep Tendencies & Dreams',
      category: 'Rest & Recovery',
      options: [
        DoshaQuestionOption(
          id: 'sleep_vata',
          dosha: AyurvedicDosha.vata,
          label: 'Light & Interrupted',
          description:
              'Awakens easily at slight noises; dreams often involve movement or wind.',
        ),
        DoshaQuestionOption(
          id: 'sleep_pitta',
          dosha: AyurvedicDosha.pitta,
          label: 'Moderate & Sound',
          description:
              'Sleeps 6-7 hours efficiently; wakes alert; dreams are vivid and purposeful.',
        ),
        DoshaQuestionOption(
          id: 'sleep_kapha',
          dosha: AyurvedicDosha.kapha,
          label: 'Deep & Heavy',
          description:
              'Sleeps deeply for 8+ hours; enjoys sleeping in; takes time to awaken fully.',
        ),
      ],
    ),
    DoshaQuestion(
      id: 'stress_response',
      title: 'Temperament Under Stress',
      category: 'Mental Balance',
      options: [
        DoshaQuestionOption(
          id: 'stress_vata',
          dosha: AyurvedicDosha.vata,
          label: 'Anxious & Overthinking',
          description:
              'Restless thoughts, worry, rapid verbal communication, quickly seeks change.',
        ),
        DoshaQuestionOption(
          id: 'stress_pitta',
          dosha: AyurvedicDosha.pitta,
          label: 'Impatient & Demanding',
          description:
              'Direct, critical, takes charge of situations, easily frustrated by delays.',
        ),
        DoshaQuestionOption(
          id: 'stress_kapha',
          dosha: AyurvedicDosha.kapha,
          label: 'Calm & Resistant',
          description:
              'Withdraws quietly, slow to anger, seeks comfort, resistant to abrupt disruptions.',
        ),
      ],
    ),
    DoshaQuestion(
      id: 'climate_affinity',
      title: 'Climate Preference & Weather Sensitivity',
      category: 'Environmental Harmony',
      options: [
        DoshaQuestionOption(
          id: 'climate_vata',
          dosha: AyurvedicDosha.vata,
          label: 'Loves Warmth, Dislikes Cold/Wind',
          description:
              'Uncomfortable in cold, windy, or arid climates; feels energized in warm sun.',
        ),
        DoshaQuestionOption(
          id: 'climate_pitta',
          dosha: AyurvedicDosha.pitta,
          label: 'Loves Cool Breezes, Dislikes Heat',
          description:
              'Overheats quickly; craves air conditioning, shade, and cool mountain weather.',
        ),
        DoshaQuestionOption(
          id: 'climate_kapha',
          dosha: AyurvedicDosha.kapha,
          label: 'Loves Dry Heat, Dislikes Damp Cold',
          description:
              'Feels heavy and congested in wet rainy seasons; thrives in dry, sunny conditions.',
        ),
      ],
    ),
  ];
}
