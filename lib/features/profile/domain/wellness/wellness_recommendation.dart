/// Represents a traditional lifestyle and wellness recommendation based on
/// Ayurvedic constitutional tendencies.
///
/// NOTE: Non-medical wellness suggestions strictly separated from clinical
/// advice per ADR-011 and Brain/pdr.md.
class WellnessRecommendation {
  final String id;
  final String category;
  final String title;
  final String description;
  final String iconName;

  /// Explicit flag asserting that this recommendation is strictly non-medical.
  final bool isMedicalClaim;

  const WellnessRecommendation({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.iconName,
    this.isMedicalClaim = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'title': title,
        'description': description,
        'icon_name': iconName,
        'is_medical_claim': isMedicalClaim,
      };

  factory WellnessRecommendation.fromJson(Map<String, dynamic> json) =>
      WellnessRecommendation(
        id: json['id'] as String,
        category: json['category'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        iconName: json['icon_name'] as String? ?? 'spa',
        isMedicalClaim: json['is_medical_claim'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WellnessRecommendation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          category == other.category &&
          title == other.title;

  @override
  int get hashCode => Object.hash(id, category, title);
}
