import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/karma_provider.dart';
import '../../../data/providers/workout_provider.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/storage/hive_service.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final WorkoutModel? workout;
  final String? workoutId;

  const WorkoutDetailScreen({super.key, this.workout, this.workoutId});

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;
  bool _isLoading = true;
  WorkoutModel? _workout;

  @override
  void initState() {
    super.initState();
    _initializeWorkout();
  }

  Future<void> _initializeWorkout() async {
    if (widget.workout != null) {
      _workout = widget.workout;
    } else if (widget.workoutId != null) {
      // Fetch from provider
      final workoutRepo = ref.read(workoutRepositoryProvider);
      _workout = workoutRepo.getWorkoutById(widget.workoutId!);
    }

    if (_workout != null) {
      _controller = YoutubePlayerController(
        initialVideoId: _workout!.youtubeId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      )..addListener(listener);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void listener() {
    if (_isPlayerReady && mounted && _controller != null && !_controller!.value.isFullScreen) {
      setState(() {});
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_workout == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: const Center(child: Text('Workout not found')),
      );
    }

    return YoutubePlayerBuilder(
      onExitFullScreen: () {},
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppTheme.primaryColor,
        onReady: () {
          _isPlayerReady = true;
        },
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_workout!.title),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                player,
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _workout!.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.category,
                              size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(_workout!.category),
                          const SizedBox(width: 16),
                          Icon(Icons.timer,
                              size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text('${_workout!.durationMins} min'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Estimated Burn: ${(_workout!.durationMins * _workout!.estimatedCaloriesPerMin).toInt()} Calories',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _completeWorkout,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('I Completed This! (+15 Karma)'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _completeWorkout() {
    final user = ref.read(authStateProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to record a workout.')),
      );
      return;
    }

    final totalCalories =
        _workout!.durationMins * _workout!.estimatedCaloriesPerMin;

    final logData = {
      'id': const Uuid().v4(),
      'user_id': user.id,
      'workout_id': _workout!.id,
      'title': _workout!.title,
      'duration_mins': _workout!.durationMins,
      'calories_burned': totalCalories,
      'completed_at': DateTime.now().toIso8601String(),
    };

    // Save offline & queue for sync
    HiveService.workoutLogBox.put(logData['id'], logData);
    ref.read(syncServiceProvider).enqueueAction(
          collection: 'workout_logs',
          operation: 'create',
          data: logData,
        );

    // Grant Karma
    ref
        .read(karmaProvider.notifier)
        .earnKarma(15, 'Completed ${_workout!.title}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Great Job! +15 Karma points earned!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );

    Navigator.of(context).pop(); // Go back to the workout list
  }
}
