import 'package:hive/hive.dart';

part 'workout_model.g.dart';

@HiveType(typeId: 2)
class WorkoutModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String youtubeId;

  @HiveField(4)
  final double estimatedCaloriesPerMin;

  @HiveField(5)
  final int durationMins;

  @HiveField(6)
  final String imageUrl;

  WorkoutModel({
    required this.id,
    required this.title,
    required this.category,
    required this.youtubeId,
    required this.estimatedCaloriesPerMin,
    required this.durationMins,
    required this.imageUrl,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      youtubeId: json['youtube_id'] as String,
      estimatedCaloriesPerMin:
          (json['estimated_calories_per_min'] as num).toDouble(),
      durationMins: json['duration_mins'] as int,
      imageUrl: json['image_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'youtube_id': youtubeId,
      'estimated_calories_per_min': estimatedCaloriesPerMin,
      'duration_mins': durationMins,
      'image_url': imageUrl,
    };
  }
}
