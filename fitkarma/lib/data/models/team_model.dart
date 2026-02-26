import 'package:hive/hive.dart';

part 'team_model.g.dart';

@HiveType(typeId: 13)
class TeamModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> memberIds;

  @HiveField(3)
  final int totalKarma;

  @HiveField(4)
  final String? logoUrl;

  @HiveField(5)
  final String? description;

  TeamModel({
    required this.id,
    required this.name,
    required this.memberIds,
    this.totalKarma = 0,
    this.logoUrl,
    this.description,
  });

  TeamModel copyWith({
    String? name,
    List<String>? memberIds,
    int? totalKarma,
    String? logoUrl,
    String? description,
  }) {
    return TeamModel(
      id: id,
      name: name ?? this.name,
      memberIds: memberIds ?? this.memberIds,
      totalKarma: totalKarma ?? this.totalKarma,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
    );
  }

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unnamed Team',
      memberIds: List<String>.from(json['members'] ?? []),
      totalKarma: json['total_karma'] ?? 0,
      logoUrl: json['logo_url'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'members': memberIds,
      'total_karma': totalKarma,
      'logo_url': logoUrl,
      'description': description,
    };
  }
}
