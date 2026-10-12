import 'package:fitkarma/core/sync/repository/sync_entity.dart';

/// Outcomes produced by a [ConflictResolutionStrategy].
enum ConflictResolutionType {
  /// The local modification takes precedence and must be pushed to remote.
  localWins,

  /// The remote modification takes precedence and overwrites local state.
  remoteWins,

  /// A blended or custom merged entity was produced.
  merge,

  /// Conflict cannot be resolved automatically and must be reported for user/UI intervention.
  conflictReported,
}

/// The structured result of evaluating a conflict between local and remote entity states.
class ConflictResolution<T extends SyncEntity> {
  final ConflictResolutionType type;
  final T? resolvedEntity;
  final String reason;
  final Map<String, dynamic>? conflictDetails;

  const ConflictResolution({
    required this.type,
    this.resolvedEntity,
    required this.reason,
    this.conflictDetails,
  });

  factory ConflictResolution.localWins(T localEntity, {String? reason}) {
    return ConflictResolution(
      type: ConflictResolutionType.localWins,
      resolvedEntity: localEntity,
      reason: reason ?? 'Local modification is newer than remote state.',
    );
  }

  factory ConflictResolution.remoteWins(T remoteEntity, {String? reason}) {
    return ConflictResolution(
      type: ConflictResolutionType.remoteWins,
      resolvedEntity: remoteEntity,
      reason: reason ?? 'Remote modification is newer than local state.',
    );
  }

  factory ConflictResolution.merge(T mergedEntity, {required String reason}) {
    return ConflictResolution(
      type: ConflictResolutionType.merge,
      resolvedEntity: mergedEntity,
      reason: reason,
    );
  }

  factory ConflictResolution.conflictReported({
    required T localEntity,
    required T remoteEntity,
    required String reason,
    Map<String, dynamic>? extraDetails,
  }) {
    return ConflictResolution(
      type: ConflictResolutionType.conflictReported,
      resolvedEntity: localEntity,
      reason: reason,
      conflictDetails: {
        'error_code': 'FK-3003',
        'local_entity': localEntity.toRemoteJson(),
        'remote_entity': remoteEntity.toRemoteJson(),
        'local_updated_at': localEntity.syncUpdatedAt.toIso8601String(),
        'remote_updated_at': remoteEntity.syncUpdatedAt.toIso8601String(),
        ...?extraDetails,
      },
    );
  }

  bool get isLocalWins => type == ConflictResolutionType.localWins;
  bool get isRemoteWins => type == ConflictResolutionType.remoteWins;
  bool get isMerge => type == ConflictResolutionType.merge;
  bool get isConflictReported => type == ConflictResolutionType.conflictReported;
}

/// Contract interface for resolving concurrent mutation conflicts between Drift and Supabase.
abstract interface class ConflictResolutionStrategy<T extends SyncEntity> {
  ConflictResolution<T> resolve({
    required T localEntity,
    required T remoteEntity,
  });
}

/// Timestamp-based Last-Write-Wins (LWW) resolution strategy.
///
/// Compares [SyncEntity.syncUpdatedAt] between the local and remote copies.
/// The modification with the more recent timestamp wins. In the event of an exact
/// tie, [preferRemoteOnTie] determines whether the remote state takes precedence.
class TimestampLastWriteWinsStrategy<T extends SyncEntity>
    implements ConflictResolutionStrategy<T> {
  final bool preferRemoteOnTie;

  const TimestampLastWriteWinsStrategy({this.preferRemoteOnTie = true});

  @override
  ConflictResolution<T> resolve({
    required T localEntity,
    required T remoteEntity,
  }) {
    final localTime = localEntity.syncUpdatedAt;
    final remoteTime = remoteEntity.syncUpdatedAt;

    if (remoteTime.isAfter(localTime)) {
      return ConflictResolution.remoteWins(
        remoteEntity,
        reason:
            'Remote timestamp (${remoteTime.toIso8601String()}) is after local timestamp (${localTime.toIso8601String()}).',
      );
    } else if (localTime.isAfter(remoteTime)) {
      return ConflictResolution.localWins(
        localEntity,
        reason:
            'Local timestamp (${localTime.toIso8601String()}) is after remote timestamp (${remoteTime.toIso8601String()}).',
      );
    } else {
      // Exact timestamp tie
      if (preferRemoteOnTie) {
        return ConflictResolution.remoteWins(
          remoteEntity,
          reason: 'Identical timestamps; remote state preferred by tie-breaker.',
        );
      } else {
        return ConflictResolution.localWins(
          localEntity,
          reason: 'Identical timestamps; local state preferred by tie-breaker.',
        );
      }
    }
  }
}

/// Version/revision counter-based conflict strategy.
///
/// Compares [SyncEntity.syncVersion]. Higher version wins.
class VersionConflictStrategy<T extends SyncEntity>
    implements ConflictResolutionStrategy<T> {
  final ConflictResolutionStrategy<T> fallbackStrategy;

  const VersionConflictStrategy({
    this.fallbackStrategy = const TimestampLastWriteWinsStrategy(),
  });

  @override
  ConflictResolution<T> resolve({
    required T localEntity,
    required T remoteEntity,
  }) {
    final localVer = localEntity.syncVersion;
    final remoteVer = remoteEntity.syncVersion;

    if (localVer != null && remoteVer != null) {
      if (remoteVer > localVer) {
        return ConflictResolution.remoteWins(
          remoteEntity,
          reason: 'Remote version ($remoteVer) is greater than local version ($localVer).',
        );
      } else if (localVer > remoteVer) {
        return ConflictResolution.localWins(
          localEntity,
          reason: 'Local version ($localVer) is greater than remote version ($remoteVer).',
        );
      }
    }

    // If versions are equal or missing, delegate to fallback strategy
    return fallbackStrategy.resolve(
      localEntity: localEntity,
      remoteEntity: remoteEntity,
    );
  }
}

/// Strategy that always resolves conflicts by retaining the local client state.
class ClientWinsStrategy<T extends SyncEntity>
    implements ConflictResolutionStrategy<T> {
  const ClientWinsStrategy();

  @override
  ConflictResolution<T> resolve({
    required T localEntity,
    required T remoteEntity,
  }) {
    return ConflictResolution.localWins(
      localEntity,
      reason: 'Client-wins strategy unconditionally preserves local mutation.',
    );
  }
}

/// Strategy that always resolves conflicts by accepting the remote server state.
class ServerWinsStrategy<T extends SyncEntity>
    implements ConflictResolutionStrategy<T> {
  const ServerWinsStrategy();

  @override
  ConflictResolution<T> resolve({
    required T localEntity,
    required T remoteEntity,
  }) {
    return ConflictResolution.remoteWins(
      remoteEntity,
      reason: 'Server-wins strategy unconditionally accepts remote state.',
    );
  }
}

/// Strategy that never silently overwrites concurrent changes and reports
/// a conflict with code FK-3003 for manual reconciliation.
class ManualConflictStrategy<T extends SyncEntity>
    implements ConflictResolutionStrategy<T> {
  const ManualConflictStrategy();

  @override
  ConflictResolution<T> resolve({
    required T localEntity,
    required T remoteEntity,
  }) {
    return ConflictResolution.conflictReported(
      localEntity: localEntity,
      remoteEntity: remoteEntity,
      reason:
          'Concurrent modification detected. Manual reconciliation required (FK-3003).',
    );
  }
}
