// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FitKarma';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get community => 'Community';

  @override
  String get profile => 'Profile';

  @override
  String get food => 'Food';

  @override
  String get workouts => 'Workouts';

  @override
  String karmaPoints(int count) {
    return '$count Karma Points';
  }

  @override
  String get waterIntake => 'Water Intake';

  @override
  String get steps => 'Steps';

  @override
  String get calories => 'Calories';

  @override
  String get trackWalk => 'Track Walk';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get ayurvedicDoshaQuiz => 'Ayurvedic Dosha Quiz';

  @override
  String get festivalCalendar => 'Festival Calendar';

  @override
  String get language => 'Language';

  @override
  String get hindi => 'Hindi';

  @override
  String get english => 'English';

  @override
  String get logout => 'Logout';

  @override
  String get whatThisMeans => 'What this means';

  @override
  String get bestFoods => 'Best Foods for You';

  @override
  String get workoutAdvice => 'Workout Advice';
}
