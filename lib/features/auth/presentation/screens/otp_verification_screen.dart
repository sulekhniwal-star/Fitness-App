import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/core/routing/app_routes.dart';
import 'package:fitkarma/features/auth/presentation/controllers/phone_auth_controller.dart';
import 'package:fitkarma/features/auth/presentation/widgets/otp_pin_input.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_radii.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/app_button.dart';
import 'package:fitkarma/shared/presentation/widgets/app_scaffold.dart';
import 'package:fitkarma/shared/presentation/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen allowing the user to enter the 6-digit SMS verification code,
/// handle resend countdown timers, and verify authentication with Supabase.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final code = _otpController.text.trim();
    if (code.length != 6) return;

    final success = await ref
        .read(phoneAuthControllerProvider.notifier)
        .verifyOtp(code);

    if (!mounted) return;

    if (success) {
      // Session established; redirect to dashboard
      if (GoRouter.maybeOf(context) != null) {
        context.go(AppRoutes.dashboard);
      }
    } else {
      final failure = ref.read(phoneAuthControllerProvider).failure;
      if (failure != null) {
        AppSnackBar.show(
          context,
          message: failure.message,
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _handleResend() async {
    final strings = AppLocalizations.stringsOf(context);
    final success = await ref
        .read(phoneAuthControllerProvider.notifier)
        .resendOtp();

    if (!mounted) return;

    if (success) {
      _otpController.clear();
      AppSnackBar.show(
        context,
        message: strings.otpSentSuccess,
        type: SnackBarType.success,
      );
    } else {
      final failure = ref.read(phoneAuthControllerProvider).failure;
      if (failure != null) {
        AppSnackBar.show(
          context,
          message: failure.message,
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.stringsOf(context);
    final authState = ref.watch(phoneAuthControllerProvider);
    final hasError = authState.failure != null;

    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top navigation row
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  key: const Key('otp_back_button'),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textPrimary,
                  ),
                  tooltip: strings.back,
                  onPressed: () {
                    final router = GoRouter.maybeOf(context);
                    if (router != null && router.canPop()) {
                      router.pop();
                    } else if (router != null) {
                      router.go(AppRoutes.login);
                    }
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Title
              Text(
                strings.otpVerificationTitle,
                style: AppTypography.headline.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Subtitle with masked phone and "Change" link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      '${strings.otpVerificationSubtitle} ${authState.maskedPhoneNumber}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  GestureDetector(
                    key: const Key('change_phone_button'),
                    onTap: () {
                      final router = GoRouter.maybeOf(context);
                      if (router != null && router.canPop()) {
                        router.pop();
                      } else if (router != null) {
                        router.go(AppRoutes.login);
                      }
                    },
                    child: Text(
                      strings.changePhone,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // 6-digit OTP input widget
              OtpPinInput(
                controller: _otpController,
                focusNode: _focusNode,
                hasError: hasError,
                enabled: !authState.isLoading,
                onChanged: (_) {
                  if (authState.failure != null) {
                    ref.read(phoneAuthControllerProvider.notifier).clearFailure();
                  }
                  setState(() {});
                },
                onCompleted: (code) {
                  _handleVerify();
                },
              ),

              // Inline error feedback
              if (authState.failure != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  key: const Key('otp_error_banner'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorSubtle,
                    borderRadius: AppRadii.roundedSm,
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 16,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          authState.failure!.message,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),

              // Resend countdown timer row
              Center(
                child: authState.resendCooldown > 0
                    ? Text(
                        strings.resendInSeconds(authState.resendCooldown),
                        key: const Key('resend_countdown_text'),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : TextButton(
                        key: const Key('resend_otp_button'),
                        onPressed: authState.isLoading ? null : _handleResend,
                        child: Text(
                          strings.resendOtp,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Verify button
              AppButton(
                key: const Key('verify_otp_button'),
                label: strings.verifyOtp,
                variant: AppButtonVariant.primary,
                isLoading: authState.isLoading,
                isFullWidth: true,
                onPressed: _otpController.text.trim().length == 6 &&
                        !authState.isLoading
                    ? _handleVerify
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
