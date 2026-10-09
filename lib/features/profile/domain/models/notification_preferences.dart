/// User notification and cadence preferences.
class NotificationPreferences {
  final bool dailyDIPDigest;
  final bool mealReminders;
  final bool hydrationReminders;
  final bool fastingReminders;
  final bool workoutReminders;
  final bool weeklySummary;

  const NotificationPreferences({
    this.dailyDIPDigest = true,
    this.mealReminders = true,
    this.hydrationReminders = true,
    this.fastingReminders = true,
    this.workoutReminders = true,
    this.weeklySummary = true,
  });

  static const NotificationPreferences defaults = NotificationPreferences();

  NotificationPreferences copyWith({
    bool? dailyDIPDigest,
    bool? mealReminders,
    bool? hydrationReminders,
    bool? fastingReminders,
    bool? workoutReminders,
    bool? weeklySummary,
  }) {
    return NotificationPreferences(
      dailyDIPDigest: dailyDIPDigest ?? this.dailyDIPDigest,
      mealReminders: mealReminders ?? this.mealReminders,
      hydrationReminders: hydrationReminders ?? this.hydrationReminders,
      fastingReminders: fastingReminders ?? this.fastingReminders,
      workoutReminders: workoutReminders ?? this.workoutReminders,
      weeklySummary: weeklySummary ?? this.weeklySummary,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_dip_digest': dailyDIPDigest,
      'meal_reminders': mealReminders,
      'hydration_reminders': hydrationReminders,
      'fasting_reminders': fastingReminders,
      'workout_reminders': workoutReminders,
      'weekly_summary': weeklySummary,
    };
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      dailyDIPDigest: json['daily_dip_digest'] as bool? ?? true,
      mealReminders: json['meal_reminders'] as bool? ?? true,
      hydrationReminders: json['hydration_reminders'] as bool? ?? true,
      fastingReminders: json['fasting_reminders'] as bool? ?? true,
      workoutReminders: json['workout_reminders'] as bool? ?? true,
      weeklySummary: json['weekly_summary'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferences &&
          runtimeType == other.runtimeType &&
          dailyDIPDigest == other.dailyDIPDigest &&
          mealReminders == other.mealReminders &&
          hydrationReminders == other.hydrationReminders &&
          fastingReminders == other.fastingReminders &&
          workoutReminders == other.workoutReminders &&
          weeklySummary == other.weeklySummary;

  @override
  int get hashCode => Object.hash(
    dailyDIPDigest,
    mealReminders,
    hydrationReminders,
    fastingReminders,
    workoutReminders,
    weeklySummary,
  );
}
