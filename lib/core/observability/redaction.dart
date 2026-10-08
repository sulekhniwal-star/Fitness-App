/// Enterprise-grade data redactor enforcing DPDP and health data privacy.
///
/// Strips credentials, auth tokens, payment data, sensitive health observations,
/// and personal identifiable information (PII) from logs, events, and diagnostics.
class DataRedactor {
  const DataRedactor();

  static const String redactedPlaceholder = '[REDACTED]';

  /// Key substring matches that trigger automatic redaction.
  static const Set<String> sensitiveKeySubstrings = {
    // Auth & Security
    'password',
    'secret',
    'token',
    'key',
    'pin',
    'otp',
    'auth',
    'bearer',
    'credential',
    'private',
    'session',
    // Payments
    'cvv',
    'card',
    'account',
    'bank',
    'vpa',
    'mandate',
    'upi',
    // Health (Raw sensitive observations that must not enter logging/analytics)
    'glucose',
    'blood_pressure',
    'systolic',
    'diastolic',
    'heart_rate',
    'hrv',
    'medication',
    'diagnosis',
    'condition',
    'symptom',
    'period',
    'cycle',
    'weight',
    // PII
    'email',
    'phone',
    'mobile',
    'aadhaar',
    'pan',
    'address',
    'name',
  };

  /// Regex patterns for inline string masking.
  static final RegExp _emailRegex = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b',
  );

  static final RegExp _phoneRegex = RegExp(r'(?:\+?91[\s-]?)?[6-9]\d{9}\b');

  static final RegExp _bearerTokenRegex = RegExp(
    r'Bearer\s+[A-Za-z0-9\-._~+/]+=*',
    caseSensitive: false,
  );

  /// Recursively sanitizes any value (Map, List, String, primitive).
  dynamic redact(dynamic value, {String? keyName}) {
    if (value == null) return null;

    if (keyName != null && isKeySensitive(keyName)) {
      return redactedPlaceholder;
    }

    if (value is Map<String, dynamic>) {
      return redactMap(value);
    } else if (value is Map) {
      final castMap = value.map((k, v) => MapEntry(k.toString(), v));
      return redactMap(castMap);
    } else if (value is Iterable) {
      return value.map((item) => redact(item)).toList();
    } else if (value is String) {
      return redactString(value);
    }

    return value;
  }

  /// Sanitizes a key-value map.
  Map<String, dynamic> redactMap(Map<String, dynamic> map) {
    final sanitized = <String, dynamic>{};

    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value;

      if (isKeySensitive(key)) {
        sanitized[key] = redactedPlaceholder;
      } else {
        sanitized[key] = redact(value, keyName: key);
      }
    }

    return sanitized;
  }

  /// Masks inline emails, phone numbers, and bearer tokens in raw text.
  String redactString(String input) {
    var result = input;
    result = result.replaceAll(
      _bearerTokenRegex,
      'Bearer $redactedPlaceholder',
    );
    result = result.replaceAll(_emailRegex, redactedPlaceholder);
    result = result.replaceAll(_phoneRegex, redactedPlaceholder);
    return result;
  }

  /// Returns true if a key name matches any known sensitive classification.
  bool isKeySensitive(String key) {
    final normalized = key.toLowerCase().trim();
    for (final pattern in sensitiveKeySubstrings) {
      if (normalized.contains(pattern)) {
        return true;
      }
    }
    return false;
  }
}
