import 'package:fitkarma/core/config/app_config.dart';

/// Billing cadence enum.
enum BillingCadence {
  free,
  monthly,
  yearly,
  oneTime;

  static BillingCadence fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'monthly':
        return BillingCadence.monthly;
      case 'yearly':
      case 'annual':
        return BillingCadence.yearly;
      case 'one_time':
      case 'sachet':
        return BillingCadence.oneTime;
      case 'free':
      default:
        return BillingCadence.free;
    }
  }
}

/// Dynamic commercial subscription plan definition resolved from backend config.
///
/// Pricing, names, and entitlements are never hard-coded architectural constants.
class SubscriptionPlan {
  final String id;
  final String displayName;
  final int priceInRupees;
  final BillingCadence cadence;
  final List<String> entitlements;

  const SubscriptionPlan({
    required this.id,
    required this.displayName,
    required this.priceInRupees,
    required this.cadence,
    required this.entitlements,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String? ?? 'unknown',
      displayName: json['display_name'] as String? ?? '',
      priceInRupees: (json['price_in_rupees'] as num?)?.toInt() ?? 0,
      cadence: BillingCadence.fromString(json['cadence'] as String?),
      entitlements:
          (json['entitlements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': displayName,
    'price_in_rupees': priceInRupees,
    'cadence': cadence.name,
    'entitlements': entitlements,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionPlan &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          priceInRupees == other.priceInRupees &&
          cadence == other.cadence;

  @override
  int get hashCode => id.hashCode ^ priceInRupees.hashCode ^ cadence.hashCode;
}

/// Remote configuration state containing feature flags, kill switches, and plans.
class RemoteConfig {
  final String version;
  final DateTime fetchedAt;
  final Map<String, bool> featureFlags;
  final List<SubscriptionPlan> plans;

  const RemoteConfig({
    required this.version,
    required this.fetchedAt,
    required this.featureFlags,
    required this.plans,
  });

  /// Deterministic, safe offline defaults when remote config cannot be fetched.
  factory RemoteConfig.defaults() {
    return RemoteConfig(
      version: '1.0.0-default',
      fetchedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      featureFlags: {
        // Core features active by default
        'offline_logging': true,
        'indian_food_database': true,
        'dynamic_tdee': true,
        'tadka_slider': true,
        'family_recipe_splitter': true,
        // P1/P2/PROPOSED features gated
        'photo_food_logging': false,
        'aqi_weather_context': false,
        'tamil_telugu_support': false,
        'family_care_dashboard': false,
        'cgm_pipeline': false,
        // Emergency kill switches (false = inactive / normal operation)
        'kill_switch_ai_routing': false,
        'kill_switch_whatsapp_logging': false,
        'kill_switch_external_providers': false,
      },
      plans: const [
        SubscriptionPlan(
          id: 'yogi_free',
          displayName: 'Yogi Free',
          priceInRupees: 0,
          cadence: BillingCadence.free,
          entitlements: [
            'manual_logging',
            'steps',
            'basic_wellness',
            'offline_cache',
          ],
        ),
        SubscriptionPlan(
          id: 'karma_pro_monthly',
          displayName: 'Karma Pro Monthly',
          priceInRupees: 149,
          cadence: BillingCadence.monthly,
          entitlements: [
            'whatsapp_voice',
            'ai_meal_analysis',
            'full_indian_recipes',
            'dynamic_tdee',
            'ad_free',
          ],
        ),
        SubscriptionPlan(
          id: 'karma_pro_yearly',
          displayName: 'Karma Pro Annual',
          priceInRupees: 1499,
          cadence: BillingCadence.yearly,
          entitlements: [
            'whatsapp_voice',
            'ai_meal_analysis',
            'full_indian_recipes',
            'dynamic_tdee',
            'ad_free',
          ],
        ),
        SubscriptionPlan(
          id: 'fitkarma_elite_monthly',
          displayName: 'FitKarma Elite',
          priceInRupees: 1999,
          cadence: BillingCadence.monthly,
          entitlements: [
            'karma_pro_features',
            'clinical_dossier',
            'priority_coaching',
            'metabolic_tracking',
          ],
        ),
        SubscriptionPlan(
          id: 'sachet_sprint_7d',
          displayName: '7-Day Metabolic Reset Sachet',
          priceInRupees: 49,
          cadence: BillingCadence.oneTime,
          entitlements: ['targeted_7d_report'],
        ),
      ],
    );
  }

  factory RemoteConfig.fromJson(Map<String, dynamic> json) {
    // Assert no server secrets are present in incoming payload
    _assertNoSecrets(json);

    final version = json['version'] as String? ?? '1.0.0';
    final fetchedAtRaw = json['fetched_at'] as String?;
    final fetchedAt = fetchedAtRaw != null
        ? DateTime.tryParse(fetchedAtRaw) ?? DateTime.now().toUtc()
        : DateTime.now().toUtc();

    final flagsMap =
        (json['feature_flags'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v == true),
        ) ??
        const {};

    final plansList =
        (json['plans'] as List<dynamic>?)
            ?.map((p) => SubscriptionPlan.fromJson(p as Map<String, dynamic>))
            .toList() ??
        const [];

    return RemoteConfig(
      version: version,
      fetchedAt: fetchedAt,
      featureFlags: flagsMap,
      plans: plansList,
    );
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'fetched_at': fetchedAt.toIso8601String(),
    'feature_flags': featureFlags,
    'plans': plans.map((p) => p.toJson()).toList(),
  };

  static void _assertNoSecrets(Map<String, dynamic> map) {
    for (final key in map.keys) {
      final lk = key.toLowerCase();
      if (lk.contains('secret') ||
          lk.contains('service_role') ||
          lk.contains('private_key')) {
        throw const SecurityViolationException(
          'Remote config payload contains prohibited secret keys.',
        );
      }
    }
  }
}
