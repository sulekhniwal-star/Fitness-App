import 'package:flutter_test/flutter_test.dart';
import 'package:fitkarma/data/models/workout_model.dart';

void main() {
  group('WorkoutModel', () {
    test('should create WorkoutModel from JSON', () {
      final json = {
        'id': 'w_yoga_1',
        'title': 'Surya Namaskar',
        'category': 'Yoga',
        'youtube_id': 'abc123',
        'estimated_calories_per_min': 4.5,
        'duration_mins': 15,
        'image_url': 'https://example.com/image.jpg',
      };

      final workout = WorkoutModel.fromJson(json);

      expect(workout.id, 'w_yoga_1');
      expect(workout.title, 'Surya Namaskar');
      expect(workout.category, 'Yoga');
      expect(workout.youtubeId, 'abc123');
      expect(workout.estimatedCaloriesPerMin, 4.5);
      expect(workout.durationMins, 15);
      expect(workout.imageUrl, 'https://example.com/image.jpg');
    });

    test('should convert to JSON correctly', () {
      final workout = WorkoutModel(
        id: 'w_yoga_1',
        title: 'Surya Namaskar',
        category: 'Yoga',
        youtubeId: 'abc123',
        estimatedCaloriesPerMin: 4.5,
        durationMins: 15,
        imageUrl: 'https://example.com/image.jpg',
      );

      final json = workout.toJson();

      expect(json['id'], 'w_yoga_1');
      expect(json['title'], 'Surya Namaskar');
      expect(json['category'], 'Yoga');
      expect(json['youtube_id'], 'abc123');
      expect(json['estimated_calories_per_min'], 4.5);
      expect(json['duration_mins'], 15);
    });

    test('should handle null routePolyline', () {
      final json = {
        'id': 'w_yoga_1',
        'title': 'Surya Namaskar',
        'category': 'Yoga',
        'youtube_id': 'abc123',
        'estimated_calories_per_min': 4.5,
        'duration_mins': 15,
        'image_url': 'https://example.com/image.jpg',
      };

      final workout = WorkoutModel.fromJson(json);

      expect(workout.routePolyline, isNull);
    });

    test('should include routePolyline in JSON when present', () {
      final workout = WorkoutModel(
        id: 'w_run_1',
        title: 'Morning Run',
        category: 'Running',
        youtubeId: 'xyz789',
        estimatedCaloriesPerMin: 10.0,
        durationMins: 30,
        imageUrl: 'https://example.com/run.jpg',
        routePolyline: 'encoded_polyline_string',
      );

      final json = workout.toJson();

      expect(json['route_polyline'], 'encoded_polyline_string');
    });
  });
}
