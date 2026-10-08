import 'package:fitkarma/core/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSupportedLocale and Locale Enumeration Tests', () {
    test('enumerates baseline and expansion Indian languages', () {
      expect(AppSupportedLocale.english.languageCode, equals('en'));
      expect(AppSupportedLocale.hindi.languageCode, equals('hi'));
      expect(AppSupportedLocale.tamil.languageCode, equals('ta'));
      expect(AppSupportedLocale.telugu.languageCode, equals('te'));
      expect(AppSupportedLocale.gujarati.languageCode, equals('gu'));
      expect(AppSupportedLocale.bengali.languageCode, equals('bn'));
      expect(AppSupportedLocale.marathi.languageCode, equals('mr'));
      expect(AppSupportedLocale.punjabi.languageCode, equals('pa'));

      // Baseline languages are fully localized in Phase 1
      expect(AppSupportedLocale.english.isFullyLocalized, isTrue);
      expect(AppSupportedLocale.hindi.isFullyLocalized, isTrue);

      // Expansion languages are prepared for Phase 2/expansion
      expect(AppSupportedLocale.tamil.isFullyLocalized, isFalse);
      expect(AppSupportedLocale.telugu.isFullyLocalized, isFalse);
      expect(AppSupportedLocale.gujarati.isFullyLocalized, isFalse);
      expect(AppSupportedLocale.bengali.isFullyLocalized, isFalse);
      expect(AppSupportedLocale.marathi.isFullyLocalized, isFalse);
      expect(AppSupportedLocale.punjabi.isFullyLocalized, isFalse);
    });

    test('fromCode maps codes accurately and safely defaults to English', () {
      expect(
        AppSupportedLocale.fromCode('hi'),
        equals(AppSupportedLocale.hindi),
      );
      expect(
        AppSupportedLocale.fromCode('HI'),
        equals(AppSupportedLocale.hindi),
      );
      expect(
        AppSupportedLocale.fromCode('ta'),
        equals(AppSupportedLocale.tamil),
      );
      expect(
        AppSupportedLocale.fromCode('unknown'),
        equals(AppSupportedLocale.english),
      );
      expect(
        AppSupportedLocale.fromCode(null),
        equals(AppSupportedLocale.english),
      );
    });
  });

  group('String Catalogs & Parity Tests', () {
    test('EnglishStrings provides complete non-empty string catalog', () {
      const en = EnglishStrings();

      // Navigation
      expect(en.dashboard, equals('Dashboard'));
      expect(en.nutrition, equals('Nutrition'));
      expect(en.workouts, equals('Workouts'));
      expect(en.sleep, equals('Sleep'));
      expect(en.recovery, equals('Recovery'));
      expect(en.aiCoach, isNotEmpty);
      expect(en.dataVault, equals('Data Vault'));

      // Metrics
      expect(en.steps, equals('steps'));
      expect(en.calories, equals('kcal'));
      expect(en.water, equals('Water'));

      // Error and recovery
      expect(en.offlinePreserved, isNotEmpty);
      expect(en.genericError, isNotEmpty);
    });

    test(
      'HindiStrings provides cultural, culturally respectful translations',
      () {
        const hi = HindiStrings();

        // Navigation
        expect(hi.dashboard, equals('डैशबोर्ड'));
        expect(hi.nutrition, equals('पोषण व आहार'));
        expect(hi.workouts, equals('व्यायाम'));
        expect(hi.sleep, equals('नींद'));
        expect(hi.recovery, equals('रिकवरी'));
        expect(hi.dataVault, equals('डेटा वॉल्ट'));

        // Metrics
        expect(hi.steps, equals('कदम'));
        expect(hi.calories, equals('कैलोरी'));
        expect(hi.water, equals('पानी'));

        // Error and recovery
        expect(hi.offlinePreserved, contains('सुरक्षित'));
        expect(hi.genericError, equals('कुछ गड़बड़ हुई'));
      },
    );
  });

  group('Missing Translation Fallback Tests', () {
    test('falls back safely to English for prepared expansion languages', () {
      final preparedLocales = [
        const Locale('ta'),
        const Locale('te'),
        const Locale('gu'),
        const Locale('bn'),
        const Locale('mr'),
        const Locale('pa'),
      ];

      for (final locale in preparedLocales) {
        final strings = AppLocalizations.resolveStrings(locale);
        // Until Phase 2 catalogs are loaded, prepared languages fall back cleanly to English
        expect(strings, isA<EnglishStrings>());
        expect(strings.nutrition, equals('Nutrition'));
        expect(strings.steps, equals('steps'));
      }
    });

    test('falls back safely to English for completely unknown locales', () {
      final strings = AppLocalizations.resolveStrings(const Locale('fr'));
      expect(strings, isA<EnglishStrings>());
      expect(strings.dashboard, equals('Dashboard'));
    });
  });

  group('Reactive Locale Switching & Riverpod Tests', () {
    test('AppLocaleNotifier switches locales and toggles English/Hindi', () {
      final notifier = AppLocaleNotifier();

      expect(notifier.state.languageCode, equals('en'));

      notifier.setLocale(const Locale('hi'));
      expect(notifier.state.languageCode, equals('hi'));

      notifier.toggleEnglishHindi();
      expect(notifier.state.languageCode, equals('en'));

      notifier.toggleEnglishHindi();
      expect(notifier.state.languageCode, equals('hi'));
    });

    testWidgets('UI updates immediately on locale change without restart', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              final activeLocale = ref.watch(appLocaleProvider);
              final strings = ref.watch(appStringsProvider);

              return MaterialApp(
                locale: activeLocale,
                supportedLocales: AppSupportedLocale.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: Scaffold(
                  body: Column(
                    children: [
                      Text('Current: ${strings.nutrition}'),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(appLocaleProvider.notifier)
                              .toggleEnglishHindi();
                        },
                        child: const Text('Switch Language'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Initially in English
      expect(find.text('Current: Nutrition'), findsOneWidget);

      // Tap language toggle
      await tester.tap(find.text('Switch Language'));
      await tester.pumpAndSettle();

      // Reactively renders Hindi without restart
      expect(find.text('Current: पोषण व आहार'), findsOneWidget);

      // Tap again to return to English
      await tester.tap(find.text('Switch Language'));
      await tester.pumpAndSettle();

      expect(find.text('Current: Nutrition'), findsOneWidget);
    });
  });

  group('Separation of UI Localization from AI Conversational Phrasing', () {
    test(
      'AiPhrasingConfig generates prompt directives decoupled from UI strings',
      () {
        const config = AiPhrasingConfig(
          dialect: AiConversationalDialect.hinglish,
          hinglishMixRatio: HinglishMixRatio.balanced,
          tone: AiCoachingTone.peerBuddy,
          respectFastingContext: true,
          regionalDietaryContext: 'North Indian vegetarian',
        );

        final directives = config.generatePromptDirectives();

        // Check prompt directives for LLM
        expect(directives, contains('Language & Phrasing Directives'));
        expect(directives, contains('Natural Indian Hinglish'));
        expect(directives, contains('45%'));
        expect(directives, contains('tadka'));
        expect(directives, contains('peer ("Dost/Buddy")'));
        expect(directives, contains('Fasting Sensitivity'));
        expect(directives, contains('North Indian vegetarian'));

        // Confirm UI strings remain pristine and isolated from AI prompt directives
        const uiStrings = EnglishStrings();
        expect(uiStrings.nutrition, equals('Nutrition'));
        expect(uiStrings.nutrition.contains('Directives'), isFalse);
      },
    );

    test('AiConversationalDialect supports all prepared regional dialects', () {
      final dialects = AiConversationalDialect.values;
      final codes = dialects.map((d) => d.code).toList();

      expect(
        codes,
        containsAll([
          'en',
          'hi',
          'hinglish',
          'ta',
          'te',
          'gu',
          'bn',
          'mr',
          'pa',
        ]),
      );
    });
  });
}
