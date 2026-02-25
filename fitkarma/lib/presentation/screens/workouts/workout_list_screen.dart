import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

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
    // Placeholder workouts data
    final workouts = _getWorkoutsForCategory(categoryId);

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return _buildWorkoutCard(workout);
      },
    );
  }

  List<Map<String, dynamic>> _getWorkoutsForCategory(String categoryId) {
    switch (categoryId) {
      case 'yoga':
        return [
          {
            'title': 'Morning Yoga Flow',
            'duration': '20 min',
            'calories': 120,
            'level': 'Beginner',
            'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
            'videoId': 'dQw4w9WgXcQ',
          },
          {
            'title': 'Power Yoga',
            'duration': '30 min',
            'calories': 200,
            'level': 'Intermediate',
            'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
            'videoId': 'dQw4w9WgXcQ',
          },
          {
            'title': 'Relaxation Yoga',
            'duration': '15 min',
            'calories': 80,
            'level': 'Beginner',
            'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
            'videoId': 'dQw4w9WgXcQ',
          },
        ];
      case 'bollywood':
        return [
          {
            'title': 'Bollywood Cardio Burn',
            'duration': '25 min',
            'calories': 250,
            'level': 'Intermediate',
            'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
            'videoId': 'dQw4w9WgXcQ',
          },
          {
            'title': 'Dance Fitness',
            'duration': '30 min',
            'calories': 300,
            'level': 'Beginner',
            'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
            'videoId': 'dQw4w9WgXcQ',
          },
        ];
      case 'desi':
        return [
          {
            'title': 'Desi Home Workout',
            'duration': '20 min',
            'calories': 180,
            'level': 'Beginner',
            'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
            'videoId': 'dQw4w9WgXcQ',
          },
          {
            'title': 'Cricket Fitness',
            'duration': '15 min',
            'calories': 150,
            'level': 'Intermediate',
            'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
            'videoId': 'dQw4w9WgXcQ',
          },
        ];
      case 'hiit':
        return [
          {
            'title': 'Quick Fat Burn',
            'duration': '15 min',
            'calories': 200,
            'level': 'Advanced',
            'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
            'videoId': 'dQw4w9WgXcQ',
          },
        ];
      case 'sports':
        return [
          {
            'title': 'Cricket Training',
            'duration': '30 min',
            'calories': 220,
            'level': 'Intermediate',
            'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
            'videoId': 'dQw4w9WgXcQ',
          },
          {
            'title': 'Football Warmup',
            'duration': '15 min',
            'calories': 120,
            'level': 'Beginner',
            'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
            'videoId': 'dQw4w9WgXcQ',
          },
        ];
      default:
        return [];
    }
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to video player
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail placeholder
            Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: Stack(
                children: [
                  Center(
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
                        workout['duration'],
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
                    workout['title'],
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
                        '${workout['calories']} cal',
                        AppTheme.errorColor,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.signal_cellular_alt,
                        workout['level'],
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
