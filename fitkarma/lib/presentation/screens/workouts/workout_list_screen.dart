import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/providers/workout_provider.dart';
import 'workout_detail_screen.dart';

class WorkoutListScreen extends ConsumerStatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  ConsumerState<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends ConsumerState<WorkoutListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'yoga', 'name': 'Yoga', 'icon': Icons.self_improvement},
    {'id': 'bollywood', 'name': 'Bollywood Dance', 'icon': Icons.music_note},
    {'id': 'desi', 'name': 'Desi Workouts', 'icon': Icons.fitness_center},
    {'id': 'hiit', 'name': 'HIIT', 'icon': Icons.flash_on},
    {'id': 'sports', 'name': 'Indian Sports', 'icon': Icons.sports_cricket},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((cat) {
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat['icon'], size: 20),
                  const SizedBox(width: 8),
                  Text(cat['name']),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((category) {
          return _buildWorkoutList(category['id']);
        }).toList(),
      ),
    );
  }

  Widget _buildWorkoutList(String categoryId) {
    // Utilize the WorkoutProvider directly instead of static mock strings
    final workouts =
        ref.watch(workoutRepositoryProvider).getWorkoutsByCategory(categoryId);

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return _buildWorkoutCard(workout);
      },
    );
  }

  Widget _buildWorkoutCard(WorkoutModel workout) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => WorkoutDetailScreen(workout: workout),
          ));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail placeholder mapping
            Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    workout.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, _, __) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${workout.durationMins} min',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.local_fire_department,
                        '${(workout.estimatedCaloriesPerMin * workout.durationMins).toInt()} cal',
                        AppTheme.errorColor,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.signal_cellular_alt,
                        workout.category,
                        AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
