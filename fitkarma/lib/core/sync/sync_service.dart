import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pocketbase/pocketbase.dart';

import '../constants/app_constants.dart';
import '../network/pocketbase_client.dart';
import '../storage/hive_service.dart';

/// Represents a queued synchronization action
class SyncAction {
  final String id;
  final String collection;
  final String operation; // 'create', 'update', 'delete'
  final Map<String, dynamic> data;
  final String recordId;
  final int retryCount;
  final DateTime createdAt;

  SyncAction({
    required this.id,
    required this.collection,
    required this.operation,
    required this.data,
    required this.recordId,
    this.retryCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'collection': collection,
        'operation': operation,
        'data': data,
        'recordId': recordId,
        'retryCount': retryCount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SyncAction.fromJson(Map<String, dynamic> json) => SyncAction(
        id: json['id'],
        collection: json['collection'],
        operation: json['operation'],
        data: Map<String, dynamic>.from(json['data']),
        recordId: json['recordId'],
        retryCount: json['retryCount'] ?? 0,
        createdAt: DateTime.parse(json['createdAt']),
      );

  SyncAction copyWith({int? retryCount}) {
    return SyncAction(
      id: id,
      collection: collection,
      operation: operation,
      data: data,
      recordId: recordId,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt,
    );
  }
}

/// A service to watch for connectivity transitions and sync local data from Hive -> PocketBase
class SyncService {
  final Ref _ref;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  // Maximum number of retries per action
  static const int _maxRetries = 5;

  SyncService(this._ref) {
    _init();
  }

  void _init() {
    // Listen to network changes
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        // We're online, trigger sync
        sync();
      }
    });

    // Check initial state and potentially sync immediately
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    if (results.isNotEmpty && results.first != ConnectivityResult.none) {
      sync();
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Add a local mutation event to the Sync Queue for remote consistency
  Future<void> enqueueAction({
    required String collection,
    required String operation,
    required Map<String, dynamic> data,
    String recordId = '',
  }) async {
    final action = SyncAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      collection: collection,
      operation: operation,
      data: data,
      recordId: recordId,
    );

    final box = HiveService.syncQueueBox;
    await box.put(action.id, action.toJson());

    // Attempt to sync immediately
    sync();
  }

  /// Process the event sync queue sequentially
  Future<void> sync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pb = _ref.read(pocketBaseProvider);
      final box = HiveService.syncQueueBox;
      final keys = box.keys.toList();

      for (final key in keys) {
        final Map<dynamic, dynamic>? rawAction = box.get(key);
        if (rawAction == null) continue;

        final Map<String, dynamic> actionMap =
            Map<String, dynamic>.from(rawAction);
        final action = SyncAction.fromJson(actionMap);

        bool success = await _executeAction(pb, action);

        if (success) {
          // Remove from queue
          await box.delete(key);
        } else {
          // Exponential backoff or dropping
          if (action.retryCount >= _maxRetries) {
            // Drop it, exceeded retries
            await box.delete(key);
          } else {
            // Update retry count and re-save
            final updatedAction =
                action.copyWith(retryCount: action.retryCount + 1);
            await box.put(key, updatedAction.toJson());

            // Apply exponential backoff delay before continuing the whole queue
            final delaySeconds =
                1 << updatedAction.retryCount; // 2, 4, 8, 16, 32...
            await Future.delayed(Duration(seconds: delaySeconds));
          }
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Internal engine method resolving one action mapping
  Future<bool> _executeAction(PocketBase pb, SyncAction action) async {
    try {
      switch (action.operation) {
        case 'create':
          await pb.collection(action.collection).create(body: action.data);
          return true;
        case 'update':
          if (action.recordId.isEmpty) return false;
          await pb
              .collection(action.collection)
              .update(action.recordId, body: action.data);
          return true;
        case 'delete':
          if (action.recordId.isEmpty) return false;
          await pb.collection(action.collection).delete(action.recordId);
          return true;
        default:
          return false;
      }
    } on ClientException catch (e) {
      // If it's auth failure, stop syncing the whole queue
      if (e.statusCode == 401 || e.statusCode == 403) {
        // Not a success, but we shouldn't necessarily increment retry blindly
        // depending on whether the user logs out.
        return false;
      }

      // If client-wins resolution, log conflicts but typically we overwrite servers.
      return false;
    } catch (_) {
      return false;
    }
  }
}

/// Riverpod provider
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});
