enum DoshaType { vata, pitta, kapha }

class DoshaQuestion {
  final String id;
  final String question;
  final Map<DoshaType, String> options;

  const DoshaQuestion({
    required this.id,
    required this.question,
    required this.options,
  });
}

class DoshaResult {
  final DoshaType dominantDosha;
  final Map<DoshaType, int> scores;
  final Map<DoshaType, double> percentages;

  DoshaResult({
    required this.dominantDosha,
    required this.scores,
    required this.percentages,
  });
}

class DoshaRepository {
  static const List<DoshaQuestion> questions = [
    DoshaQuestion(
      id: 'body_frame',
      question: 'How would you describe your body frame?',
      options: {
        DoshaType.vata: 'Thin, bony, and small-framed (hard to gain weight)',
        DoshaType.pitta: 'Medium-built and muscular (stable weight)',
        DoshaType.kapha:
            'Large-framed and broad-shouldered (easy to gain weight)',
      },
    ),
    DoshaQuestion(
      id: 'skin_texture',
      question: 'What is your skin texture normally like?',
      options: {
        DoshaType.vata: 'Dry, rough, and thin; easily gets cold',
        DoshaType.pitta: 'Soft, warm, and oily; may have reddish tint',
        DoshaType.kapha: 'Thick, cool, and moist; very soft and smooth',
      },
    ),
    DoshaQuestion(
      id: 'appetite',
      question: 'What best describes your appetite and digestion?',
      options: {
        DoshaType.vata:
            'Irregular; I often forget to eat or have variable hunger',
        DoshaType.pitta: 'Strong; I get irritable if I skip a meal',
        DoshaType.kapha:
            'Steady; I have slow digestion and can easily skip meals',
      },
    ),
    DoshaQuestion(
      id: 'sleep',
      question: 'How do you usually sleep?',
      options: {
        DoshaType.vata: 'Light sleeper; often interrupted or prone to insomnia',
        DoshaType.pitta: 'Moderate but sound sleeper; I wake up feeling alert',
        DoshaType.kapha:
            'Heavy sleeper; I love sleeping and feel groggy if I wake early',
      },
    ),
    DoshaQuestion(
      id: 'mental_state',
      question: 'How would you describe your mental state under stress?',
      options: {
        DoshaType.vata: 'Anxious, worried, and prone to overthinking',
        DoshaType.pitta: 'Irritable, angry, and competitive',
        DoshaType.kapha: 'Withdrawn, calm, and slow to react',
      },
    ),
    // ... adding more to reach 15 as per SPEC
    DoshaQuestion(
      id: 'hair',
      question: 'Describe your hair type:',
      options: {
        DoshaType.vata: 'Dry, brittle, curly or frizzy',
        DoshaType.pitta: 'Fine, soft, oily, or early graying/thinning',
        DoshaType.kapha: 'Thick, abundant, oily, and lustrous',
      },
    ),
    DoshaQuestion(
      id: 'weather_pref',
      question: 'How do you react to different weather conditions?',
      options: {
        DoshaType.vata: 'I dislike cold and wind; I love warm sunlight',
        DoshaType.pitta: 'I dislike intense heat; I love cool environments',
        DoshaType.kapha: 'I dislike damp, cold weather; I prefer dry warmth',
      },
    ),
    DoshaQuestion(
      id: 'activity',
      question: 'How do you prefer to stay active?',
      options: {
        DoshaType.vata: 'I am always on the go; I have bursts of energy',
        DoshaType.pitta: 'I love intense, goal-oriented workouts',
        DoshaType.kapha: 'I prefer steady, slow-paced activities',
      },
    ),
    DoshaQuestion(
      id: 'speech',
      question: 'What is your speaking style?',
      options: {
        DoshaType.vata: 'Quick, talkative, and sometimes scattered',
        DoshaType.pitta: 'Sharp, decisive, and loud/clear',
        DoshaType.kapha: 'Slow, melodious, and thoughtful',
      },
    ),
    DoshaQuestion(
      id: 'memory',
      question: 'How is your memory?',
      options: {
        DoshaType.vata: 'Learns quickly but forgets quickly',
        DoshaType.pitta:
            'Learns and understands moderately and remembers long-term',
        DoshaType.kapha: 'Learns slowly but never forgets',
      },
    ),
    DoshaQuestion(
      id: 'emotions',
      question: 'What is your dominant positive emotion?',
      options: {
        DoshaType.vata: 'Enthusiasm and creativity',
        DoshaType.pitta: 'Focus and courage',
        DoshaType.kapha: 'Calmness and compassion',
      },
    ),
    DoshaQuestion(
      id: 'joints',
      question: 'Describe your joints:',
      options: {
        DoshaType.vata: 'Prominent, crack easily, and thin',
        DoshaType.pitta: 'Medium-sized and flexible',
        DoshaType.kapha: 'Broad, well-cushioned, and stable',
      },
    ),
    DoshaQuestion(
      id: 'stools',
      question: 'What are your elimination habits like?',
      options: {
        DoshaType.vata: 'Prone to constipation; hard or irregular',
        DoshaType.pitta: 'Soft, regular, and sometimes oily/loose',
        DoshaType.kapha: 'Steady, heavy, and slow but regular',
      },
    ),
    DoshaQuestion(
      id: 'dreams',
      question: 'What do you often dream about?',
      options: {
        DoshaType.vata: 'Flying, running, or feeling fearful',
        DoshaType.pitta: 'Fire, conflict, or goal-oriented tasks',
        DoshaType.kapha: 'Water, clouds, or peaceful romantic scenes',
      },
    ),
    DoshaQuestion(
      id: 'social',
      question: 'How do you behave in social situations?',
      options: {
        DoshaType.vata: 'Talkative and enjoys meeting new people',
        DoshaType.pitta: 'Likely to take charge of the conversation',
        DoshaType.kapha: 'Listens more, calm and nurturing presence',
      },
    ),
  ];

  static DoshaResult calculateResult(Map<String, DoshaType> answers) {
    final scores = {
      DoshaType.vata: 0,
      DoshaType.pitta: 0,
      DoshaType.kapha: 0,
    };

    for (final type in answers.values) {
      scores[type] = scores[type]! + 1;
    }

    final total = answers.length;
    final percentages = {
      DoshaType.vata: (scores[DoshaType.vata]! / total) * 100,
      DoshaType.pitta: (scores[DoshaType.pitta]! / total) * 100,
      DoshaType.kapha: (scores[DoshaType.kapha]! / total) * 100,
    };

    DoshaType dominant = DoshaType.vata;
    if (scores[DoshaType.pitta]! > scores[dominant]!) {
      dominant = DoshaType.pitta;
    }
    if (scores[DoshaType.kapha]! > scores[dominant]!) {
      dominant = DoshaType.kapha;
    }

    return DoshaResult(
      dominantDosha: dominant,
      scores: scores,
      percentages: percentages,
    );
  }
}
