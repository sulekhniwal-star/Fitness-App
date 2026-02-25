import 'package:hive/hive.dart';

part 'post_model.g.dart';

@HiveType(typeId: 5)
class PostModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String? imageUrl;

  @HiveField(4)
  final List<String> likes;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final String? challengeId;

  // Expansion fields from PocketBase (not persisted in Hive usually, but kept for UI)
  final String? userName;
  final String? userAvatar;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    this.likes = const [],
    required this.createdAt,
    this.challengeId,
    this.userName,
    this.userAvatar,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Handle PocketBase expansion if available
    final expand = json['expand'] as Map<String, dynamic>?;
    final userData = expand?['user'] as Map<String, dynamic>?;

    return PostModel(
      id: json['id'] as String,
      userId: json['user'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['image'] as String?,
      likes: List<String>.from(json['likes'] ?? []),
      createdAt: DateTime.parse(json['created'] as String),
      challengeId: json['challenge'] as String?,
      userName: userData?['name'] as String?,
      userAvatar: userData?['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'content': content,
      'image': imageUrl,
      'likes': likes,
      'created': createdAt.toIso8601String(),
      'challenge': challengeId,
    };
  }

  PostModel copyWith({
    String? content,
    String? imageUrl,
    List<String>? likes,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      createdAt: createdAt,
      challengeId: challengeId,
      userName: userName,
      userAvatar: userAvatar,
    );
  }
}
