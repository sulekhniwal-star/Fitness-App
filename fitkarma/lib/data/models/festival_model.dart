class Festival {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final double calorieMultiplier; // e.g., 1.2 for 20% more flexibility
  final String workoutSuggestion; // e.g., "Garba", "Bhangra"
  final Map<String, String>
      healthySwaps; // e.g., {"Ladoo": "Dates & Nuts Ladoo"}

  const Festival({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    this.calorieMultiplier = 1.0,
    this.workoutSuggestion = "Standard Workout",
    this.healthySwaps = const {},
  });
}

class FestivalRepository {
  static List<Festival> getFestivalsForYear(int year) {
    return [
      Festival(
        id: 'makar_sankranti',
        name: 'Makar Sankranti',
        description: 'Harvest festival celebrated across India.',
        date: DateTime(year, 1, 14),
        calorieMultiplier: 1.1,
        workoutSuggestion: 'Kite Flying (Active Arm & Neck movement)',
        healthySwaps: {'Til Gul Ladoo': 'Til Ladoo with Stevia/Jaggery limit'},
      ),
      Festival(
        id: 'republic_day',
        name: 'Republic Day',
        description: 'National festival of India.',
        date: DateTime(year, 1, 26),
        workoutSuggestion: 'Prabhat Pheri (Morning Walk)',
      ),
      Festival(
        id: 'holi',
        name: 'Holi',
        description: 'Festival of Colors.',
        date: DateTime(year, 3, 14), // Approx date for 2026
        calorieMultiplier: 1.25,
        workoutSuggestion: 'Playing with colors (High intensity cardio)',
        healthySwaps: {
          'Gujiya': 'Baked Gujiya',
          'Thandai': 'Thandai with Nut milk & minimal sugar'
        },
      ),
      Festival(
        id: 'ugadi',
        name: 'Ugadi / Gudi Padwa',
        description: 'Hindu New Year.',
        date: DateTime(year, 3, 19),
        calorieMultiplier: 1.15,
        healthySwaps: {'Puran Poli': 'Whole wheat Puran Poli with less Ghee'},
      ),
      Festival(
        id: 'eid_al_fitr',
        name: 'Eid-al-Fitr',
        description: 'End of Ramadan fasting.',
        date: DateTime(year, 3, 20), // Approx
        calorieMultiplier: 1.2,
        healthySwaps: {
          'Sheer Khurma': 'Sheer Khurma with Dates instead of sugar'
        },
      ),
      Festival(
        id: 'baisakhi',
        name: 'Baisakhi',
        description: 'Harvest festival of Punjab.',
        date: DateTime(year, 4, 14),
        calorieMultiplier: 1.2,
        workoutSuggestion: 'Bhangra Dance Session',
      ),
      Festival(
        id: 'independence_day',
        name: 'Independence Day',
        description: 'Celebrating freedom.',
        date: DateTime(year, 8, 15),
        workoutSuggestion: 'Community Walkathon',
      ),
      Festival(
        id: 'raksha_bandhan',
        name: 'Raksha Bandhan',
        description: 'Celebrating the bond between siblings.',
        date: DateTime(year, 8, 28),
        calorieMultiplier: 1.1,
        healthySwaps: {'Sweets': 'Fruit Platter or Dry Fruits'},
      ),
      Festival(
        id: 'janmashtami',
        name: 'Janmashtami',
        description: 'Birth of Lord Krishna.',
        date: DateTime(year, 9, 4),
        calorieMultiplier: 1.1,
        workoutSuggestion: 'Dahi Handi (Climbing and Core)',
      ),
      Festival(
        id: 'ganesh_chaturthi',
        name: 'Ganesh Chaturthi',
        description: 'Festival of Lord Ganesha.',
        date: DateTime(year, 9, 14),
        calorieMultiplier: 1.2,
        healthySwaps: {'Modak': 'Steamed Modak (Ukadiche Modak)'},
      ),
      Festival(
        id: 'navratri_start',
        name: 'Navratri Start',
        description: 'Nine nights of dance and devotion.',
        date: DateTime(year, 10, 12),
        calorieMultiplier: 1.15,
        workoutSuggestion: 'Garba / Dandiya (High Cardio)',
      ),
      Festival(
        id: 'dussehra',
        name: 'Dussehra',
        description: 'Victory of good over evil.',
        date: DateTime(year, 10, 21),
        calorieMultiplier: 1.15,
      ),
      Festival(
        id: 'diwali',
        name: 'Diwali',
        description: 'Festival of Lights.',
        date: DateTime(year, 11, 8),
        calorieMultiplier: 1.3,
        workoutSuggestion:
            'Full Body Cleanup (Functional Fitness) & Evening walk',
        healthySwaps: {
          'Fried Namkeen': 'Roasted Makhana/Nuts',
          'Sugar Sweets': 'Stevia based sandesh'
        },
      ),
    ];
  }
}
