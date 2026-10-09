import 'package:fitkarma/features/profile/domain/wellness/dosha_question.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/bento_card.dart';
import 'package:flutter/material.dart';

/// Interactive card widget displaying a single Prakriti assessment question
/// with selectable options.
class DoshaQuizCard extends StatelessWidget {
  final DoshaQuestion question;
  final String? selectedOptionId;
  final ValueChanged<String> onOptionSelected;

  const DoshaQuizCard({
    super.key,
    required this.question,
    required this.selectedOptionId,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Badge & Title
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.saffron.withAlpha(25),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Text(
                question.category.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.saffron,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          question.title,
          style: AppTypography.headline.copyWith(
            fontSize: 18,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Options
        ...question.options.map((option) {
          final isSelected = selectedOptionId == option.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: BentoCard(
              key: Key('option_${option.id}'),
              onTap: () => onOptionSelected(option.id),
              title: option.label,
              subtitle: option.description,
              icon: Icons.spa_outlined,
              iconColor:
                  isSelected ? AppColors.saffron : AppColors.textSecondary,
              trailing: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color:
                    isSelected ? AppColors.saffron : AppColors.textSecondary,
              ),
            ),
          );
        }),
      ],
    );
  }
}
