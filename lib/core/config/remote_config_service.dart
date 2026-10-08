import 'dart:convert';

import 'package:fitkarma/core/config/remote_config.dart';

/// Storage boundary interface for persisting last-known remote config offline.
abstract interface class ConfigCacheStorage {
  Future<String?> readConfig();
  Future<void> writeConfig(String rawJson);
}

/// In-memory cache storage implementation for testing and initial fallback.
class InMemoryConfigCacheStorage implements ConfigCacheStorage {
  String? _cache;

  InMemoryConfigCacheStorage([this._cache]);

  @override
  Future<String?> readConfig() async => _cache;

  @override
  Future<void> writeConfig(String rawJson) async {
    _cache = rawJson;
  }
}

/// Remote configuration and feature-flag service.
///
/// Ensures pricing, plans, feature entitlements, and kill switches are
/// dynamic and backend-driven with offline resilience.
class RemoteConfigService {
  final ConfigCacheStorage cacheStorage;
  RemoteConfig _activeConfig = RemoteConfig.defaults();
  bool _isInitialized = false;

  RemoteConfigService({ConfigCacheStorage? cacheStorage})
    : cacheStorage = cacheStorage ?? InMemoryConfigCacheStorage();

  bool get isInitialized => _isInitialized;
  RemoteConfig get activeConfig => _activeConfig;

  /// Initializes the service by restoring cached configuration or applying safe defaults.
  Future<void> initialize() async {
    try {
      final cachedRaw = await cacheStorage.readConfig();
      if (cachedRaw != null && cachedRaw.trim().isNotEmpty) {
        final decoded = jsonDecode(cachedRaw) as Map<String, dynamic>;
        _activeConfig = RemoteConfig.fromJson(decoded);
      } else {
        _activeConfig = RemoteConfig.defaults();
      }
    } catch (_) {
      // In case of corrupt cache, fall back to safe deterministic defaults
      _activeConfig = RemoteConfig.defaults();
    }
    _isInitialized = true;
  }

  /// Updates and activates a new configuration payload, persisting it to cache.
  Future<void> activate(RemoteConfig newConfig) async {
    _activeConfig = newConfig;
    try {
      await cacheStorage.writeConfig(jsonEncode(newConfig.toJson()));
    } catch (_) {
      // Cache persistence failure must not prevent active configuration usage
    }
  }

  /// Checks whether a feature flag is enabled.
  ///
  /// Returns false by default if unknown or unconfigured.
  bool isFeatureEnabled(String flagKey) {
    // If a related emergency kill switch is active, immediately disable feature
    if (_isRelatedKillSwitchActive(flagKey)) {
      return false;
    }
    return _activeConfig.featureFlags[flagKey] ?? false;
  }

  /// Checks if an emergency kill switch is active.
  bool isKillSwitchActive(String killSwitchKey) {
    return _activeConfig.featureFlags[killSwitchKey] ?? false;
  }

  /// Returns all available subscription tiers.
  List<SubscriptionPlan> getAvailablePlans() {
    return List.unmodifiable(_activeConfig.plans);
  }

  /// Finds a specific subscription plan by ID.
  SubscriptionPlan? getPlanById(String planId) {
    for (final plan in _activeConfig.plans) {
      if (plan.id == planId) return plan;
    }
    return null;
  }

  bool _isRelatedKillSwitchActive(String flagKey) {
    if (flagKey.contains('ai') &&
        isKillSwitchActive('kill_switch_ai_routing')) {
      return true;
    }
    if (flagKey.contains('whatsapp') &&
        isKillSwitchActive('kill_switch_whatsapp_logging')) {
      return true;
    }
    if ((flagKey.contains('cgm') || flagKey.contains('aqi')) &&
        isKillSwitchActive('kill_switch_external_providers')) {
      return true;
    }
    return false;
  }
}
