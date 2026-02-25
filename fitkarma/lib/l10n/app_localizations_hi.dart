// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'फिटकर्मा';

  @override
  String get dashboard => 'डैशबोर्ड';

  @override
  String get community => 'कम्युनिटी';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get food => 'आहार';

  @override
  String get workouts => 'वर्कआउट';

  @override
  String karmaPoints(int count) {
    return '$count कर्मा पॉइंट्स';
  }

  @override
  String get waterIntake => 'पानी का सेवन';

  @override
  String get steps => 'कदम';

  @override
  String get calories => 'कैलोरी';

  @override
  String get trackWalk => 'सैर ट्रैक करें';

  @override
  String get upgradeToPremium => 'प्रीमियम में अपग्रेड करें';

  @override
  String get ayurvedicDoshaQuiz => 'आयुर्वेदिक दोष क्विज़';

  @override
  String get festivalCalendar => 'त्योहार कैलेंडर';

  @override
  String get language => 'भाषा';

  @override
  String get hindi => 'हिंदी';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get whatThisMeans => 'इसका क्या मतलब है';

  @override
  String get bestFoods => 'आपके लिए सबसे अच्छा भोजन';

  @override
  String get workoutAdvice => 'वर्कआउट सलाह';
}
