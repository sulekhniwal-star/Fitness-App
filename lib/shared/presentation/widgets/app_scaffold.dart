import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Top bar with back navigation, titles, and action slots for FitKarma screens.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 68.0 : 56.0);

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      leading:
          leading ??
          (showBackButton && canPop
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  tooltip: 'Back',
                  onPressed:
                      onBackPressed ?? () => Navigator.of(context).maybePop(),
                )
              : null),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTypography.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: AppTypography.bodySmall),
          ],
        ],
      ),
      actions: actions,
    );
  }
}

/// Offline warning and sync banner presented at the top of scaffolds.
class OfflineIndicatorBanner extends StatelessWidget {
  final bool isOffline;
  final String? customMessage;
  final VoidCallback? onRetry;

  const OfflineIndicatorBanner({
    super.key,
    required this.isOffline,
    this.customMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    final strings = AppLocalizations.stringsOf(context);
    final message = customMessage ?? strings.offlinePreserved;

    return Semantics(
      liveRegion: true,
      label: 'Offline indicator: $message',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.15),
          border: const Border(
            bottom: BorderSide(color: AppColors.warning, width: 1.0),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off, size: 18, color: AppColors.warning),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  minimumSize: const Size(0, 32),
                ),
                child: Text(
                  strings.retry,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Centralized application scaffold enforcing dark aesthetic, offline banner,
/// and safe insets.
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool isOffline;
  final bool safeArea;
  final EdgeInsetsGeometry? padding;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.isOffline = false,
    this.safeArea = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: [
        if (isOffline) OfflineIndicatorBanner(isOffline: isOffline),
        Expanded(
          child: padding != null
              ? Padding(padding: padding!, child: body)
              : body,
        ),
      ],
    );

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
