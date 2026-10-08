import 'package:fitkarma/core/localization/app_locale.dart';

/// Dialect and language modes for dynamic AI conversational generation.
///
/// Strictly decoupled from static UI localization string catalogs.
enum AiConversationalDialect {
  english(code: 'en', label: 'English'),
  hindi(code: 'hi', label: 'Hindi'),
  hinglish(code: 'hinglish', label: 'Hinglish (Conversational)'),
  tamil(code: 'ta', label: 'Tamil'),
  telugu(code: 'te', label: 'Telugu'),
  gujarati(code: 'gu', label: 'Gujarati'),
  bengali(code: 'bn', label: 'Bengali'),
  marathi(code: 'mr', label: 'Marathi'),
  punjabi(code: 'pa', label: 'Punjabi');

  final String code;
  final String label;

  const AiConversationalDialect({required this.code, required this.label});

  static AiConversationalDialect fromAppLocale(AppSupportedLocale locale) {
    switch (locale) {
      case AppSupportedLocale.hindi:
        return AiConversationalDialect
            .hinglish; // Default for Hindi users is natural Hinglish
      case AppSupportedLocale.tamil:
        return AiConversationalDialect.tamil;
      case AppSupportedLocale.telugu:
        return AiConversationalDialect.telugu;
      case AppSupportedLocale.gujarati:
        return AiConversationalDialect.gujarati;
      case AppSupportedLocale.bengali:
        return AiConversationalDialect.bengali;
      case AppSupportedLocale.marathi:
        return AiConversationalDialect.marathi;
      case AppSupportedLocale.punjabi:
        return AiConversationalDialect.punjabi;
      case AppSupportedLocale.english:
        return AiConversationalDialect.english;
    }
  }
}

/// Ratio of Hindi vernacular phrasing mixed into English responses for Hinglish mode.
enum HinglishMixRatio {
  /// ~15% Hindi terms (food items, greetings), primarily English grammar
  subtle(ratio: 0.15),

  /// ~45% Hindi conversational phrases, English metrics & structure (optimal default)
  balanced(ratio: 0.45),

  /// ~75% Hindi vernacular flow with English fitness/metric loanwords
  vernacularHeavy(ratio: 0.75);

  final double ratio;
  const HinglishMixRatio({required this.ratio});
}

/// Persona tone for AI coaching interactions.
enum AiCoachingTone {
  /// Respectful, empathetic, supportive elder ("Aap", encouraging)
  supportiveElder,

  /// Energetic, motivational gym buddy / peer ("Dost", actionable)
  peerBuddy,

  /// Evidence-based, clinical, structured, objective
  clinicalSpecialist,
}

/// Configuration governing how the multi-model AI generates conversational phrasing.
///
/// INVARIANT: Static UI strings must NEVER depend on this class. This class
/// solely instructs LLM system prompts and voice note transcription post-processors.
class AiPhrasingConfig {
  final AiConversationalDialect dialect;
  final HinglishMixRatio hinglishMixRatio;
  final AiCoachingTone tone;
  final bool respectFastingContext;
  final String? regionalDietaryContext; // e.g. "South Indian vegetarian", "Punjabi dairy-rich"

  const AiPhrasingConfig({
    this.dialect = AiConversationalDialect.hinglish,
    this.hinglishMixRatio = HinglishMixRatio.balanced,
    this.tone = AiCoachingTone.peerBuddy,
    this.respectFastingContext = true,
    this.regionalDietaryContext,
  });

  /// Generates LLM system prompt directives instructing the model how to phrase responses.
  String generatePromptDirectives() {
    final buffer = StringBuffer();
    buffer.writeln('### Language & Phrasing Directives:');

    switch (dialect) {
      case AiConversationalDialect.hinglish:
        buffer.writeln(
          '- Dialect: Natural Indian Hinglish (blend of conversational Hindi and English).',
        );
        buffer.writeln(
          '- Mixing ratio: ${(hinglishMixRatio.ratio * 100).toInt()}% Hindi idioms and vocabulary.',
        );
        buffer.writeln(
          '- Use natural Indian terms for food and cooking (e.g., "tadka", "ghar ka khana", "roti", "dal", "katori").',
        );
        break;
      case AiConversationalDialect.hindi:
        buffer.writeln('- Dialect: Pure Hindi in Devanagari script.');
        break;
      case AiConversationalDialect.tamil:
        buffer.writeln(
          '- Dialect: Tamil (conversational with clear nutritional guidance).',
        );
        break;
      case AiConversationalDialect.telugu:
        buffer.writeln(
          '- Dialect: Telugu (conversational with clear nutritional guidance).',
        );
        break;
      case AiConversationalDialect.gujarati:
        buffer.writeln(
          '- Dialect: Gujarati (conversational with clear nutritional guidance).',
        );
        break;
      case AiConversationalDialect.bengali:
        buffer.writeln(
          '- Dialect: Bengali (conversational with clear nutritional guidance).',
        );
        break;
      case AiConversationalDialect.marathi:
        buffer.writeln(
          '- Dialect: Marathi (conversational with clear nutritional guidance).',
        );
        break;
      case AiConversationalDialect.punjabi:
        buffer.writeln(
          '- Dialect: Punjabi (conversational with clear nutritional guidance).',
        );
        break;
      case AiConversationalDialect.english:
        buffer.writeln(
          '- Dialect: Clear, accessible English tailored for Indian users.',
        );
        break;
    }

    buffer.write('- Coaching Tone: ');
    switch (tone) {
      case AiCoachingTone.supportiveElder:
        buffer.writeln(
          'Respectful, empathetic, patient, encouraging ("Aap" orientation).',
        );
        break;
      case AiCoachingTone.peerBuddy:
        buffer.writeln(
          'Energetic, friendly, conversational peer ("Dost/Buddy").',
        );
        break;
      case AiCoachingTone.clinicalSpecialist:
        buffer.writeln('Objective, scientific, concise, data-driven.');
        break;
    }

    if (respectFastingContext) {
      buffer.writeln(
        '- Fasting Sensitivity: Never scold or prompt to eat during fasts; suggest safe hydration.',
      );
    }

    if (regionalDietaryContext != null) {
      buffer.writeln('- Regional Context: $regionalDietaryContext.');
    }

    return buffer.toString().trim();
  }

  AiPhrasingConfig copyWith({
    AiConversationalDialect? dialect,
    HinglishMixRatio? hinglishMixRatio,
    AiCoachingTone? tone,
    bool? respectFastingContext,
    String? regionalDietaryContext,
  }) {
    return AiPhrasingConfig(
      dialect: dialect ?? this.dialect,
      hinglishMixRatio: hinglishMixRatio ?? this.hinglishMixRatio,
      tone: tone ?? this.tone,
      respectFastingContext:
          respectFastingContext ?? this.respectFastingContext,
      regionalDietaryContext:
          regionalDietaryContext ?? this.regionalDietaryContext,
    );
  }
}
