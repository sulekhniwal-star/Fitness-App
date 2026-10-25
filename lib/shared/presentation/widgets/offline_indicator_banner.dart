import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/core/sync/providers/sync_providers.dart';
import 'package:fitkarma/core/sync/sync_boundary.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_radii.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/app_button.dart';
import 'package:fitkarma/shared/presentation/widgets/conflict_resolution_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modal bottom sheet detailing the current connectivity state, sync status,
/// error diagnostics, and local storage safety guarantees.
class SyncFailureDetailsSheet extends StatelessWidget {
  final bool isOnline;
  final SyncStatus status;
  final int pendingCount;
  final String? errorCode;
  final String? errorMessage;
  final DateTime? lastSyncedAt;
  final VoidCallback? onRetry;
  final Map<String, dynamic>? conflictDetails;
  final VoidCallback? onReviewConflict;

  const SyncFailureDetailsSheet({
    super.key,
    required this.isOnline,
    required this.status,
    this.pendingCount = 0,
    this.errorCode,
    this.errorMessage,
    this.lastSyncedAt,
    this.onRetry,
    this.conflictDetails,
    this.onReviewConflict,
  });

  /// Displays the modal sheet modally.
  static Future<void> show(
    BuildContext context, {
    required bool isOnline,
    required SyncStatus status,
    int pendingCount = 0,
    String? errorCode,
    String? errorMessage,
    DateTime? lastSyncedAt,
    VoidCallback? onRetry,
    Map<String, dynamic>? conflictDetails,
    VoidCallback? onReviewConflict,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (ctx) => SyncFailureDetailsSheet(
        isOnline: isOnline,
        status: status,
        pendingCount: pendingCount,
        errorCode: errorCode,
        errorMessage: errorMessage,
        lastSyncedAt: lastSyncedAt,
        onRetry: onRetry,
        conflictDetails: conflictDetails,
        onReviewConflict: onReviewConflict,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.stringsOf(context);

    final statusColor = _resolveStatusColor();
    final statusText = _resolveStatusTitle(strings);
    final explanation = _resolveExplanation(strings);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: AppRadii.roundedFull,
                ),
              ),
            ),

