import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/core/sync/repository/sync_repository.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_radii.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Visual indicator badge displaying an entity's sync state:
/// - Pending (`AppColors.warning`, clock / outbox icon)
/// - Synced (`AppColors.primary`, checkmark / cloud done icon)
/// - Conflict (`AppColors.warning` / error, alert icon with action hint)
class EntitySyncBadge extends StatelessWidget {
  final bool isSynced;
  final bool isPending;
  final bool hasConflict;
  final VoidCallback? onTapConflict;

  const EntitySyncBadge({
    super.key,
    this.isSynced = true,
    this.isPending = false,
    this.hasConflict = false,
    this.onTapConflict,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.stringsOf(context);

    if (hasConflict) {
      return Semantics(
        button: onTapConflict != null,
        label: 'Sync Conflict: Tap to review',
        child: InkWell(
          onTap: onTapConflict,
          borderRadius: AppRadii.roundedFull,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: AppRadii.roundedFull,
              border: Border.all(
                color: AppColors.warning,
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  strings.syncConflict,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (isPending || !isSynced) {
      return Semantics(
        label: 'Sync Pending: Changes saved locally',
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            borderRadius: AppRadii.roundedFull,
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.4),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_queue_rounded,
                size: 14,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                strings.syncPending,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Synced state
    return Semantics(
      label: 'Synced: Saved to cloud',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: AppRadii.roundedFull,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_done_rounded,
              size: 14,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              strings.synced,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// User-facing conflict resolution bottom sheet implementing error code FK-3003 handling.
///
/// Features:
/// - Never silently overwrites material user changes.
/// - Clear, non-blaming language explaining concurrent updates.
/// - Side-by-side inspection of "This Device" vs "Cloud (Other Device)".
/// - Distinct resolution paths:
///   - [ConflictUserChoice.keepMine]: Keeps local version and re-pushes.
///   - [ConflictUserChoice.keepServer]: Adopts remote version.
///   - [ConflictUserChoice.merge]: Blends non-overlapping updates safely.
/// - Minimum 48dp touch targets on all interactive actions.
class ConflictResolutionSheet extends StatelessWidget {
  final String entityTitle;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final ValueChanged<ConflictUserChoice> onResolve;
  final bool allowMerge;

  const ConflictResolutionSheet({
    super.key,
    required this.entityTitle,
    required this.localData,
    required this.serverData,
    required this.onResolve,
    this.allowMerge = true,
  });

  /// Displays the modal resolution sheet.
  static Future<ConflictUserChoice?> show(
    BuildContext context, {
    required String entityTitle,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> serverData,
    bool allowMerge = true,
  }) {
    return showModalBottomSheet<ConflictUserChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (ctx) => ConflictResolutionSheet(
        entityTitle: entityTitle,
        localData: localData,
        serverData: serverData,
        allowMerge: allowMerge,
        onResolve: (choice) => Navigator.of(ctx).pop(choice),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.stringsOf(context);

    return SafeArea(
      child: SingleChildScrollView(
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

            // Header
            Row(
              children: [
                const Icon(
                  Icons.balance_rounded,
                  color: AppColors.warning,
                  size: 26,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.conflictTitle,
                        style: AppTypography.titleLarge,
                      ),
                      if (entityTitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          entityTitle,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
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

            // Non-blaming explanation banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: AppRadii.roundedMd,
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: Text(
                strings.conflictSubtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Comparison cards: Local (Mine) vs Cloud (Server)
            _buildVersionCard(
              title: strings.yourVersion,
              badgeColor: AppColors.primary,
              data: localData,
              subtitle: strings.keepMineSubtitle,
              isLocal: true,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildVersionCard(
              title: strings.serverVersion,
              badgeColor: AppColors.techBlue,
              data: serverData,
              subtitle: strings.keepServerSubtitle,
              isLocal: false,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Non-blaming action buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton(
                  label: strings.keepMine,
                  variant: AppButtonVariant.primary,
                  onPressed: () => onResolve(ConflictUserChoice.keepMine),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: strings.keepServer,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => onResolve(ConflictUserChoice.keepServer),
                ),
                if (allowMerge) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: strings.mergeSafe,
                    variant: AppButtonVariant.ghost,
                    onPressed: () => onResolve(ConflictUserChoice.merge),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionCard({
    required String title,
    required Color badgeColor,
    required Map<String, dynamic> data,
    required String subtitle,
    required bool isLocal,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.roundedMd,
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
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
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                isLocal ? 'Offline Edits' : 'Cloud Version',
                style: AppTypography.labelSmall.copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(color: AppColors.surfaceBorder, height: 16),
          ...data.entries.take(5).map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      entry.key,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
