import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/auth_provider.dart';
import '../network/pocketbase_client.dart';

class NotificationService {
  final Ref _ref;
  final _controller = StreamController<NotificationEvent>.broadcast();
  bool _isSubscribed = false;

  NotificationService(this._ref) {
    _init();
  }

  Stream<NotificationEvent> get notifications => _controller.stream;

  void _init() {
    // Watch auth state to subscribe/unsubscribe
    _ref.listen(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated && next.user != null) {
        _subscribeToNotifications(next.user!.id);
      } else {
        _unsubscribe();
      }
    }, fireImmediately: true);
  }

  void _subscribeToNotifications(String userId) async {
    if (_isSubscribed) return;

    try {
      final pb = _ref.read(pocketBaseProvider);

      await pb.collection('notifications').subscribe('*', (e) {
        if (e.record != null && e.record!.data['user_id'] == userId) {
          _controller.add(NotificationEvent.fromJson(e.record!.toJson()));
        }
      });
      _isSubscribed = true;
    } catch (e) {
      // ignore: avoid_print
      print('Error subscribing to notifications: $e');
    }
  }

  Future<void> _unsubscribe() async {
    if (!_isSubscribed) return;

    try {
      final pb = _ref.read(pocketBaseProvider);
      await pb.collection('notifications').unsubscribe('*');
      _isSubscribed = false;
    } catch (e) {
      // ignore: avoid_print
      print('Error unsubscribing from notifications: $e');
    }
  }

  void dispose() {
    _unsubscribe();
    _controller.close();
  }
}

class NotificationEvent {
  final String id;
  final String title;
  final String message;
  final String type;

  NotificationEvent({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
  });

  factory NotificationEvent.fromJson(Map<String, dynamic> json) {
    return NotificationEvent(
      id: json['id'],
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});

final notificationStreamProvider = StreamProvider<NotificationEvent>((ref) {
  return ref.watch(notificationServiceProvider).notifications;
});
