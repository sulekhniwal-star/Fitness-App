import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  Mixpanel? _mixpanel;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      // Use a dummy token for now, resolve safely without hard crashes
      const mixpanelToken = "DUMMY_TOKEN";

      if (mixpanelToken != "DUMMY_TOKEN") {
        _mixpanel =
            await Mixpanel.init(mixpanelToken, trackAutomaticEvents: true);
      }
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Mixpanel initialization failed: $e');
      }
    }
  }

  void trackEvent(String name, {Map<String, dynamic>? properties}) {
    if (!_initialized) return;

    if (kDebugMode) {
      // ignore: avoid_print
      print('Analytics: Track $name $properties');
    }

    _mixpanel?.track(name, properties: properties);
  }

  void setUserProperties(String userId, {Map<String, dynamic>? properties}) {
    if (!_initialized) return;

    _mixpanel?.identify(userId);
    if (properties != null) {
      properties.forEach((key, value) {
        _mixpanel?.getPeople().set(key, value);
      });
    }
  }
}

final analyticsService = AnalyticsService();
