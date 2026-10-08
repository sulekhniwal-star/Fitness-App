import 'dart:convert';

import 'package:fitkarma/core/config/remote_config.dart';
import 'package:fitkarma/core/config/remote_config_service.dart';
import 'package:fitkarma/core/config/app_config.dart';
import 'package:fitkarma/core/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemoteConfig and SubscriptionPlan models', () {
    test(
      'RemoteConfig.defaults() provides safe deterministic offline defaults',
      () {
        final config = RemoteConfig.defaults();

        expect(config.version, contains('default'));
        expect(config.plans, isNotEmpty);

        // Core features active by default
        expect(config.featureFlags['offline_logging'], isTrue);
        expect(config.featureFlags['indian_food_database'], isTrue);

        // Gated P1/P2/PROPOSED features are disabled by default
        expect(config.featureFlags['photo_food_logging'], isFalse);
        expect(config.featureFlags['aqi_weather_context'], isFalse);
        expect(config.featureFlags['tamil_telugu_support'], isFalse);
        expect(config.featureFlags['family_care_dashboard'], isFalse);
        expect(config.featureFlags['cgm_pipeline'], isFalse);

        // Kill switches are inactive (false) by default
        expect(config.featureFlags['kill_switch_ai_routing'], isFalse);
        expect(config.featureFlags['kill_switch_whatsapp_logging'], isFalse);
        expect(config.featureFlags['kill_switch_external_providers'], isFalse);

        // Plans present in defaults
        final planIds = config.plans.map((p) => p.id).toList();
        expect(
          planIds,
          containsAll([
            'yogi_free',
            'karma_pro_monthly',
            'karma_pro_yearly',
            'fitkarma_elite_monthly',
            'sachet_sprint_7d',
          ]),
        );
      },
    );

    test('SubscriptionPlan serialization and cadence parsing', () {
      const plan = SubscriptionPlan(
        id: 'test_plan',
        displayName: 'Test Plan',
        priceInRupees: 299,
        cadence: BillingCadence.monthly,
        entitlements: ['feature_a', 'feature_b'],
      );

      final json = plan.toJson();
      final reconstructed = SubscriptionPlan.fromJson(json);

      expect(reconstructed.id, equals('test_plan'));
      expect(reconstructed.displayName, equals('Test Plan'));
      expect(reconstructed.priceInRupees, equals(299));
      expect(reconstructed.cadence, equals(BillingCadence.monthly));
      expect(reconstructed.entitlements, equals(['feature_a', 'feature_b']));
    });

    test('BillingCadence handles various input strings gracefully', () {
      expect(BillingCadence.fromString('monthly'), BillingCadence.monthly);
      expect(BillingCadence.fromString('yearly'), BillingCadence.yearly);
      expect(BillingCadence.fromString('annual'), BillingCadence.yearly);
      expect(BillingCadence.fromString('one_time'), BillingCadence.oneTime);
      expect(BillingCadence.fromString('sachet'), BillingCadence.oneTime);
      expect(BillingCadence.fromString('free'), BillingCadence.free);
      expect(BillingCadence.fromString(null), BillingCadence.free);
      expect(BillingCadence.fromString('invalid'), BillingCadence.free);
    });

    test('RemoteConfig serialization round-trip', () {
      final original = RemoteConfig.defaults();
      final json = original.toJson();
      final parsed = RemoteConfig.fromJson(json);

      expect(parsed.version, equals(original.version));
      expect(parsed.featureFlags, equals(original.featureFlags));
      expect(parsed.plans.length, equals(original.plans.length));
    });

    test('RemoteConfig throws SecurityViolationException if payload contains prohibited secrets', () {
      final secretPayloads = [
        {'supabase_service_role_key': 'secret_123'},
        {'razorpay_secret': 'key_secret'},
        {'private_key': 'abc'},
      ];

      for (final payload in secretPayloads) {
        expect(
          () => RemoteConfig.fromJson(payload),
          throwsA(isA<SecurityViolationException>()),
        );
      }
    });
  });

  group('RemoteConfigService', () {
    test('initializes with offline defaults when cache is empty', () async {
      final storage = InMemoryConfigCacheStorage();
      final service = RemoteConfigService(cacheStorage: storage);

      expect(service.isInitialized, isFalse);
      await service.initialize();

      expect(service.isInitialized, isTrue);
      expect(service.activeConfig.version, contains('default'));
      expect(service.isFeatureEnabled('offline_logging'), isTrue);
      expect(service.isFeatureEnabled('photo_food_logging'), isFalse);
    });

    test('initializes from cached config when cache is populated', () async {
      final customConfig = RemoteConfig(
        version: '2.0.0-remote',
        fetchedAt: DateTime.utc(2026, 10, 8),
        featureFlags: const {
          'photo_food_logging': true,
          'offline_logging': true,
        },
        plans: const [
          SubscriptionPlan(
            id: 'custom_plan',
            displayName: 'Special Offer',
            priceInRupees: 99,
            cadence: BillingCadence.monthly,
            entitlements: ['all_access'],
          ),
        ],
      );

      final storage = InMemoryConfigCacheStorage(
        jsonEncode(customConfig.toJson()),
      );
      final service = RemoteConfigService(cacheStorage: storage);

      await service.initialize();

      expect(service.activeConfig.version, equals('2.0.0-remote'));
      expect(service.isFeatureEnabled('photo_food_logging'), isTrue);
      expect(service.getAvailablePlans().length, equals(1));
      expect(service.getPlanById('custom_plan')?.priceInRupees, equals(99));
    });

    test('falls back to defaults if cached JSON is corrupted', () async {
      final storage = InMemoryConfigCacheStorage('corrupted { json [');
      final service = RemoteConfigService(cacheStorage: storage);

      await service.initialize();

      expect(service.isInitialized, isTrue);
      expect(service.activeConfig.version, contains('default'));
    });

    test('activate updates activeConfig and persists to cache', () async {
      final storage = InMemoryConfigCacheStorage();
      final service = RemoteConfigService(cacheStorage: storage);
      await service.initialize();

      final updatedConfig = RemoteConfig(
        version: '2.5.0-updated',
        fetchedAt: DateTime.utc(2026, 10, 8),
        featureFlags: const {'aqi_weather_context': true},
        plans: const [
          SubscriptionPlan(
            id: 'updated_pro',
            displayName: 'Karma Pro Festive',
            priceInRupees: 99,
            cadence: BillingCadence.monthly,
            entitlements: ['full_access'],
          ),
        ],
      );

      await service.activate(updatedConfig);

      expect(service.activeConfig.version, equals('2.5.0-updated'));
      expect(service.isFeatureEnabled('aqi_weather_context'), isTrue);
      expect(service.getPlanById('updated_pro')?.priceInRupees, equals(99));

      // Verify cached in storage
      final storedJson = await storage.readConfig();
      expect(storedJson, isNotNull);
      expect(storedJson, contains('2.5.0-updated'));
      expect(storedJson, contains('Karma Pro Festive'));
    });

    test('isFeatureEnabled returns false for unknown flags', () async {
      final service = RemoteConfigService();
      await service.initialize();

      expect(service.isFeatureEnabled('non_existent_feature_xyz'), isFalse);
    });

    test(
      'emergency kill switches immediately override feature enablement',
      () async {
        final storage = InMemoryConfigCacheStorage();
        final service = RemoteConfigService(cacheStorage: storage);

        // Config with features enabled AND kill switches activated
        final killSwitchedConfig = RemoteConfig(
          version: '1.5.0-killswitch',
          fetchedAt: DateTime.utc(2026, 10, 8),
          featureFlags: const {
            'ai_meal_analysis': true,
            'whatsapp_voice': true,
            'cgm_pipeline': true,
            'aqi_weather_context': true,
            'kill_switch_ai_routing': true,
            'kill_switch_whatsapp_logging': true,
            'kill_switch_external_providers': true,
          },
          plans: const [],
        );

        await service.activate(killSwitchedConfig);

        // Kill switch status
        expect(service.isKillSwitchActive('kill_switch_ai_routing'), isTrue);
        expect(
          service.isKillSwitchActive('kill_switch_whatsapp_logging'),
          isTrue,
        );
        expect(
          service.isKillSwitchActive('kill_switch_external_providers'),
          isTrue,
        );

        // Even though features were flagged true, related kill switches must disable them
        expect(service.isFeatureEnabled('ai_meal_analysis'), isFalse);
        expect(service.isFeatureEnabled('whatsapp_voice'), isFalse);
        expect(service.isFeatureEnabled('cgm_pipeline'), isFalse);
        expect(service.isFeatureEnabled('aqi_weather_context'), isFalse);
      },
    );

    test('plan lookup methods return correct plans or null', () async {
      final service = RemoteConfigService();
      await service.initialize();

      final freePlan = service.getPlanById('yogi_free');
      expect(freePlan, isNotNull);
      expect(freePlan?.priceInRupees, equals(0));
      expect(freePlan?.cadence, equals(BillingCadence.free));

      final proMonthly = service.getPlanById('karma_pro_monthly');
      expect(proMonthly, isNotNull);
      expect(proMonthly?.priceInRupees, equals(149));

      final missingPlan = service.getPlanById('non_existent_tier');
      expect(missingPlan, isNull);
    });

    test(
      'Riverpod remoteConfigServiceProvider resolves RemoteConfigService',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final service = container.read(remoteConfigServiceProvider);
        expect(service, isA<RemoteConfigService>());
        expect(service.activeConfig.plans, isNotEmpty);
      },
    );
  });
}
