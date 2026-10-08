import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/core/routing/app_routes.dart';
import 'package:fitkarma/features/auth/presentation/controllers/google_auth_controller.dart';
import 'package:fitkarma/features/auth/presentation/controllers/phone_auth_controller.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_radii.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/app_button.dart';
import 'package:fitkarma/shared/presentation/widgets/app_scaffold.dart';
import 'package:fitkarma/shared/presentation/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen allowing the user to enter their mobile phone number for OTP authentication
/// or sign in with Google.
class PhoneEntryScreen extends ConsumerStatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  ConsumerState<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends ConsumerState<PhoneEntryScreen> {
  late final TextEditingController _phoneController;
  final FocusNode _focusNode = FocusNode();
  String? _clientValidationError;

  @override
  void initState() {
    super.initState();
    final currentPhone = ref.read(phoneAuthControllerProvider).phoneNumber;
    _phoneController = TextEditingController(text: currentPhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final rawInput = _phoneController.text.trim();
    final strings = AppLocalizations.stringsOf(context);

    final normalized = PhoneAuthController.normalizeIndianPhone(rawInput);
    if (normalized == null) {
      setState(() {
        _clientValidationError = strings.invalidPhoneError;
      });
      return;
    }

    setState(() {
      _clientValidationError = null;
    });

    final success = await ref
        .read(phoneAuthControllerProvider.notifier)
        .sendOtp(normalized);

    if (!mounted) return;

    if (success) {
      if (GoRouter.maybeOf(context) != null) {
        context.push(AppRoutes.otp);
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

  Future<void> _handleGoogleSignIn() async {
    final strings = AppLocalizations.stringsOf(context);
    final success = await ref
        .read(googleAuthControllerProvider.notifier)
        .signInWithGoogle();

    if (!mounted) return;

    if (success) {
      if (GoRouter.maybeOf(context) != null) {
        context.go(AppRoutes.dashboard);
      }
    } else {
      final googleState = ref.read(googleAuthControllerProvider);
      if (googleState.isCancelled) {
        AppSnackBar.show(
          context,
          message: strings.googleSignInCancelled,
          type: SnackBarType.info,
        );
      } else if (googleState.failure != null) {
        AppSnackBar.show(
          context,
          message: googleState.failure!.message,
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.stringsOf(context);
    final authState = ref.watch(phoneAuthControllerProvider);
    final googleAuthState = ref.watch(googleAuthControllerProvider);
    final effectiveError = _clientValidationError ?? authState.failure?.message;

    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              // Brand mark / icon
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.15),
                    borderRadius: AppRadii.roundedLg,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Title & Subtitle
              Text(
                strings.phoneEntryTitle,
                style: AppTypography.headline.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                strings.phoneEntrySubtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Phone number input row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country code badge (+91 🇮🇳)
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadii.roundedMd,
                      border: Border.all(
                        color: AppColors.surfaceBorder,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '+91',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // National number field
                  Expanded(
                    child: Semantics(
                      label: strings.phoneInputLabel,
                      child: TextField(
                        key: const Key('phone_number_text_field'),
                        controller: _phoneController,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        enabled: !authState.isLoading && !googleAuthState.isLoading,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                        cursorColor: AppColors.primary,
                        onChanged: (_) {
                          if (_clientValidationError != null ||
                              authState.failure != null) {
                            setState(() => _clientValidationError = null);
                            ref
                                .read(phoneAuthControllerProvider.notifier)
                                .clearFailure();
                          }
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: strings.phoneInputHint,
                          hintStyle: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 1.2,
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: AppRadii.roundedMd,
                            borderSide: const BorderSide(
                              color: AppColors.surfaceBorder,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppRadii.roundedMd,
                            borderSide: BorderSide(
                              color: effectiveError != null
                                  ? AppColors.error
                                  : AppColors.surfaceBorder,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppRadii.roundedMd,
                            borderSide: BorderSide(
                              color: effectiveError != null
                                  ? AppColors.error
                                  : AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Inline error feedback
              if (effectiveError != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        effectiveError,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // Get OTP Action Button
              AppButton(
                key: const Key('send_otp_button'),
                label: strings.sendOtp,
                variant: AppButtonVariant.primary,
                isLoading: authState.isLoading,
                isFullWidth: true,
                onPressed: _phoneController.text.trim().length >= 10 &&
                        !authState.isLoading &&
                        !googleAuthState.isLoading
                    ? _handleSendOtp
                    : null,
              ),

              const SizedBox(height: AppSpacing.lg),

              // OR divider
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      color: AppColors.surfaceBorder,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      strings.orDivider,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      color: AppColors.surfaceBorder,
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Continue with Google Button
              AppButton(
                key: const Key('google_sign_in_button'),
                label: strings.continueWithGoogle,
                variant: AppButtonVariant.secondary,
                icon: Icons.g_mobiledata_rounded,
                isLoading: googleAuthState.isLoading,
                isFullWidth: true,
                onPressed: !googleAuthState.isLoading && !authState.isLoading
                    ? _handleGoogleSignIn
                    : null,
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // DPDP / Terms Notice
              Text(
                strings.authTermsNotice,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
