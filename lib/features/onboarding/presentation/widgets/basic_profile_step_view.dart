import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:fitkarma/features/profile/domain/models/profile_enums.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Step 4: Basic Profile (Age, Sex, Height, Weight).
class BasicProfileStepView extends ConsumerStatefulWidget {
  const BasicProfileStepView({super.key});

  @override
  ConsumerState<BasicProfileStepView> createState() =>
      _BasicProfileStepViewState();
}

class _BasicProfileStepViewState extends ConsumerState<BasicProfileStepView> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingControllerProvider);
    _nameController = TextEditingController(text: state.displayName);
    _ageController = TextEditingController(text: state.age.toString());
    _heightController =
        TextEditingController(text: state.heightCm.toStringAsFixed(0));
    _weightController =
        TextEditingController(text: state.weightKg.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _syncState() {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    ref.read(onboardingControllerProvider.notifier).updateBasicProfile(
          displayName: name,
          age: age,
          heightCm: height,
          weightKg: weight,
        );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.stringsOf(context);
    final onboardingState = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final validationErrors = onboardingState.validationErrors;

    return SingleChildScrollView(
      key: const Key('step_basic_profile_scroll'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.onboardingBasicProfileTitle,
            style: AppTypography.headline.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings.onboardingBasicProfileSubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Display Name
          AppTextField(
            key: const Key('input_display_name_container'),
            textFieldKey: const Key('input_display_name'),
            label: strings.onboardingDisplayNameLabel,
            hint: 'e.g. Aarav Sharma',
            controller: _nameController,
            errorText: validationErrors?['displayName'],
            onChanged: (_) => _syncState(),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Biological Sex Selector
          Text(
            strings.onboardingSexLabel,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Calibrates clinical Mifflin-St Jeor BMR constant offsets (+5 kcal male, -161 kcal female).',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary.withAlpha(180),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: BiologicalSex.values.map((sex) {
              final isSelected = onboardingState.biologicalSex == sex;
              final label = switch (sex) {
                BiologicalSex.male => 'Male',
                BiologicalSex.female => 'Female',
                BiologicalSex.other => 'Other',
                BiologicalSex.preferNotToSay => 'Prefer Not to Say',
              };
              return ChoiceChip(
                key: Key('chip_sex_${sex.name}'),
                label: Text(label),
                selected: isSelected,
                selectedColor: AppColors.primary.withAlpha(50),
                backgroundColor: AppColors.surfaceElevated,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) {
                    controller.updateBasicProfile(biologicalSex: sex);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Age
          AppTextField(
            key: const Key('input_age_container'),
            textFieldKey: const Key('input_age'),
            label: strings.onboardingAgeLabel,
            hint: 'e.g. 28',
            controller: _ageController,
            keyboardType: TextInputType.number,
            errorText: validationErrors?['age'],
            onChanged: (_) => _syncState(),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Height (cm) & Weight (kg) Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  key: const Key('input_height_cm_container'),
                  textFieldKey: const Key('input_height_cm'),
                  label: strings.onboardingHeightLabel,
                  hint: '175',
                  controller: _heightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  errorText: validationErrors?['heightCm'],
                  onChanged: (_) => _syncState(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  key: const Key('input_weight_kg_container'),
                  textFieldKey: const Key('input_weight_kg'),
                  label: strings.onboardingWeightLabel,
                  hint: '72',
                  controller: _weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  errorText: validationErrors?['weightKg'],
                  onChanged: (_) => _syncState(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
