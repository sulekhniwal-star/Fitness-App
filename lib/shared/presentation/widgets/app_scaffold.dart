import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/offline_indicator_banner.dart';
import 'package:flutter/material.dart';

export 'offline_indicator_banner.dart';

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

/// Centralized application scaffold enforcing dark aesthetic, offline banner,
/// and safe insets.
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool isOffline;
  final bool autoSyncBanner;
  final VoidCallback? onRetrySync;
  final bool safeArea;
  final EdgeInsetsGeometry? padding;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.isOffline = false,
    this.autoSyncBanner = false,
    this.onRetrySync,
    this.safeArea = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: [
        if (isOffline)
          OfflineIndicatorBanner(
            isOffline: isOffline,
            onRetry: onRetrySync,
          )
        else if (autoSyncBanner)
          OfflineIndicatorBanner.connected(
            onRetryOverride: onRetrySync,
          ),
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

