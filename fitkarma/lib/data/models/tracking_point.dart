import 'package:hive/hive.dart';

part 'tracking_point.g.dart';

@HiveType(typeId: 7)
class TrackingPoint extends HiveObject {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final double? altitude;

  @HiveField(4)
  final double? speed;

  TrackingPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.altitude,
    this.speed,
  });

  Map<String, dynamic> toJson() => {
        'lat': latitude,
        'lng': longitude,
        'time': timestamp.toIso8601String(),
        'alt': altitude,
        'spd': speed,
      };

  factory TrackingPoint.fromJson(Map<String, dynamic> json) => TrackingPoint(
        latitude: json['lat'],
        longitude: json['lng'],
        timestamp: DateTime.parse(json['time']),
        altitude: json['alt'],
        speed: json['spd'],
      );
}
