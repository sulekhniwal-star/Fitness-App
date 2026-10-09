import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/errors/result.dart';
import 'package:fitkarma/core/localization/app_locale.dart';
import 'package:fitkarma/core/localization/locale_provider.dart';
import 'package:fitkarma/core/supabase/supabase_providers.dart';
import 'package:fitkarma/core/supabase/supabase_service_boundary.dart';
import 'package:fitkarma/features/profile/domain/models/notification_preferences.dart';
import 'package:fitkarma/features/profile/domain/models/nutrition_preferences.dart';
import 'package:fitkarma/features/profile/domain/models/profile_enums.dart';
import 'package:fitkarma/features/profile/domain/models/user_profile.dart';
import 'package:fitkarma/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:fitkarma/features/profile/domain/validation/user_profile_validator.dart';
import 'package:fitkarma/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Available steps in the onboarding wizard.
enum OnboardingStep {
  welcome,
  language,
  consent,
  basicProfile,
  goals,
  dietary,
  activity,
  ayurveda,
  permissions,
  accountSetup,
}

/// Immutable state representing current progress and answers across the onboarding wizard.
class OnboardingState {
  final int currentStepIndex;
  final String selectedLocale;
  final bool consentGranted;
  final String displayName;
  final int age;
  final BiologicalSex biologicalSex;
  final double heightCm;
  final double weightKg;
  final List<FitnessGoal> goals;
  final DietaryIdentity dietaryIdentity;
  final int mealsPerDay;
  final String? fastingProtocol;
  final ActivityLevel activityLevel;
  final AyurvedicDosha? dosha;
  final bool notificationsEnabled;
  final bool healthSyncEnabled;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, String>? validationErrors;
  final bool isCompleted;

  const OnboardingState({
    this.currentStepIndex = 0,
    this.selectedLocale = 'en',
    this.consentGranted = false,
    this.displayName = '',
    this.age = 25,
    this.biologicalSex = BiologicalSex.male,
    this.heightCm = 170.0,
    this.weightKg = 70.0,
    this.goals = const [FitnessGoal.weightLoss],
    this.dietaryIdentity = DietaryIdentity.vegetarian,
    this.mealsPerDay = 3,
    this.fastingProtocol,
    this.activityLevel = ActivityLevel.moderatelyActive,
    this.dosha,
    this.notificationsEnabled = true,
    this.healthSyncEnabled = false,
    this.isLoading = false,
    this.errorMessage,
    this.validationErrors,
    this.isCompleted = false,
  });

  OnboardingStep get currentStep =>
      OnboardingStep.values[currentStepIndex.clamp(0, totalSteps - 1)];

  int get totalSteps => OnboardingStep.values.length;
  double get progress => (currentStepIndex + 1) / totalSteps;
  bool get canGoBack => currentStepIndex > 0;
  bool get isLastStep => currentStepIndex == totalSteps - 1;