            // Header Row
            Row(
              children: [
                Icon(
                  isOnline ? Icons.sync_rounded : Icons.cloud_off_rounded,
                  color: statusColor,
                  size: 26,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    strings.syncDetailsTitle,
                    style: AppTypography.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  tooltip: strings.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.roundedMd,
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            statusText,
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isOnline
                            ? strings.connectionOnline
                            : strings.connectionOffline,
                        style: AppTypography.labelSmall.copyWith(
                          color: isOnline
                              ? AppColors.primary
                              : AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (pendingCount > 0) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      strings.pendingSyncCount(pendingCount),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (errorCode != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Error Code: $errorCode',
                      style: AppTypography.bodySmall.copyWith(
                        fontFamily: 'monospace',
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Detailed Diagnostic / Explanation
            Text(
              explanation,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Local Data Safe Reassurance Box
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: AppRadii.roundedMd,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.security_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      strings.localDataSecureGuarantee,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: strings.cancel,
                    variant: AppButtonVariant.ghost,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                if (status == SyncStatus.conflict || errorCode == 'FK-3003') ...[
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: strings.reviewConflict,
                      variant: AppButtonVariant.primary,
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (onReviewConflict != null) {
                          onReviewConflict!();
                        } else if (conflictDetails != null) {
                          final localMap = (conflictDetails?['local_entity'] as Map<String, dynamic>?) ?? {};
                          final remoteMap = (conflictDetails?['remote_entity'] as Map<String, dynamic>?) ?? {};
                          ConflictResolutionSheet.show(
                            context,
                            entityTitle: conflictDetails?['entity_type']?.toString() ?? 'Conflicting Item',
                            localData: localMap,
                            serverData: remoteMap,
                          );
                        }
                      },
                    ),
                  ),
                ] else if (onRetry != null && isOnline) ...[
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: strings.syncNow,
                      variant: AppButtonVariant.primary,
                      isLoading: status == SyncStatus.syncing,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onRetry!();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _resolveStatusColor() {
    if (!isOnline) return AppColors.warning;
    switch (status) {
      case SyncStatus.syncing:
        return AppColors.primary;
      case SyncStatus.synced:
        return AppColors.primary;
      case SyncStatus.error:
        return AppColors.error;
      case SyncStatus.conflict:
        return AppColors.warning;
      case SyncStatus.idle:
        return pendingCount > 0 ? AppColors.warning : AppColors.primary;
    }
  }

  String _resolveStatusTitle(AppStrings strings) {
    if (!isOnline) return strings.offline;
    switch (status) {
      case SyncStatus.syncing:
        return strings.syncing;
      case SyncStatus.synced:
        return strings.synced;
      case SyncStatus.error:
        return strings.syncError;
      case SyncStatus.conflict:
        return strings.syncConflict;
      case SyncStatus.idle:
        return pendingCount > 0 ? strings.syncPending : strings.synced;
    }
  }

  String _resolveExplanation(AppStrings strings) {
    if (!isOnline) {
      return strings.offlinePreserved;
    }
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return errorMessage!;
    }
    if (errorCode == 'FK-3001') {
      return strings.offlinePreserved;
    }
    if (errorCode == 'FK-3002') {
      return 'A temporary network interruption occurred while synchronizing. FitKarma is automatically retrying in the background.';
    }
    if (errorCode == 'FK-3003') {
      return 'Changes made on this device conflict with a more recent server record. Your local entries are preserved.';
    }
    if (status == SyncStatus.syncing) {
      return 'Connecting to server and securely syncing pending health logs and updates.';
    }
    if (status == SyncStatus.synced) {
      return 'All local data is fully synchronized with your secure cloud storage.';
    }
    return strings.offlinePreserved;
  }
}

/// Unobtrusive global offline and synchronization status banner.
///
/// Features:
/// - Displays current connectivity state (`Online` / `Offline`).
/// - Surfaces pending sync count and synchronization state (`idle`, `syncing`, `synced`, `error`, `conflict`).
/// - Provides tactile retry action with minimum 48dp touch target.
/// - Opens detailed [SyncFailureDetailsSheet] explaining failure diagnoses and local encryption guarantees.
/// - Does not obstruct touch events or screen content, allowing core offline workflows to remain 100% usable.
class OfflineIndicatorBanner extends ConsumerWidget {
  final bool isOffline;
  final SyncStatus? status;
  final int? pendingCount;
  final String? errorCode;
  final String? errorMessage;
  final String? customMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onTapDetails;
  final Map<String, dynamic>? conflictDetails;
  final VoidCallback? onReviewConflict;

  const OfflineIndicatorBanner({
    super.key,
    required this.isOffline,
    this.status,
    this.pendingCount,
    this.errorCode,
    this.errorMessage,
    this.customMessage,
    this.onRetry,
    this.onTapDetails,
    this.conflictDetails,
    this.onReviewConflict,
  });

  /// Factory creating an [OfflineIndicatorBanner] connected directly to Riverpod's [syncCoordinatorProvider].
  static Widget connected({
    Key? key,
    String? customMessage,
    VoidCallback? onRetryOverride,
    VoidCallback? onTapDetailsOverride,
  }) {
    return _ConnectedOfflineIndicatorBanner(
      key: key,
      customMessage: customMessage,
      onRetryOverride: onRetryOverride,
      onTapDetailsOverride: onTapDetailsOverride,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveStatus = status ?? SyncStatus.idle;
    final effectivePending = pendingCount ?? 0;

    // Unobtrusive rule: If online, idle/synced, and 0 pending operations, quietly hide
    final shouldShow = isOffline ||
        effectivePending > 0 ||
        effectiveStatus == SyncStatus.syncing ||
        effectiveStatus == SyncStatus.error ||
        effectiveStatus == SyncStatus.conflict;

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    final strings = AppLocalizations.stringsOf(context);
    final bannerConfig = _resolveBannerConfig(strings, effectiveStatus, effectivePending);

    return Semantics(
      liveRegion: true,
      label: 'Sync status: ${bannerConfig.message}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapDetails ??
              () => _openDetailsSheet(
                    context,
                    effectiveStatus,
                    effectivePending,
                  ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: bannerConfig.backgroundColor,
              border: Border(
                bottom: BorderSide(color: bannerConfig.borderColor, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  bannerConfig.icon,
                  size: 18,
                  color: bannerConfig.iconColor,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    customMessage ?? bannerConfig.message,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (effectiveStatus == SyncStatus.syncing) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                const SizedBox(width: AppSpacing.xs),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: AppSpacing.minTouchTarget,
                    minHeight: AppSpacing.minTouchTarget,
                  ),
                  child: TextButton(
                    onPressed: effectiveStatus == SyncStatus.syncing
                        ? null
                        : (onRetry ?? () => _triggerDefaultRetry(ref)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      minimumSize: const Size(
                        AppSpacing.minTouchTarget,
                        AppSpacing.minTouchTarget,
                      ),
                    ),
                    child: Text(
                      strings.retry,
                      style: AppTypography.labelSmall.copyWith(
                        color: bannerConfig.actionColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _triggerDefaultRetry(WidgetRef ref) {
    try {
      ref.read(syncCoordinatorProvider.notifier).triggerSync();
    } catch (_) {
      // In standalone tests or non-coordinator environments, safe fallback
    }
  }

  void _openDetailsSheet(
    BuildContext context,
    SyncStatus effectiveStatus,
    int effectivePending,
  ) {
    SyncFailureDetailsSheet.show(
      context,
      isOnline: !isOffline,
      status: effectiveStatus,
      pendingCount: effectivePending,
      errorCode: errorCode,
      errorMessage: errorMessage,
      onRetry: onRetry,
      conflictDetails: conflictDetails,
      onReviewConflict: onReviewConflict,
    );
  }

  _BannerConfig _resolveBannerConfig(
    AppStrings strings,
    SyncStatus currentStatus,
    int currentPending,
  ) {
    if (isOffline) {
      final message = currentPending > 0
          ? '${strings.offline} · ${strings.pendingSyncCount(currentPending)}'
          : strings.offlinePreserved;

      return _BannerConfig(
        icon: Icons.cloud_off,
        iconColor: AppColors.warning,
        borderColor: AppColors.warning,
        backgroundColor: AppColors.warning.withValues(alpha: 0.15),
        actionColor: AppColors.warning,
        message: message,
      );
    }

    switch (currentStatus) {
      case SyncStatus.syncing:
        return _BannerConfig(
          icon: Icons.sync,
          iconColor: AppColors.primary,
          borderColor: AppColors.primary.withValues(alpha: 0.4),
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          actionColor: AppColors.primary,
          message: strings.syncing,
        );

      case SyncStatus.error:
        final errorMsg = errorMessage != null && errorMessage!.isNotEmpty
            ? errorMessage!
            : '${strings.syncError}${errorCode != null ? ' ($errorCode)' : ''}';
        return _BannerConfig(
          icon: Icons.sync_problem,
          iconColor: AppColors.error,
          borderColor: AppColors.error,
          backgroundColor: AppColors.error.withValues(alpha: 0.15),
          actionColor: AppColors.error,
          message: errorMsg,
        );

      case SyncStatus.conflict:
        return _BannerConfig(
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.warning,
          borderColor: AppColors.warning,
          backgroundColor: AppColors.warning.withValues(alpha: 0.15),
          actionColor: AppColors.warning,
          message: strings.syncConflict,
        );

      case SyncStatus.synced:
      case SyncStatus.idle:
        if (currentPending > 0) {
          return _BannerConfig(
            icon: Icons.cloud_queue,
            iconColor: AppColors.warning,
            borderColor: AppColors.warning.withValues(alpha: 0.4),
            backgroundColor: AppColors.warning.withValues(alpha: 0.12),
            actionColor: AppColors.warning,
            message: strings.pendingSyncCount(currentPending),
          );
        }
        return _BannerConfig(
          icon: Icons.cloud_done,
          iconColor: AppColors.primary,
          borderColor: AppColors.primary,
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          actionColor: AppColors.primary,
          message: strings.synced,
        );
    }
  }
}

class _BannerConfig {
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final Color backgroundColor;
  final Color actionColor;
  final String message;

  const _BannerConfig({
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    required this.backgroundColor,
    required this.actionColor,
    required this.message,
  });
}

/// Internal connected implementation of [OfflineIndicatorBanner] driven by [syncCoordinatorProvider].
class _ConnectedOfflineIndicatorBanner extends ConsumerWidget {
  final String? customMessage;
  final VoidCallback? onRetryOverride;
  final VoidCallback? onTapDetailsOverride;

  const _ConnectedOfflineIndicatorBanner({
    super.key,
    this.customMessage,
    this.onRetryOverride,
    this.onTapDetailsOverride,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncCoordinatorProvider);

    return OfflineIndicatorBanner(
      isOffline: !syncState.isOnline,
      status: syncState.status,
      pendingCount: syncState.pendingCount,
      errorCode: syncState.errorCode,
      errorMessage: syncState.errorMessage,
      conflictDetails: syncState.conflictDetails,
      customMessage: customMessage,
      onRetry: onRetryOverride ??
          () => ref.read(syncCoordinatorProvider.notifier).triggerSync(),
      onTapDetails: onTapDetailsOverride,
    );
  }
}
