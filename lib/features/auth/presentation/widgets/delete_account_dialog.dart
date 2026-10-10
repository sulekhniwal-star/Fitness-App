import 'package:fitkarma/features/auth/presentation/providers/account_lifecycle_providers.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Intentional confirmation dialog for requesting account deletion and local data wipe.
///
/// Complies with DPDP Act 2023 requirements and Brain/ui_spec.md guidelines.
class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DeleteAccountDialog(),
    );
  }

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  bool _confirmed = false;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lifecycleState = ref.watch(accountLifecycleControllerProvider);
    final controller = ref.read(accountLifecycleControllerProvider.notifier);

    return Dialog(
      key: const Key('dialog_delete_account'),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Delete Account',
                      style: AppTypography.headline.copyWith(
                        fontSize: 20,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // DPDP Data Protection Notice
              Text(
                'Requesting account deletion will initiate a cascading wipe of your '
                'health observations, workout logs, nutritional records, and credentials '
                'under the Digital Personal Data Protection (DPDP) Act.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(15),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                  border: Border.all(color: AppColors.error.withAlpha(80)),
                ),
                child: Text(
                  'All local data on this device will be immediately wiped. '
                  'A 30-day grace period is provided before server records are irrevocably purged.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Reason input (optional)
              Text(
                'Reason (Optional)',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                key: const Key('input_deletion_reason'),
                controller: _reasonController,
                decoration: InputDecoration(
                  hintText: 'e.g. Privacy concerns, switching services',
                  hintStyle: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                ),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Confirmation Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    key: const Key('checkbox_confirm_data_loss'),
                    value: _confirmed,
                    activeColor: AppColors.error,
                    onChanged: (val) {
                      setState(() {
                        _confirmed = val ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _confirmed = !_confirmed;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          'I understand that my health history will be wiped and cannot be recovered.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (lifecycleState.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  lifecycleState.errorMessage!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      key: const Key('btn_cancel_deletion'),
                      label: 'Cancel',
                      variant: AppButtonVariant.secondary,
                      onPressed: lifecycleState.isDeleting
                          ? null
                          : () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      key: const Key('btn_confirm_deletion'),
                      label: lifecycleState.isDeleting
                          ? 'Wiping...'
                          : 'Delete Account',
                      variant: AppButtonVariant.primary,
                      isLoading: lifecycleState.isDeleting,
                      onPressed: !_confirmed || lifecycleState.isDeleting
                          ? null
                          : () async {
                              final receipt =
                                  await controller.requestAccountDeletion(
                                reason: _reasonController.text.trim(),
                                confirmDataLoss: _confirmed,
                              );
                              if (context.mounted && receipt != null) {
                                Navigator.of(context).pop(true);
                              }
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
