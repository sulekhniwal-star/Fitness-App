import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/notification_service.dart';
import '../../../core/theme/app_theme.dart';

class NotificationCentreScreen extends ConsumerStatefulWidget {
  const NotificationCentreScreen({super.key});

  @override
  ConsumerState<NotificationCentreScreen> createState() =>
      _NotificationCentreScreenState();
}

class _NotificationCentreScreenState
    extends ConsumerState<NotificationCentreScreen> {
  final List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final service = ref.read(notificationServiceProvider);
    final notifications = await service.getNotifications();
    setState(() {
      _notifications.clear();
      _notifications.addAll(notifications);
    });
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'karma':
        return Icons.stars;
      case 'challenge':
        return Icons.emoji_events;
      case 'social':
        return Icons.people;
      case 'warning':
        return Icons.warning_amber;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'karma':
        return AppTheme.saffronColor;
      case 'challenge':
        return AppTheme.accentColor;
      case 'social':
        return AppTheme.secondaryColor;
      case 'warning':
        return AppTheme.warningColor;
      case 'system':
        return Colors.grey;
      default:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to stream and accumulate new notifications
    ref.listen(notificationServiceProvider.select((s) => s.notificationStream),
        (previous, next) {
      next.listen((notification) {
        if (mounted) {
          setState(() => _notifications.insert(0, notification));
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _notifications.clear()),
              child: const Text(
                'Clear all',
                style: TextStyle(color: AppTheme.errorColor),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = _notifications[index];
                return _buildNotificationTile(n);
              },
            ),
    );
  }

  Widget _buildNotificationTile(AppNotification n) {
    final color = _colorFor(n.type);
    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.errorColor,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        final service = ref.read(notificationServiceProvider);
        await service.deleteNotification(n.id);
        setState(() => _notifications.removeWhere((e) => e.id == n.id));
      },
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(_iconFor(n.type), color: color, size: 22),
        ),
        title: Text(
          n.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          n.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: n.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () async {
          if (!n.isRead) {
            final service = ref.read(notificationServiceProvider);
            await service.markAsRead(n.id);
            setState(() {
              final index = _notifications.indexWhere((e) => e.id == n.id);
              if (index != -1) {
                _notifications[index] = AppNotification(
                  id: n.id,
                  title: n.title,
                  body: n.body,
                  type: n.type,
                  isRead: true,
                  createdAt: n.createdAt,
                  data: n.data,
                );
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'New notifications will appear here.',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
