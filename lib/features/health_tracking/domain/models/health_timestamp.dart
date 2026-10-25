/// Represents a normalized point-in-time observation timestamp with timezone awareness.
class HealthTimestamp {
  final DateTime dateTime;
  final Duration? timeZoneOffset;

  const HealthTimestamp({
    required this.dateTime,
    this.timeZoneOffset,
  });

  factory HealthTimestamp.now({Duration? timeZoneOffset}) {
    final now = DateTime.now();
    return HealthTimestamp(
      dateTime: now,
      timeZoneOffset: timeZoneOffset ?? now.timeZoneOffset,
    );
  }

  factory HealthTimestamp.fromDateTime(DateTime dt) {
    return HealthTimestamp(
      dateTime: dt,
      timeZoneOffset: dt.timeZoneOffset,
    );
  }

  Map<String, dynamic> toJson() => {
        'date_time': dateTime.toIso8601String(),
        if (timeZoneOffset != null)
          'timezone_offset_minutes': timeZoneOffset!.inMinutes,
      };

  factory HealthTimestamp.fromJson(Map<String, dynamic> json) {
    return HealthTimestamp(
      dateTime: DateTime.parse(json['date_time'] as String),
      timeZoneOffset: json['timezone_offset_minutes'] != null
          ? Duration(minutes: json['timezone_offset_minutes'] as int)
          : null,
    );
  }

  String toIso8601String() => dateTime.toIso8601String();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthTimestamp &&
          other.dateTime.isAtSameMomentAs(dateTime) &&
          other.timeZoneOffset == timeZoneOffset;

  @override
  int get hashCode => Object.hash(dateTime.millisecondsSinceEpoch, timeZoneOffset);

  @override
  String toString() => dateTime.toIso8601String();
}

/// Represents an observation spanning an interval/duration (e.g. sleep sessions, walking intervals).
class HealthTimeRange {
  final DateTime start;
  final DateTime end;

  HealthTimeRange({
    required this.start,
    required this.end,
  }) {
    if (end.isBefore(start)) {
      throw ArgumentError('TimeRange end ($end) cannot be before start ($start)');
    }
  }

  Duration get duration => end.difference(start);
  int get durationMinutes => duration.inMinutes;
  int get durationSeconds => duration.inSeconds;

  bool contains(DateTime dt) =>
      (dt.isAtSameMomentAs(start) || dt.isAfter(start)) &&
      (dt.isAtSameMomentAs(end) || dt.isBefore(end));

  Map<String, dynamic> toJson() => {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };

  factory HealthTimeRange.fromJson(Map<String, dynamic> json) {
    return HealthTimeRange(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthTimeRange &&
          other.start.isAtSameMomentAs(start) &&
          other.end.isAtSameMomentAs(end);

  @override
  int get hashCode => Object.hash(
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      );

  @override
  String toString() => '${start.toIso8601String()} -> ${end.toIso8601String()} (${durationMinutes}m)';
}
