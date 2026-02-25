import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/tracking_point.dart';

enum TrackingStatus { idle, tracking, paused }

class GPSState {
  final List<TrackingPoint> path;
  final TrackingStatus status;
  final double totalDistance; // in meters
  final Duration duration;
  final String? error;

  GPSState({
    this.path = const [],
    this.status = TrackingStatus.idle,
    this.totalDistance = 0,
    this.duration = Duration.zero,
    this.error,
  });

  GPSState copyWith({
    List<TrackingPoint>? path,
    TrackingStatus? status,
    double? totalDistance,
    Duration? duration,
    String? error,
  }) {
    return GPSState(
      path: path ?? this.path,
      status: status ?? this.status,
      totalDistance: totalDistance ?? this.totalDistance,
      duration: duration ?? this.duration,
      error: error,
    );
  }
}

class GPSNotifier extends StateNotifier<GPSState> {
  StreamSubscription<Position>? _positionSubscription;
  Timer? _timer;

  GPSNotifier() : super(GPSState());

  Future<void> startTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(error: 'Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        state = state.copyWith(error: 'Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      state =
          state.copyWith(error: 'Location permissions are permanently denied.');
      return;
    }

    state = state.copyWith(
        status: TrackingStatus.tracking,
        path: [],
        totalDistance: 0,
        duration: Duration.zero);

    _startTimer();

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // minimum change in meters
      ),
    ).listen((Position position) {
      _onPositionUpdate(position);
    });
  }

  void _onPositionUpdate(Position position) {
    if (state.status != TrackingStatus.tracking) return;

    final newPoint = TrackingPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
      altitude: position.altitude,
      speed: position.speed,
    );

    double addedDistance = 0;
    if (state.path.isNotEmpty) {
      final lastPoint = state.path.last;
      addedDistance = Geolocator.distanceBetween(
        lastPoint.latitude,
        lastPoint.longitude,
        newPoint.latitude,
        newPoint.longitude,
      );
    }

    state = state.copyWith(
      path: [...state.path, newPoint],
      totalDistance: state.totalDistance + addedDistance,
    );
  }

  void pauseTracking() {
    if (state.status == TrackingStatus.tracking) {
      state = state.copyWith(status: TrackingStatus.paused);
      _timer?.cancel();
    }
  }

  void resumeTracking() {
    if (state.status == TrackingStatus.paused) {
      state = state.copyWith(status: TrackingStatus.tracking);
      _startTimer();
    }
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _timer?.cancel();
    state = state.copyWith(status: TrackingStatus.idle);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state =
          state.copyWith(duration: state.duration + const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}

final gpsProvider = StateNotifierProvider<GPSNotifier, GPSState>((ref) {
  return GPSNotifier();
});
