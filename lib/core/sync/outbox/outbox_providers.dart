import 'package:fitkarma/core/database/database_providers.dart';
import 'package:fitkarma/core/sync/outbox/outbox_queue.dart';
import 'package:fitkarma/core/sync/outbox/outbox_queue_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the generic offline [IOutboxQueue] sync foundation.
final outboxQueueProvider = Provider<IOutboxQueue>((ref) {
  final dao = ref.watch(syncOutboxDaoProvider);
  return OutboxQueueImpl(dao: dao);
}, name: 'outboxQueueProvider');
