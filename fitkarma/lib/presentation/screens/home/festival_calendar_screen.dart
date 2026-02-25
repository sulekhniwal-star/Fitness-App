import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/festival_model.dart';
import '../../../data/providers/festival_provider.dart';

class FestivalCalendarScreen extends ConsumerWidget {
  const FestivalCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final festivalState = ref.watch(festivalProvider);
    final List<Festival> upcomingFestivals = festivalState.allFestivals
        .where((f) =>
            f.date.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Festival Calendar'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: upcomingFestivals.length,
        itemBuilder: (context, index) {
          final festival = upcomingFestivals[index];
          final isToday = festivalState.todayFestival?.id == festival.id;

          return Card(
            elevation: isToday ? 8 : 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isToday
                  ? const BorderSide(color: AppTheme.saffronColor, width: 2)
                  : BorderSide.none,
            ),
            child: ExpansionTile(
              leading: _buildDateBadge(festival.date, isToday),
              title: Text(
                festival.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(festival.description),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (festival.calorieMultiplier > 1.0)
                        _buildInfoRow(
                          Icons.restaurant,
                          'Nutrition Guide',
                          'Calorie flexibility: +${((festival.calorieMultiplier - 1) * 100).toInt()}%',
                          color: Colors.orange,
                        ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.fitness_center,
                        'Workout Idea',
                        festival.workoutSuggestion,
                        color: Colors.blue,
                      ),
                      if (festival.healthySwaps.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Healthy Swaps',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const SizedBox(height: 8),
                        ...festival.healthySwaps.entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.swap_horiz,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text('${e.key} ➡️ ${e.value}',
                                        style: const TextStyle(fontSize: 14)),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateBadge(DateTime date, bool isToday) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isToday ? AppTheme.saffronColor : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              color: isToday ? Colors.white70 : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: 20,
              color: isToday ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value,
      {required Color color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
