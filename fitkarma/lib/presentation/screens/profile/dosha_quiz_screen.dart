import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/dosha_model.dart';
import '../../../data/providers/dosha_provider.dart';

class DoshaQuizScreen extends ConsumerStatefulWidget {
  const DoshaQuizScreen({super.key});

  @override
  ConsumerState<DoshaQuizScreen> createState() => _DoshaQuizScreenState();
}

class _DoshaQuizScreenState extends ConsumerState<DoshaQuizScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final Map<String, DoshaType> _answers = {};

  void _onAnswer(String questionId, DoshaType type) {
    setState(() {
      _answers[questionId] = type;
    });

    if (_currentIndex < DoshaRepository.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    final result = DoshaRepository.calculateResult(_answers);
    ref.read(doshaProvider.notifier).setResult(result);
    // Navigate to results screen or show in-place
  }

  @override
  Widget build(BuildContext context) {
    const questions = DoshaRepository.questions;
    final progress = (_currentIndex + 1) / questions.length;
    final doshaState = ref.watch(doshaProvider);

    if (doshaState.result != null) {
      return _buildResultView(context, doshaState.result!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayurvedic Dosha Quiz'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.saffronColor.withValues(alpha: 0.1),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.saffronColor),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Question ${_currentIndex + 1} of ${questions.length}',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Text(
                        q.question,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      ...q.options.entries.map((entry) {
                        final isSelected = _answers[q.id] == entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: InkWell(
                            onTap: () => _onAnswer(q.id, entry.key),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.saffronColor
                                      : Colors.grey.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                color: isSelected
                                    ? AppTheme.saffronColor
                                        .withValues(alpha: 0.1)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppTheme.saffronColor,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(BuildContext context, DoshaResult result) {
    final dominant = result.dominantDosha;
    final name = dominant.name.toUpperCase();

    // Recommendations based on Dosha
    final recommendations = _getRecommendations(dominant);

    return Scaffold(
      backgroundColor: AppTheme.saffronColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppTheme.saffronColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'YOUR DOSHA: $name',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
                ),
              ),
              background: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome,
                        size: 80, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      '${result.percentages[dominant]!.toStringAsFixed(0)}% Match',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What this means',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getDoshaDescription(dominant),
                    style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  _buildSection(
                      '🍏 Best Foods for You', recommendations['foods']!),
                  const SizedBox(height: 24),
                  _buildSection(
                      '🧘 Workout Advice', recommendations['workouts']!),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.saffronColor,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('GO TO DASHBOARD'),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        ref.read(doshaProvider.notifier).clearResult();
                        setState(() {
                          _currentIndex = 0;
                          _answers.clear();
                        });
                      },
                      child: const Text('Retake Quiz',
                          style: TextStyle(color: Colors.grey)),
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

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.circle,
                      size: 8, color: AppTheme.saffronColor),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
      ],
    );
  }

  String _getDoshaDescription(DoshaType type) {
    switch (type) {
      case DoshaType.vata:
        return 'Vata is characterized by the elements of Space and Air. You are likely creative, energetic, and always on the move, but may prone to anxiety and dry skin. Balancing Vata involves warmth, routine, and grounding foods.';
      case DoshaType.pitta:
        return 'Pitta is characterized by Fire and Water. You are likely focused, ambitious, and have a strong digestion. However, you can be irritable and prone to inflammation. Balancing Pitta involves staying cool and avoiding intense heat.';
      case DoshaType.kapha:
        return 'Kapha is characterized by Earth and Water. You are likely calm, compassionate, and have strong endurance. You may be prone to weight gain and lethargy. Balancing Kapha involves stimulation, variety, and light, warm foods.';
    }
  }

  Map<String, List<String>> _getRecommendations(DoshaType type) {
    switch (type) {
      case DoshaType.vata:
        return {
          'foods': [
            'Warm soups and stews',
            'Cooked grains (oats, rice)',
            'Sweet fruits',
            'Healthy fats (Ghee, Avocado)'
          ],
          'workouts': [
            'Gentle Yoga',
            'Walking in nature',
            'Tai Chi',
            'Steady strength training'
          ],
        };
      case DoshaType.pitta:
        return {
          'foods': [
            'Cooling foods (Cucumber, Melons)',
            'Sweet and bitter tastes',
            'Abundant leafy greens',
            'Coconut water'
          ],
          'workouts': [
            'Swimming',
            'Evening walks',
            'Moderate Yoga (cooling)',
            'Team sports'
          ],
        };
      case DoshaType.kapha:
        return {
          'foods': [
            'Light, spicy, and bitter foods',
            'Dry-cooked methods',
            'Plenty of vegetables',
            'Ginger tea'
          ],
          'workouts': [
            'Vigorous HIIT',
            'Running',
            'Active Sun Salutations',
            'Cardio dance'
          ],
        };
    }
  }
}
