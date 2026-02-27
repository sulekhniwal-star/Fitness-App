import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../core/network/pocketbase_client.dart';
import '../../data/providers/auth_provider.dart';

/// Notification model for PocketBase
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type = 'general',
    this.isRead = false,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromRecord(RecordModel record) {
    final data = record.data;
    return AppNotification(
      id: record.id,
      title: data['title'] as String? ?? 'Notification',
      body: data['body'] as String? ?? '',
      type: data['type'] as String? ?? 'general',
      isRead: data['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(record.get<String>('created')),
      data: data['metadata'] as Map<String, dynamic>?,
    );
  }

}

/// Service to handle PocketBase notifications with polling
class NotificationService {
  final Ref _ref;
  Timer? _pollingTimer;
  final _notificationController = StreamController<AppNotification>.broadcast();
  String? _lastNotificationId;
  bool _isInitialized = false;

  NotificationService(this._ref) {
    _init();
  }

  Stream<AppNotification> get notificationStream => _notificationController.stream;

  void _init() {
    // Listen to auth state changes
    _ref.listen(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated && next.user != null) {
        _startPolling(next.user!.id);
      } else {
        _stopPolling();
      }
    });
  }

  void _startPolling(String userId) {
    if (_isInitialized) return;
    _isInitialized = true;

    // Initial fetch
    _fetchNewNotifications(userId);

    // Poll every 30 seconds for new notifications
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchNewNotifications(userId);
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isInitialized = false;
  }

  Future<void> _fetchNewNotifications(String userId) async {
    try {
      final pb = _ref.read(pocketBaseProvider);
      final result = await pb.collection('notifications').getList(
        perPage: 5,
        filter: 'user = "$userId" && is_read = false',
        sort: '-created',
      );

      for (final record in result.items) {
        // Skip if we've already seen this notification
        if (_lastNotificationId != null && record.id == _lastNotificationId) {
          continue;
        }

        _lastNotificationId = record.id;
        final notification = AppNotification.fromRecord(record);
        _notificationController.add(notification);
        _showLocalNotification(notification);
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  void _showLocalNotification(AppNotification notification) {
    // Show in-app notification banner
    debugPrint('📬 Notification: ${notification.title} - ${notification.body}');
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final pb = _ref.read(pocketBaseProvider);
      await pb.collection('notifications').update(notificationId, body: {
        'is_read': true,
      });
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Get all notifications for current user
  Future<List<AppNotification>> getNotifications({int page = 1, int perPage = 20}) async {
    try {
      final user = _ref.read(authStateProvider).user;
      if (user == null) return [];

      final pb = _ref.read(pocketBaseProvider);
      final result = await pb.collection('notifications').getList(
        page: page,
        perPage: perPage,
        filter: 'user = "${user.id}"',
        sort: '-created',
      );

      return result.items.map((r) => AppNotification.fromRecord(r)).toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    try {
      final user = _ref.read(authStateProvider).user;
      if (user == null) return 0;

      final pb = _ref.read(pocketBaseProvider);
      final result = await pb.collection('notifications').getList(
        filter: 'user = "${user.id}" && is_read = false',
      );

      return result.totalItems;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final pb = _ref.read(pocketBaseProvider);
      await pb.collection('notifications').delete(notificationId);
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  void dispose() {
    _stopPolling();
    _notificationController.close();
  }
}

/// Riverpod provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for unread notification count
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return await service.getUnreadCount();
});
