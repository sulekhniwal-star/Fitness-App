import 'package:fitkarma/features/profile/domain/wellness/dosha_question.dart';
import 'package:fitkarma/features/profile/domain/wellness/wellness_profile.dart';
import 'package:fitkarma/features/profile/presentation/providers/wellness_providers.dart';
import 'package:fitkarma/features/profile/presentation/widgets/dosha_quiz_card.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/app_button.dart';
import 'package:fitkarma/shared/presentation/widgets/app_progress_bar.dart';
import 'package:fitkarma/shared/presentation/widgets/app_scaffold.dart';
import 'package:fitkarma/shared/presentation/widgets/bento_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen managing the complete Ayurveda & Prakriti wellness personalization layer.
///
/// Supports interactive questionnaire, non-medical recommendations display,
/// skipping, and revisiting/retaking the assessment.
class DoshaWellnessScreen extends ConsumerStatefulWidget {
  const DoshaWellnessScreen({super.key});

  @override
  ConsumerState<DoshaWellnessScreen> createState() =>
      _DoshaWellnessScreenState();
}

class _DoshaWellnessScreenState extends ConsumerState<DoshaWellnessScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, String> _answers = {};
  bool _isTakingQuiz = false;

  @override
  Widget build(BuildContext context) {
    final wellnessAsync = ref.watch(wellnessControllerProvider);

    return AppScaffold(
      key: const Key('screen_dosha_wellness'),
      appBar: AppBar(
        title: const Text('Ayurveda & Prakriti'),
        centerTitle: false,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: wellnessAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Unable to load wellness profile.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
          ),
        ),
        data: (profile) {
          // If profile is already completed and user is not actively retaking
          if (profile != null && profile.isCompleted && !_isTakingQuiz) {
            return _buildResultsView(profile);
          }

          // Otherwise show interactive questionnaire / onboarding intake
          return _buildQuestionnaireView();
        },
      ),
    );
  }

  Widget _buildResultsView(WellnessProfile profile) {
    final score = profile.score;

    return SingleChildScrollView(
      key: const Key('scroll_dosha_results'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dominant Dosha Header Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.md),
              border: Border.all(
                color: AppColors.saffron.withAlpha(150),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.spa, color: AppColors.saffron, size: 28),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        profile.dominantDosha.displayName,
                        style: AppTypography.headline.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (profile.secondaryDosha != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Secondary Influence: ${profile.secondaryDosha!.displayName}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.saffron,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text(
                  profile.dominantDosha.description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Non-Medical Disclaimer Banner
          _buildDisclaimerBanner(),
          const SizedBox(height: AppSpacing.lg),

          // Constitutional Balance Breakdown
          Text(
            'Constitutional Balance Breakdown',
            style: AppTypography.headline.copyWith(
              fontSize: 18,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDoshaScoreBar(
            title: 'Vata (Air & Ether)',
            percentage: score.vataPercentage,
            color: const Color(0xFF64B5F6),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildDoshaScoreBar(
            title: 'Pitta (Fire & Water)',
            percentage: score.pittaPercentage,
            color: const Color(0xFFFF8A65),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildDoshaScoreBar(
            title: 'Kapha (Earth & Water)',
            percentage: score.kaphaPercentage,
            color: const Color(0xFF81C784),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Non-Medical Lifestyle Recommendations
          Text(
            'Holistic Lifestyle Guidance',
            style: AppTypography.headline.copyWith(
              fontSize: 18,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Traditional guidelines for seasonal and daily equilibrium.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...profile.recommendations.map(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: BentoCard(
                title: rec.title,
                subtitle: '${rec.category}: ${rec.description}',
                icon: Icons.lightbulb_outline,
                iconColor: AppColors.saffron,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Retake Action
          AppButton(
            key: const Key('btn_retake_dosha'),
            label: 'Retake Assessment',
            icon: Icons.refresh,
            variant: AppButtonVariant.secondary,
            onPressed: () {
              setState(() {
                _isTakingQuiz = true;
                _currentQuestionIndex = 0;
                _answers.clear();
              });
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildQuestionnaireView() {
    final questions = DoshaQuestion.standardQuestions;
    final currentQuestion = questions[_currentQuestionIndex];
    final selectedOption = _answers[currentQuestion.id];
    final total = questions.length;
    final progress = (_currentQuestionIndex + 1) / total;

    return SingleChildScrollView(
      key: const Key('scroll_dosha_quiz'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress & Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of $total',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.saffron,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          AppProgressBar(value: progress),
          const SizedBox(height: AppSpacing.md),

          // Mandatory Disclaimer Banner
          _buildDisclaimerBanner(),
          const SizedBox(height: AppSpacing.lg),

          // Active Question Card
          DoshaQuizCard(
            key: Key('question_${currentQuestion.id}'),
            question: currentQuestion,
            selectedOptionId: selectedOption,
            onOptionSelected: (optionId) {
              setState(() {
                _answers[currentQuestion.id] = optionId;
              });
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // Navigation Buttons
          Row(
            children: [
              if (_currentQuestionIndex > 0) ...[
                Expanded(
                  child: AppButton(
                    key: const Key('btn_dosha_prev'),
                    label: 'Back',
                    variant: AppButtonVariant.secondary,
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex--;
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: AppButton(
                  key: const Key('btn_dosha_next'),
                  label: _currentQuestionIndex == total - 1
                      ? 'Complete Assessment'
                      : 'Next',
                  onPressed: selectedOption == null
                      ? null
                      : () {
                          if (_currentQuestionIndex == total - 1) {
                            _completeQuiz();
                          } else {
                            setState(() {
                              _currentQuestionIndex++;
                            });
                          }
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Skip Option
          Center(
            child: TextButton.icon(
              key: const Key('btn_skip_wellness_quiz'),
              onPressed: () {
                ref.read(wellnessControllerProvider.notifier).skipAssessment();
                setState(() {
                  _isTakingQuiz = false;
                });
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Skip Assessment for Now'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildDisclaimerBanner() {
    return Container(
      key: const Key('banner_wellness_disclaimer'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.saffron.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: AppColors.saffron.withAlpha(120)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.saffron,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              WellnessProfile.nonMedicalDisclaimer,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoshaScoreBar({
    required String title,
    required double percentage,
    required Color color,
  }) {
    final pctString = '${(percentage * 100).round()}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              pctString,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  void _completeQuiz() {
    ref.read(wellnessControllerProvider.notifier).submitAssessment(_answers);
    setState(() {
      _isTakingQuiz = false;
    });
  }
}
