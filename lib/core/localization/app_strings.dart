/// Abstract contract for strongly-typed UI string catalogs in FitKarma.
///
/// UI localization is strictly decoupled from dynamic AI conversational phrasing.
abstract interface class AppStrings {
  // --- Common Actions ---
  String get start;
  String get save;
  String get cancel;
  String get retry;
  String get delete;
  String get continueAction;
  String get back;
  String get confirm;
  String get edit;

  // --- Top-Level Navigation Areas ---
  String get appTitle;
  String get dashboard;
  String get nutrition;
  String get workouts;
  String get sleep;
  String get recovery;
  String get aiCoach;
  String get family;
  String get subscriptions;
  String get settings;
  String get dataVault;
  String get onboarding;

  // --- Health Metrics & Goals ---
  String get steps;
  String get calories;
  String get water;
  String get protein;
  String get carbs;
  String get fats;
  String get dailyTarget;
  String get activeMinutes;

  // --- Status & Badges ---
  String get onTrack;
  String get fasting;
  String get verified;
  String get offline;
  String get karmaPro;
  String get syncPending;

  // --- Error & Empty States ---
  String get genericError;
  String get networkError;
  String get offlinePreserved;
  String get noWorkoutsToday;
  String get noMealsLogged;
}

/// English string catalog implementation (default source of truth).
class EnglishStrings implements AppStrings {
  const EnglishStrings();

  @override
  String get start => 'Start';
  @override
  String get save => 'Save';
  @override
  String get cancel => 'Cancel';
  @override
  String get retry => 'Try Again';
  @override
  String get delete => 'Delete';
  @override
  String get continueAction => 'Continue';
  @override
  String get back => 'Back';
  @override
  String get confirm => 'Confirm';
  @override
  String get edit => 'Edit';

  @override
  String get appTitle => 'FitKarma';
  @override
  String get dashboard => 'Dashboard';
  @override
  String get nutrition => 'Nutrition';
  @override
  String get workouts => 'Workouts';
  @override
  String get sleep => 'Sleep';
  @override
  String get recovery => 'Recovery';
  @override
  String get aiCoach => 'AI Health Coach';
  @override
  String get family => 'Family Care';
  @override
  String get subscriptions => 'Subscriptions';
  @override
  String get settings => 'Settings';
  @override
  String get dataVault => 'Data Vault';
  @override
  String get onboarding => 'Welcome to FitKarma';

  @override
  String get steps => 'steps';
  @override
  String get calories => 'kcal';
  @override
  String get water => 'Water';
  @override
  String get protein => 'Protein';
  @override
  String get carbs => 'Carbs';
  @override
  String get fats => 'Fats';
  @override
  String get dailyTarget => 'Daily Target';
  @override
  String get activeMinutes => 'Active Minutes';

  @override
  String get onTrack => 'On Track';
  @override
  String get fasting => 'Fasting Active';
  @override
  String get verified => 'Verified';
  @override
  String get offline => 'Offline Mode';
  @override
  String get karmaPro => 'Karma Pro';
  @override
  String get syncPending => 'Sync Pending';

  @override
  String get genericError => 'Something went wrong';
  @override
  String get networkError => 'Please check your internet connection';
  @override
  String get offlinePreserved =>
      'Your logs are safely preserved offline and will sync when connected.';
  @override
  String get noWorkoutsToday => 'No workouts logged today';
  @override
  String get noMealsLogged => 'No meals logged yet';
}

/// Hindi (हिन्दी) string catalog implementation.
class HindiStrings implements AppStrings {
  const HindiStrings();

  @override
  String get start => 'शुरू करें';
  @override
  String get save => 'सहेजें';
  @override
  String get cancel => 'रद्द करें';
  @override
  String get retry => 'पुनः प्रयास करें';
  @override
  String get delete => 'हटाएं';
  @override
  String get continueAction => 'आगे बढ़ें';
  @override
  String get back => 'पीछे';
  @override
  String get confirm => 'पुष्टि करें';
  @override
  String get edit => 'संपादित करें';

  @override
  String get appTitle => 'फिटकर्मा';
  @override
  String get dashboard => 'डैशबोर्ड';
  @override
  String get nutrition => 'पोषण व आहार';
  @override
  String get workouts => 'व्यायाम';
  @override
  String get sleep => 'नींद';
  @override
  String get recovery => 'रिकवरी';
  @override
  String get aiCoach => 'एआई स्वास्थ्य कोच';
  @override
  String get family => 'परिवार स्वास्थ्य';
  @override
  String get subscriptions => 'सदस्यता';
  @override
  String get settings => 'सेटिंग्स';
  @override
  String get dataVault => 'डेटा वॉल्ट';
  @override
  String get onboarding => 'फिटकर्मा में आपका स्वागत है';

  @override
  String get steps => 'कदम';
  @override
  String get calories => 'कैलोरी';
  @override
  String get water => 'पानी';
  @override
  String get protein => 'प्रोटीन';
  @override
  String get carbs => 'कार्बोहाइड्रेट';
  @override
  String get fats => 'वसा';
  @override
  String get dailyTarget => 'दैनिक लक्ष्य';
  @override
  String get activeMinutes => 'सक्रिय मिनट';

  @override
  String get onTrack => 'सही प्रगति';
  @override
  String get fasting => 'उपवास सक्रिय';
  @override
  String get verified => 'सत्यापित';
  @override
  String get offline => 'ऑफलाइन मोड';
  @override
  String get karmaPro => 'कर्मा प्रो';
  @override
  String get syncPending => 'सिंक प्रतीक्षारत';

  @override
  String get genericError => 'कुछ गड़बड़ हुई';
  @override
  String get networkError => 'कृपया अपना इंटरनेट कनेक्शन जांचें';
  @override
  String get offlinePreserved =>
      'आपका डेटा ऑफलाइन सुरक्षित है और नेटवर्क मिलने पर सिंक हो जाएगा।';
  @override
  String get noWorkoutsToday => 'आज कोई व्यायाम दर्ज नहीं किया गया';
  @override
  String get noMealsLogged => 'अभी तक कोई भोजन दर्ज नहीं किया गया';
}