  OnboardingState copyWith({
    int? currentStepIndex,
    String? selectedLocale,
    bool? consentGranted,
    String? displayName,
    int? age,
    BiologicalSex? biologicalSex,
    double? heightCm,
    double? weightKg,
    List<FitnessGoal>? goals,
    DietaryIdentity? dietaryIdentity,
    int? mealsPerDay,
    String? fastingProtocol,
    bool clearFastingProtocol = false,
    ActivityLevel? activityLevel,
    AyurvedicDosha? dosha,
    bool clearDosha = false,
    bool? notificationsEnabled,
    bool? healthSyncEnabled,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    Map<String, String>? validationErrors,
    bool clearValidationErrors = false,
    bool? isCompleted,
  }) {
    return OnboardingState(
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      selectedLocale: selectedLocale ?? this.selectedLocale,
      consentGranted: consentGranted ?? this.consentGranted,
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      biologicalSex: biologicalSex ?? this.biologicalSex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goals: goals ?? this.goals,
      dietaryIdentity: dietaryIdentity ?? this.dietaryIdentity,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      fastingProtocol: clearFastingProtocol
          ? null
          : (fastingProtocol ?? this.fastingProtocol),
      activityLevel: activityLevel ?? this.activityLevel,
      dosha: clearDosha ? null : (dosha ?? this.dosha),
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      healthSyncEnabled: healthSyncEnabled ?? this.healthSyncEnabled,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      validationErrors: clearValidationErrors
          ? null
          : (validationErrors ?? this.validationErrors),
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Controller managing onboarding steps, validation, and profile creation.
class OnboardingController extends StateNotifier<OnboardingState> {
  final IUserProfileRepository profileRepository;
  final ISupabaseAuthService authService;
  final AppLocaleNotifier localeNotifier;

  OnboardingController({
    required this.profileRepository,
    required this.authService,
    required this.localeNotifier,
  }) : super(const OnboardingState());

  void setLocale(String languageCode) {
    localeNotifier.setSupportedLocale(AppSupportedLocale.fromCode(languageCode));
    state = state.copyWith(
      selectedLocale: languageCode,
      clearError: true,
    );
  }

  void setConsent(bool granted) {
    state = state.copyWith(
      consentGranted: granted,
      clearError: true,
    );
  }

  void updateBasicProfile({
    String? displayName,
    int? age,
    BiologicalSex? biologicalSex,
    double? heightCm,
    double? weightKg,
  }) {
    state = state.copyWith(
      displayName: displayName ?? state.displayName,
      age: age ?? state.age,
      biologicalSex: biologicalSex ?? state.biologicalSex,
      heightCm: heightCm ?? state.heightCm,
      weightKg: weightKg ?? state.weightKg,
      clearError: true,
      clearValidationErrors: true,
    );
  }

  void toggleGoal(FitnessGoal goal) {
    final currentGoals = List<FitnessGoal>.from(state.goals);
    if (currentGoals.contains(goal)) {
      if (currentGoals.length > 1) {
        currentGoals.remove(goal);
      }
    } else {
      currentGoals.add(goal);
    }
    state = state.copyWith(
      goals: currentGoals,
      clearError: true,
      clearValidationErrors: true,
    );
  }

  void setDietaryIdentity(
    DietaryIdentity identity, {
    int? mealsPerDay,
    String? fastingProtocol,
  }) {
    state = state.copyWith(
      dietaryIdentity: identity,
      mealsPerDay: mealsPerDay ?? state.mealsPerDay,
      fastingProtocol: fastingProtocol,
      clearFastingProtocol: fastingProtocol == null,
      clearError: true,
    );
  }

  void setActivityLevel(ActivityLevel level) {
    state = state.copyWith(
      activityLevel: level,
      clearError: true,
    );
  }

  void setDosha(AyurvedicDosha? dosha) {
    state = state.copyWith(
      dosha: dosha,
      clearDosha: dosha == null,
      clearError: true,
    );
  }

  void setNotificationsEnabled(bool enabled) {
    state = state.copyWith(
      notificationsEnabled: enabled,
      clearError: true,
    );
  }

  void setHealthSyncEnabled(bool enabled) {
    state = state.copyWith(
      healthSyncEnabled: enabled,
      clearError: true,
    );
  }

  bool nextStep() {
    state = state.copyWith(clearError: true, clearValidationErrors: true);

    switch (state.currentStep) {
      case OnboardingStep.welcome:
      case OnboardingStep.language:
        break;

      case OnboardingStep.consent:
        if (!state.consentGranted) {
          state = state.copyWith(
            errorMessage:
                'Please agree to the privacy notice and data processing consent to continue.',
          );
          return false;
        }
        break;

      case OnboardingStep.basicProfile:
        final validationFailure = UserProfileValidator.validate(
          displayName: state.displayName,
          age: state.age,
          heightCm: state.heightCm,
          weightKg: state.weightKg,
          goals: state.goals,
          mealsPerDay: state.mealsPerDay,
          locale: state.selectedLocale,
        );

        if (validationFailure != null) {
          state = state.copyWith(
            errorMessage: validationFailure.message,
            validationErrors: validationFailure.fieldErrors,
          );
          return false;
        }
        break;

      case OnboardingStep.goals:
        if (state.goals.isEmpty) {
          state = state.copyWith(
            errorMessage: 'Please select at least one fitness goal.',
          );
          return false;
        }
        break;

      case OnboardingStep.dietary:
      case OnboardingStep.activity:
      case OnboardingStep.ayurveda:
      case OnboardingStep.permissions:
      case OnboardingStep.accountSetup:
        break;
    }

    if (state.currentStepIndex < state.totalSteps - 1) {
      state = state.copyWith(
        currentStepIndex: state.currentStepIndex + 1,
        clearError: true,
      );
      return true;
    }
    return false;
  }

  void previousStep() {
    if (state.currentStepIndex > 0) {
      state = state.copyWith(
        currentStepIndex: state.currentStepIndex - 1,
        clearError: true,
        clearValidationErrors: true,
      );
    }
  }

  void goToStep(int index) {
    if (index >= 0 && index < state.totalSteps) {
      state = state.copyWith(
        currentStepIndex: index,
        clearError: true,
        clearValidationErrors: true,
      );
    }
  }

  /// Builds a [UserProfile] entity from the current onboarding state answers.
  UserProfile buildProfile({required String userId}) {
    final now = DateTime.now();
    return UserProfile(
      id: 'profile-$userId',
      userId: userId,
      displayName: state.displayName.trim().isEmpty
          ? 'FitKarma User'
          : state.displayName.trim(),
      age: state.age,
      biologicalSex: state.biologicalSex,
      heightCm: state.heightCm,
      weightKg: state.weightKg,
      goals: state.goals,
      activityLevel: state.activityLevel,
      dietaryIdentity: state.dietaryIdentity,
      dosha: state.dosha,
      nutritionPreferences: NutritionPreferences(
        fastingProtocol: state.fastingProtocol,
        mealsPerDay: state.mealsPerDay,
      ),
      notificationPreferences: NotificationPreferences(
        dailyDIPDigest: state.notificationsEnabled,
        mealReminders: state.notificationsEnabled,
        hydrationReminders: state.notificationsEnabled,
        fastingReminders:
            state.notificationsEnabled && state.fastingProtocol != null,
        workoutReminders: state.notificationsEnabled,
      ),
      locale: state.selectedLocale,
      isSynced: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Completes onboarding as an anonymous guest user, saving the profile locally.
  Future<Result<UserProfile>> completeAsGuest() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 1. Establish anonymous guest session
      final authResult = await authService.signInAnonymously();
      switch (authResult) {
        case FailureResult(:final failure):
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return FailureResult(failure);

        case Success(:final data):
          final user = data.user;
          // 2. Build profile and save to local-first repository
          final profile = buildProfile(userId: user.id);
          final saveResult = await profileRepository.saveProfile(profile);

          switch (saveResult) {
            case Success(:final data):
              state = state.copyWith(
                isLoading: false,
                isCompleted: true,
              );
              return Success(data);

            case FailureResult(:final failure):
              state = state.copyWith(
                isLoading: false,
                errorMessage: failure.message,
              );
              return FailureResult(failure);
          }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred while completing setup.',
      );
      return FailureResult(InternalFailure(message: e.toString()));
    }
  }

  /// Completes onboarding for an already authenticated user.
  Future<Result<UserProfile>> completeForCurrentUser(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final profile = buildProfile(userId: userId);
      final saveResult = await profileRepository.saveProfile(profile);

      switch (saveResult) {
        case Success(:final data):
          state = state.copyWith(
            isLoading: false,
            isCompleted: true,
          );
          return Success(data);

        case FailureResult(:final failure):
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return FailureResult(failure);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred while saving profile.',
      );
      return FailureResult(InternalFailure(message: e.toString()));
    }
  }
}

/// Provider for [OnboardingController].
final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  final repo = ref.watch(userProfileRepositoryProvider);
  final authService = ref.watch(supabaseAuthServiceProvider);
  final localeNotifier = ref.watch(appLocaleProvider.notifier);

  return OnboardingController(
    profileRepository: repo,
    authService: authService,
    localeNotifier: localeNotifier,
  );
}, name: 'onboardingControllerProvider');
