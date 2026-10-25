import 'package:fitkarma/features/health_tracking/domain/models/health_types.dart';

/// Explicit confidence representation for health observations.
class HealthConfidence {
  /// Qualitative classification category.
  final HealthConfidenceLevel level;

  /// Numeric confidence score clamped between 0.0 (zero confidence) and 1.0 (verified).
  final double score;

  /// Whether the user has explicitly verified or confirmed this measurement.
  final bool isUserVerified;

  /// Optional calibration or reason notes explaining uncertainty.
  final String? notes;

  const HealthConfidence({
    required this.level,
    required this.score,
    this.isUserVerified = false,
    this.notes,
  });

  /// Factory for a clinically/device-verified reading.
  factory HealthConfidence.verified({String? notes}) {
    return HealthConfidence(
      level: HealthConfidenceLevel.verified,
      score: 1.0,
      isUserVerified: true,
      notes: notes,
    );
  }

  /// Factory for high-accuracy readings (e.g. optical wrist HR or step pedometer).
  factory HealthConfidence.high({String? notes}) {
    return HealthConfidence(
      level: HealthConfidenceLevel.high,
      score: HealthConfidenceLevel.high.defaultScore,
      notes: notes,
    );
  }

  /// Factory for medium-accuracy readings.
  factory HealthConfidence.medium({String? notes}) {
    return HealthConfidence(
      level: HealthConfidenceLevel.medium,
      score: HealthConfidenceLevel.medium.defaultScore,
      notes: notes,
    );
  }

  /// Factory for low-accuracy or approximate readings.
  factory HealthConfidence.low({String? notes}) {
    return HealthConfidence(
      level: HealthConfidenceLevel.low,
      score: HealthConfidenceLevel.low.defaultScore,
      notes: notes,
    );
  }

  /// Factory for unvalidated estimates.
  factory HealthConfidence.unvalidated({String? notes}) {
    return HealthConfidence(
      level: HealthConfidenceLevel.unvalidated,
      score: HealthConfidenceLevel.unvalidated.defaultScore,
      notes: notes,
    );
  }

  /// Returns a copy marked as user-verified.
  HealthConfidence markUserVerified({String? verificationNotes}) {
    return HealthConfidence(
      level: HealthConfidenceLevel.verified,
      score: 1.0,
      isUserVerified: true,
      notes: verificationNotes ?? notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'level': level.name,
        'score': score,
        'is_user_verified': isUserVerified,
        if (notes != null) 'notes': notes,
      };

  factory HealthConfidence.fromJson(Map<String, dynamic> json) {
    final score = (json['score'] as num?)?.toDouble() ?? 0.8;
    return HealthConfidence(
      level: json['level'] != null
          ? HealthConfidenceLevel.values.firstWhere(
              (e) => e.name == json['level'],
              orElse: () => HealthConfidenceLevel.fromScore(score),
            )
          : HealthConfidenceLevel.fromScore(score),
      score: score.clamp(0.0, 1.0),
      isUserVerified: json['is_user_verified'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthConfidence &&
          other.level == level &&
          (other.score - score).abs() < 1e-4 &&
          other.isUserVerified == isUserVerified &&
          other.notes == notes;

  @override
  int get hashCode => Object.hash(level, score.toStringAsFixed(2), isUserVerified, notes);

  @override
  String toString() => '${level.name} (${(score * 100).toInt()}%)';
}
