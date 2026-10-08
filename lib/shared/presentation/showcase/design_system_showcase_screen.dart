import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/shared/presentation/widgets/shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Interactive showcase screen for FitKarma design tokens and UI components.
///
/// Functions as an internal Storybook for testing theme, contrast, tactile feedback,
/// and accessibility.
class DesignSystemShowcaseScreen extends ConsumerStatefulWidget {
  const DesignSystemShowcaseScreen({super.key});

  @override
  ConsumerState<DesignSystemShowcaseScreen> createState() =>
      _DesignSystemShowcaseScreenState();
}

class _DesignSystemShowcaseScreenState
    extends ConsumerState<DesignSystemShowcaseScreen> {
  bool _chipSelected = true;
  bool _isLoadingButton = false;
  final _textController = TextEditingController(text: 'Dal Tadka (1 Bowl)');

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeLocale = ref.watch(appLocaleProvider);
    final strings = AppLocalizations.stringsOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Showcase'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.language, size: 18),
            label: Text(
              activeLocale.languageCode == 'en' ? 'हिन्दी' : 'English',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
            onPressed: () {
              ref.read(appLocaleProvider.notifier).toggleEnglishHindi();
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Design System Info',
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            _buildSectionHeader(
              '1. Colors & Surfaces',
              'Hex and elevation tokens',
            ),
            _buildColorPalette(),
            const SizedBox(height: AppSpacing.xxl),

            _buildSectionHeader(
              '2. Typography & Numerals',
              'High-contrast mobile scale',
            ),
            _buildTypographySection(),
            const SizedBox(height: AppSpacing.xxl),

            _buildSectionHeader(
              '3. Buttons & Actions',
              'Spring feedback & 48dp min touch targets',
            ),
            _buildButtonsSection(),
            const SizedBox(height: AppSpacing.xxl),

            _buildSectionHeader(
              '4. Input Fields',
              'Accessible dark inputs with glass borders',
            ),
            _buildInputsSection(),
            const SizedBox(height: AppSpacing.xxl),

            _buildSectionHeader(
              '5. Bento Cards & Glassmorphism',
              'Grid composition with frosted glass',
            ),
            _buildBentoSection(),
            const SizedBox(height: AppSpacing.xxl),

            _buildSectionHeader(
              '6. Chips & Status Badges',
              'Non-color-only accessible status',
            ),
            _buildChipsSection(),
            const SizedBox(height: AppSpacing.xxl),

            _buildSectionHeader(
              '7. Animated Progress Indicators',
              'Goal tracking & nutrient meters',
            ),
            _buildProgressSection(),
            const SizedBox(height: AppSpacing.xxl),

            _buildSectionHeader(
              '8. Error & State Views',
              'Deterministic recovery states',
            ),
            _buildStatesSection(),
            const SizedBox(height: AppSpacing.xxl),

            _buildSectionHeader(
              '9. Bilingual Localization & AI Phrasing',
              'Active locale: ${activeLocale.languageCode.toUpperCase()} (Live reactive toggle)',
            ),
            _buildLocalizationSection(activeLocale, strings),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.titleLarge),
        const SizedBox(height: 2),
        Text(subtitle, style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildColorPalette() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: const [
        _ColorChip(
          label: 'Primary Mint',
          hex: '#00E599',
          color: AppColors.primary,
        ),
        _ColorChip(
          label: 'Saffron Gold',
          hex: '#FF9933',
          color: AppColors.saffron,
        ),
        _ColorChip(
          label: 'Tech Blue',
          hex: '#38BDF8',
          color: AppColors.techBlue,
        ),
        _ColorChip(
          label: 'Background',
          hex: '#0D0F12',
          color: AppColors.background,
        ),
        _ColorChip(label: 'Surface', hex: '#161A22', color: AppColors.surface),
        _ColorChip(
          label: 'Surface Elev',
          hex: '#1F2430',
          color: AppColors.surfaceElevated,
        ),
        _ColorChip(
          label: 'Error Crimson',
          hex: '#EF4444',
          color: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildTypographySection() {
    return BentoCard(
      title: 'Typography System',
      subtitle: 'Optimized for high legibility across demographics',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Display Large (32pt)', style: AppTypography.display),
          const SizedBox(height: AppSpacing.xs),
          const Text('Headline (24pt)', style: AppTypography.headline),
          const SizedBox(height: AppSpacing.xs),
          const Text('Title Large (20pt)', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          const Text('Title Medium (16pt)', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Body Large (16pt regular)',
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Body Medium (14pt regular)',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Body Small (12pt regular)',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text('10,482', style: AppTypography.metricNumeral),
              SizedBox(width: AppSpacing.xs),
              Text('steps', style: AppTypography.metricUnit),
              SizedBox(width: AppSpacing.lg),
              Text('2,140', style: AppTypography.metricNumeral),
              SizedBox(width: AppSpacing.xs),
              Text('kcal', style: AppTypography.metricUnit),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            AppButton(
              label: 'Primary Button',
              icon: Icons.bolt,
              onPressed: () {},
              variant: AppButtonVariant.primary,
            ),
            AppButton(
              label: 'Secondary Outlined',
              icon: Icons.calendar_today,
              onPressed: () {},
              variant: AppButtonVariant.secondary,
            ),
            AppButton(
              label: 'Saffron Accent',
              icon: Icons.local_fire_department,
              onPressed: () {},
              variant: AppButtonVariant.saffron,
            ),
            AppButton(
              label: 'Ghost Text',
              onPressed: () {},
              variant: AppButtonVariant.ghost,
            ),
            AppButton(
              label: 'Loading State',
              isLoading: _isLoadingButton,
              onPressed: () {
                setState(() => _isLoadingButton = !_isLoadingButton);
              },
            ),
            const AppButton(label: 'Disabled Button', onPressed: null),
          ],
        ),
      ],
    );
  }

  Widget _buildInputsSection() {
    return Column(
      children: [
        AppTextField(
          controller: _textController,
          label: 'Meal Log Query',
          hint: 'e.g., 2 Roti, 1 bowl Dal Tadka',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        const AppTextField(
          label: 'Target Calories (Validation Error Example)',
          hint: 'Enter calories',
          errorText: 'Value must be between 800 and 5,000 kcal',
          prefixIcon: Icon(Icons.fitness_center, color: AppColors.error),
        ),
      ],
    );
  }

  Widget _buildBentoSection() {
    return Column(
      children: [
        // Standard Bento Tile
        BentoCard(
          title: 'Daily Steps',
          subtitle: 'Health Connect Synced',
          icon: Icons.directions_walk,
          iconColor: AppColors.primary,
          trailing: const AppStatusBadge(
            label: 'On Track',
            type: StatusType.success,
            icon: Icons.check_circle_outline,
          ),
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('8,450', style: AppTypography.metricNumeral),
                  SizedBox(width: AppSpacing.xs),
                  Text('/ 10,000 steps', style: AppTypography.metricUnit),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              AppProgressBar(value: 0.845),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Glassmorphism Bento Card
        BentoCard(
          isGlass: true,
          title: 'Daily Intelligence Package (DIP)',
          subtitle: 'Contextual AI Health Briefing',
          icon: Icons.auto_awesome,
          iconColor: AppColors.techBlue,
          trailing: const AppStatusBadge(
            label: 'AI Ready',
            type: StatusType.info,
            icon: Icons.bolt,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'High pollution detected (AQI 185). Shift outdoor cardio indoors. Saffron ginger tea recommended for metabolic recovery.',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChipsSection() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        AppChip(
          label: 'Breakfast',
          icon: Icons.free_breakfast,
          isSelected: _chipSelected,
          onSelected: (val) => setState(() => _chipSelected = val),
        ),
        AppChip(
          label: 'Lunch',
          icon: Icons.lunch_dining,
          isSelected: !_chipSelected,
          onSelected: (val) => setState(() => _chipSelected = !val),
        ),
        const AppStatusBadge(
          label: 'Karma Pro',
          type: StatusType.saffron,
          icon: Icons.star,
        ),
        const AppStatusBadge(
          label: 'DPDP Protected',
          type: StatusType.success,
          icon: Icons.shield,
        ),
        const AppStatusBadge(
          label: 'Offline Outbox',
          type: StatusType.warning,
          icon: Icons.cloud_off,
        ),
        const AppStatusBadge(
          label: 'Sync Error',
          type: StatusType.error,
          icon: Icons.warning_amber_rounded,
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: const [
        AppProgressBar(
          value: 0.72,
          label: 'Water Intake',
          trailingText: '2.1L / 3.0L',
        ),
        SizedBox(height: AppSpacing.md),
        AppProgressBar(
          value: 0.45,
          label: 'Protein Goal',
          trailingText: '65g / 140g',
          gradient: AppColors.saffronGradient,
        ),
      ],
    );
  }

  Widget _buildStatesSection() {
    return Column(
      children: [
        BentoCard(
          title: 'Empty State Preview',
          child: const AppEmptyStateView(
            title: 'No Workouts Logged Today',
            description:
                'Log your morning yoga or sync steps from Health Connect.',
            icon: Icons.fitness_center_outlined,
            actionLabel: 'Log Workout',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        BentoCard(
          title: 'Error State Preview',
          child: AppErrorStateView(
            title: 'Sync Timed Out',
            message: 'Unable to reach sync engine. Your logs are safely preserved offline.',
            errorCode: 'FK-4001',
            onRetry: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildLocalizationSection(Locale activeLocale, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BentoCard(
          title:
              'UI String Catalog (${activeLocale.languageCode.toUpperCase()})',
          subtitle: 'Pure static UI strings (Decoupled from AI)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  AppChip(
                    label: strings.dashboard,
                    icon: Icons.dashboard,
                    isSelected: true,
                    onSelected: (_) {},
                  ),
                  AppChip(
                    label: strings.nutrition,
                    icon: Icons.restaurant,
                    isSelected: true,
                    onSelected: (_) {},
                  ),
                  AppChip(
                    label: strings.workouts,
                    icon: Icons.fitness_center,
                    isSelected: true,
                    onSelected: (_) {},
                  ),
                  AppChip(
                    label: strings.fasting,
                    icon: Icons.timelapse,
                    isSelected: true,
                    onSelected: (_) {},
                  ),
                  AppChip(
                    label: strings.dataVault,
                    icon: Icons.lock,
                    isSelected: true,
                    onSelected: (_) {},
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Sample Banner: "${strings.onboarding}"',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Offline Recovery: "${strings.offlinePreserved}"',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        BentoCard(
          isGlass: true,
          title: 'Language Selector & Fallback Testing',
          subtitle: 'Active: ${activeLocale.languageCode}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: AppSupportedLocale.values.map((supported) {
                  final isCurrent =
                      activeLocale.languageCode == supported.languageCode;
                  return AppChip(
                    label: '${supported.displayName} (${supported.nativeName})',
                    isSelected: isCurrent,
                    onSelected: (_) {
                      ref
                          .read(appLocaleProvider.notifier)
                          .setSupportedLocale(supported);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Note: Prepared regional languages (Tamil, Telugu, Gujarati, Bengali, Marathi, Punjabi) safely fall back to English strings until fully translated in Phase 2.',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColorChip extends StatelessWidget {
  final String label;
  final String hex;
  final Color color;

  const _ColorChip({
    required this.label,
    required this.hex,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.roundedSm,
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadii.roundedXs,
              border: Border.all(color: Colors.white12),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTypography.labelSmall, maxLines: 1),
          Text(hex, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}
