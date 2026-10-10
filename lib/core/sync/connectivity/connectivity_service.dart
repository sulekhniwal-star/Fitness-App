import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Contract interface for network connectivity monitoring.
abstract interface class IConnectivityService {
  /// Whether the device currently has active network connectivity.
  bool get isConnected;

  /// Reactive stream broadcasting network connectivity status transitions.
  Stream<bool> get onConnectivityChanged;

  /// Checks current network connectivity asynchronously.
  Future<bool> checkConnectivity();

  /// Cleans up any active connectivity listeners.
  void dispose();
}

/// Concrete implementation of [IConnectivityService] using connectivity_plus.
class ConnectivityServiceImpl implements IConnectivityService {
  final Connectivity _connectivity;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = true;

  ConnectivityServiceImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  void _init() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final connected = _isAnyConnected(results);
      if (_isConnected != connected) {
        _isConnected = connected;
        _controller.add(connected);
      }
    });
  }

  bool _isAnyConnected(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isConnected = _isAnyConnected(results);
    } catch (_) {
      _isConnected = false;
    }
    return _isConnected;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}

/// Fake connectivity service for deterministic testing and offline simulation.
class FakeConnectivityService implements IConnectivityService {
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _isConnected;

  FakeConnectivityService({bool initialConnected = true})
      : _isConnected = initialConnected;

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  Future<bool> checkConnectivity() async => _isConnected;

  /// Programmatically toggles or sets connectivity state during tests.
  void setConnected(bool connected) {
    if (_isConnected != connected) {
      _isConnected = connected;
      _controller.add(connected);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}
