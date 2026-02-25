import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/storage/hive_service.dart';

class FoodItem {
  final String id;
  final String name;
  final String brand;
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final String imageUrl;

  FoodItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.imageUrl,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    final nutriments = json['nutriments'] ?? {};

    // Open Food Facts returns energy sometimes as kj, we want kcal. 'energy-kcal_100g'
    double extractNutrient(String key) {
      final val = nutriments[key];
      if (val is int) return val.toDouble();
      if (val is double) return val;
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return FoodItem(
      id: json['code'] ?? json['id'] ?? '',
      name: json['product_name'] ?? 'Unknown Food',
      brand: json['brands'] ?? '',
      calories: extractNutrient('energy-kcal_100g'),
      proteinGrams: extractNutrient('proteins_100g'),
      carbsGrams: extractNutrient('carbohydrates_100g'),
      fatGrams: extractNutrient('fat_100g'),
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'imageUrl': imageUrl,
    };
  }
}

class FoodRepository {
  static const String _baseUrl = 'https://world.openfoodfacts.org';

  /// Search for food items by text
  Future<List<FoodItem>> searchFood(String query) async {
    if (query.isEmpty) return [];

    final cacheKey = 'search_$query';
    final box = HiveService.foodCacheBox;

    // Check cache
    if (box.containsKey(cacheKey)) {
      try {
        final cachedData = box.get(cacheKey) as List<dynamic>;
        return cachedData
            .map((item) => FoodItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } catch (e) {
        // Cache read failed, proceed to network
      }
    }

    // Network request
    final uri = Uri.parse(
        '$_baseUrl/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&search_simple=1&action=process&json=1&page_size=20');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> products = data['products'] ?? [];

        final List<FoodItem> items = products
            .map((p) => FoodItem.fromJson(p as Map<String, dynamic>))
            .where(
                (item) => item.name.isNotEmpty && item.name != 'Unknown Food')
            .toList();

        // Save to cache
        await box.put(cacheKey, items.map((e) => e.toJson()).toList());

        return items;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get a specific food item by barcode
  Future<FoodItem?> getFoodByBarcode(String barcode) async {
    if (barcode.isEmpty) return null;

    final cacheKey = 'barcode_$barcode';
    final box = HiveService.foodCacheBox;

    // Check cache
    if (box.containsKey(cacheKey)) {
      try {
        final cachedData = box.get(cacheKey) as Map<dynamic, dynamic>;
        return FoodItem.fromJson(Map<String, dynamic>.from(cachedData));
      } catch (e) {
        // Continue to network
      }
    }

    // Network request
    final uri = Uri.parse('$_baseUrl/api/v0/product/$barcode.json');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 1 && data['product'] != null) {
          final item =
              FoodItem.fromJson(data['product'] as Map<String, dynamic>);

          // Save to cache
          await box.put(cacheKey, item.toJson());
          return item;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
