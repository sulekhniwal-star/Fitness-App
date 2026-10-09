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

  // --- Authentication ---
  String get phoneEntryTitle;
  String get phoneEntrySubtitle;
  String get phoneInputLabel;
  String get phoneInputHint;
  String get sendOtp;
  String get invalidPhoneError;
  String get authTermsNotice;
  String get otpVerificationTitle;
  String get otpVerificationSubtitle;
  String get changePhone;
  String get otpInputLabel;
  String get verifyOtp;
  String get resendOtp;
  String resendInSeconds(int seconds);
  String get otpSentSuccess;
  String get invalidOtpError;
  String get continueWithGoogle;
  String get orDivider;
  String get signOut;
  String get googleSignInCancelled;

  // --- Onboarding Flow ---
  String get onboardingWelcomeTitle;
  String get onboardingWelcomeSubtitle;
  String get onboardingGetStarted;
  String get onboardingLanguageTitle;
  String get onboardingLanguageSubtitle;
  String get onboardingPrivacyTitle;
  String get onboardingPrivacySubtitle;
  String get onboardingPrivacyConsentLabel;
  String get onboardingMedicalDisclaimer;
  String get onboardingBasicProfileTitle;
  String get onboardingBasicProfileSubtitle;
  String get onboardingDisplayNameLabel;
  String get onboardingAgeLabel;
  String get onboardingSexLabel;
  String get onboardingHeightLabel;
  String get onboardingWeightLabel;
  String get onboardingGoalsTitle;
  String get onboardingGoalsSubtitle;
  String get onboardingDietTitle;
  String get onboardingDietSubtitle;
  String get onboardingActivityTitle;
  String get onboardingActivitySubtitle;
  String get onboardingAyurvedaTitle;
  String get onboardingAyurvedaSubtitle;
  String get onboardingAyurvedaDisclaimer;
  String get onboardingSkip;
  String get onboardingPermissionsTitle;
  String get onboardingPermissionsSubtitle;
  String get onboardingNotificationsLabel;
  String get onboardingHealthSyncLabel;
  String get onboardingAccountSetupTitle;
  String get onboardingAccountSetupSubtitle;
  String get onboardingContinueAsGuest;
  String get onboardingComplete;
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

  // --- Authentication ---
  @override
  String get phoneEntryTitle => 'Enter your phone number';
  @override
  String get phoneEntrySubtitle =>
      'We will send a 6-digit verification code via SMS.';
  @override
  String get phoneInputLabel => 'Phone Number';
  @override
  String get phoneInputHint => '98765 43210';
  @override
  String get sendOtp => 'Get OTP';
  @override
  String get invalidPhoneError =>
      'Please enter a valid 10-digit mobile number';
  @override
  String get authTermsNotice =>
      'By continuing, you agree to FitKarma\'s Terms of Service and Privacy Policy.';
  @override
  String get otpVerificationTitle => 'Verify Phone';
  @override
  String get otpVerificationSubtitle => 'Enter the 6-digit code sent to';
  @override
  String get changePhone => 'Change';
  @override
  String get otpInputLabel => 'Verification Code';
  @override
  String get verifyOtp => 'Verify & Continue';
  @override
  String get resendOtp => 'Resend Code';
  @override
  String resendInSeconds(int seconds) => 'Resend code in ${seconds}s';
  @override
  String get otpSentSuccess => 'Verification code sent successfully.';
  @override
  String get invalidOtpError =>
      'Invalid verification code. Please check and try again.';
  @override
  String get continueWithGoogle => 'Continue with Google';
  @override
  String get orDivider => 'or';
  @override
  String get signOut => 'Sign Out';
  @override
  String get googleSignInCancelled => 'Google Sign-In was cancelled.';

  // --- Onboarding Flow ---
  @override
  String get onboardingWelcomeTitle => "India's Private Health OS";
  @override
  String get onboardingWelcomeSubtitle =>
      'Consolidates your health data, nutrition, and wellness into actionable daily intelligence. Works on WhatsApp and offline.';
  @override
  String get onboardingGetStarted => 'Get Started';
  @override
  String get onboardingLanguageTitle => 'Choose Your Language';
  @override
  String get onboardingLanguageSubtitle =>
      'Select your preferred UI language. Conversational coaching adapts automatically.';
  @override
  String get onboardingPrivacyTitle => 'Privacy & DPDP Consent';
  @override
  String get onboardingPrivacySubtitle =>
      'Your health data is stored locally first, encrypted, and never sold to advertisers or third parties.';
  @override
  String get onboardingPrivacyConsentLabel =>
      'I consent to processing my health observations for personalized wellness insights';
  @override
  String get onboardingMedicalDisclaimer =>
      'Medical Disclaimer: FitKarma provides lifestyle and nutritional wellness insights. It does not provide medical diagnoses, treatments, or prescriptions.';
  @override
  String get onboardingBasicProfileTitle => 'Basic Profile';
  @override
  String get onboardingBasicProfileSubtitle =>
      'Required for clinical metabolic expenditure and nutritional calculations.';
  @override
  String get onboardingDisplayNameLabel => 'Your Name';
  @override
  String get onboardingAgeLabel => 'Age (Years)';
  @override
  String get onboardingSexLabel => 'Biological Sex (for metabolic calculations)';
  @override
  String get onboardingHeightLabel => 'Height (cm)';
  @override
  String get onboardingWeightLabel => 'Weight (kg)';
  @override
  String get onboardingGoalsTitle => 'Fitness & Health Goals';
  @override
  String get onboardingGoalsSubtitle =>
      'Select your primary objectives to tailor your daily targets.';
  @override
  String get onboardingDietTitle => 'Dietary Identity & Preferences';
  @override
  String get onboardingDietSubtitle =>
      'Respecting Indian culinary traditions, fasting, and dietary lifestyle.';
  @override
  String get onboardingActivityTitle => 'Activity Baseline';
  @override
  String get onboardingActivitySubtitle =>
      'Helps calibrate your Total Daily Energy Expenditure (TDEE).';
  @override
  String get onboardingAyurvedaTitle => 'Ayurveda & Prakriti (Optional)';
  @override
  String get onboardingAyurvedaSubtitle =>
      'Discover your constitutional tendencies for traditional routine and wellness balancing.';
  @override
  String get onboardingAyurvedaDisclaimer =>
      'Ayurvedic insights provide traditional lifestyle guidance and are not medical diagnoses.';
  @override
  String get onboardingSkip => 'Skip for Now';
  @override
  String get onboardingPermissionsTitle => 'Permissions & Integrations';
  @override
  String get onboardingPermissionsSubtitle =>
      'Enable notifications and health platform sync for complete daily intelligence.';
  @override
  String get onboardingNotificationsLabel => 'Daily DIP & Meal Notifications';
  @override
  String get onboardingHealthSyncLabel =>
      'Sync with Health Connect / Apple Health';
  @override
  String get onboardingAccountSetupTitle => 'Account Setup';
  @override
  String get onboardingAccountSetupSubtitle =>
      'Secure your profile and synchronize across devices.';
  @override
  String get onboardingContinueAsGuest => 'Explore as Guest (Offline Mode)';
  @override
  String get onboardingComplete => 'Complete Setup & Launch';
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

  // --- Authentication ---
  @override
  String get phoneEntryTitle => 'अपना फ़ोन नंबर दर्ज करें';
  @override
  String get phoneEntrySubtitle =>
      'हम एसएमएस के जरिए 6 अंकों का सत्यापन कोड भेजेंगे।';
  @override
  String get phoneInputLabel => 'फ़ोन नंबर';
  @override
  String get phoneInputHint => '98765 43210';
  @override
  String get sendOtp => 'ओटीपी प्राप्त करें';
  @override
  String get invalidPhoneError =>
      'कृपया एक मान्य 10 अंकों का मोबाइल नंबर दर्ज करें';
  @override
  String get authTermsNotice =>
      'आगे बढ़कर आप फिटकर्मा की सेवा की शर्तों और गोपनीयता नीति से सहमत होते हैं।';
  @override
  String get otpVerificationTitle => 'फ़ोन सत्यापित करें';
  @override
  String get otpVerificationSubtitle => 'भेजा गया 6 अंकों का कोड दर्ज करें';
  @override
  String get changePhone => 'बदलें';
  @override
  String get otpInputLabel => 'सत्यापन कोड';
  @override
  String get verifyOtp => 'सत्यापित करें और आगे बढ़ें';
  @override
  String get resendOtp => 'कोड पुनः भेजें';
  @override
  String resendInSeconds(int seconds) => '$seconds सेकंड में पुनः भेजें';
  @override
  String get otpSentSuccess => 'सत्यापन कोड सफलतापूर्वक भेजा गया।';
  @override
  String get invalidOtpError =>
      'अमान्य सत्यापन कोड। कृपया जांचें और पुनः प्रयास करें।';
  @override
  String get continueWithGoogle => 'गूगल के साथ आगे बढ़ें';
  @override
  String get orDivider => 'या';
  @override
  String get signOut => 'साइन आउट';
  @override
  String get googleSignInCancelled => 'गूगल साइन-इन रद्द कर दिया गया।';

  // --- Onboarding Flow ---
  @override
  String get onboardingWelcomeTitle => 'भारत का निजी हेल्थ ओएस';
  @override
  String get onboardingWelcomeSubtitle =>
      'आपके स्वास्थ्य, पोषण और दिनचर्या को दैनिक बुद्धिमत्ता में बदलता है। व्हाट्सएप और ऑफलाइन दोनों पर उपलब्ध।';
  @override
  String get onboardingGetStarted => 'शुरू करें';
  @override
  String get onboardingLanguageTitle => 'अपनी भाषा चुनें';
  @override
  String get onboardingLanguageSubtitle =>
      'अपनी पसंदीदा भाषा चुनें। कोचिंग अपने आप अनुकूलित होगी।';
  @override
  String get onboardingPrivacyTitle => 'गोपनीयता और सहमति';
  @override
  String get onboardingPrivacySubtitle =>
      'आपका स्वास्थ्य डेटा स्थानीय रूप से सुरक्षित और एन्क्रिप्टेड है, किसी तीसरे पक्ष को नहीं बेचा जाता।';
  @override
  String get onboardingPrivacyConsentLabel =>
      'मैं व्यक्तिगत स्वास्थ्य सुझावों के लिए डेटा प्रसंस्करण की सहमति देता/देती हूँ';
  @override
  String get onboardingMedicalDisclaimer =>
      'चिकित्सीय अस्वीकरण: फिटकर्मा केवल जीवनशैली और पोषण संबंधी मार्गदर्शन प्रदान करता है। यह चिकित्सीय निदान या उपचार का विकल्प नहीं है।';
  @override
  String get onboardingBasicProfileTitle => 'मूल प्रोफ़ाइल';
  @override
  String get onboardingBasicProfileSubtitle =>
      'सटीक चयापचय (मेटाबॉलिक) गणनाओं के लिए आवश्यक।';
  @override
  String get onboardingDisplayNameLabel => 'आपका नाम';
  @override
  String get onboardingAgeLabel => 'आयु (वर्ष)';
  @override
  String get onboardingSexLabel => 'जैविक लिंग (मेटाबॉलिक गणना हेतु)';
  @override
  String get onboardingHeightLabel => 'कद (सेमी)';
  @override
  String get onboardingWeightLabel => 'वजन (किग्रा)';
  @override
  String get onboardingGoalsTitle => 'स्वास्थ्य और फिटनेस लक्ष्य';
  @override
  String get onboardingGoalsSubtitle =>
      'दैनिक लक्ष्यों को अनुकूलित करने के लिए अपने मुख्य लक्ष्य चुनें।';
  @override
  String get onboardingDietTitle => 'आहार और भोजन प्राथमिकताएँ';
  @override
  String get onboardingDietSubtitle =>
      'भारतीय भोजन परंपराओं, उपवास और आहार नियमों का सम्मान।';
  @override
  String get onboardingActivityTitle => 'दैनिक गतिविधि स्तर';
  @override
  String get onboardingActivitySubtitle =>
      'दैनिक ऊर्जा व्यय (टीडीईई) को सटीक बनाने में मदद करता है।';
  @override
  String get onboardingAyurvedaTitle => 'आयुर्वेद और प्रकृति (वैकल्पिक)';
  @override
  String get onboardingAyurvedaSubtitle =>
      'संतुलित दिनचर्या के लिए अपनी शारीरिक प्रकृति जानें।';
  @override
  String get onboardingAyurvedaDisclaimer =>
      'आयुर्वेदिक मार्गदर्शन पारंपरिक जीवनशैली संदर्भ है, कोई चिकित्सीय निदान नहीं।';
  @override
  String get onboardingSkip => 'अभी छोड़ें';
  @override
  String get onboardingPermissionsTitle => 'अनुमतियाँ और एकीकरण';
  @override
  String get onboardingPermissionsSubtitle =>
      'दैनिक सुझावों और स्वचालित डेटा सिंक के लिए अनुमतियाँ सक्षम करें।';
  @override
  String get onboardingNotificationsLabel => 'दैनिक सुझाव व भोजन स्मरण';
  @override
  String get onboardingHealthSyncLabel => 'हेल्थ कनेक्ट / एप्पल हेल्थ से जोड़ें';
  @override
  String get onboardingAccountSetupTitle => 'खाता सेटअप';
  @override
  String get onboardingAccountSetupSubtitle =>
      'अपनी प्रोफ़ाइल सुरक्षित करें और उपकरणों के बीच सिंक करें।';
  @override
  String get onboardingContinueAsGuest =>
      'अतिथि के रूप में अन्वेषण करें (ऑफलाइन)';
  @override
  String get onboardingComplete => 'सेटअप पूरा करें और शुरू करें';
}
