import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Service for integrating with Open Food Facts API
class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';
  
  /// Search for products by name
  Future<List<FoodProduct>> searchProducts(String query, {int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?search_terms=${Uri.encodeComponent(query)}&page=$page&page_size=20&fields=product_name,brands,nutriments,image_url,code'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = (data['products'] as List<dynamic>?)
            ?.map((p) => FoodProduct.fromJson(p))
            .where((p) => p.name.isNotEmpty)
            .toList() ?? [];
        return products;
      }
      return [];
    } catch (e) {
      debugPrint('Error searching Open Food Facts: $e');
      return [];
    }
  }
  
  /// Get product by barcode
  Future<FoodProduct?> getProductByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/product/$barcode.json?fields=product_name,brands,nutriments,image_url,code,serving_size'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          return FoodProduct.fromJson(data['product']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching product by barcode: $e');
      return null;
    }
  }
  
  /// Get product nutrients by barcode
  Future<Map<String, dynamic>?> getProductNutrients(String barcode) async {
    final product = await getProductByBarcode(barcode);
    if (product == null) return null;
    
    return {
      'calories': product.calories,
      'protein': product.protein,
      'carbs': product.carbs,
      'fat': product.fat,
      'fiber': product.fiber,
      'sugar': product.sugar,
    };
  }
}

/// Model representing a food product from Open Food Facts
class FoodProduct {
  final String code;
  final String name;
  final String? brand;
  final String? imageUrl;
  final double calories; // per 100g
  final double protein; // per 100g
  final double carbs; // per 100g
  final double fat; // per 100g
  final double? fiber; // per 100g
  final double? sugar; // per 100g
  final String? servingSize;

  FoodProduct({
    required this.code,
    required this.name,
    this.brand,
    this.imageUrl,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sugar,
    this.servingSize,
  });

  factory FoodProduct.fromJson(Map<String, dynamic> json) {
    final nutriments = json['nutriments'] as Map<String, dynamic>? ?? {};
    
    return FoodProduct(
      code: json['code'] as String? ?? '',
      name: json['product_name'] as String? ?? 'Unknown Product',
      brand: json['brands'] as String?,
      imageUrl: json['image_url'] as String?,
      calories: _parseDouble(nutriments['energy-kcal_100g']) ?? 
                _parseDouble(nutriments['energy-kcal']) ?? 
                (_parseDouble(nutriments['energy_100g']) ?? 0) / 4.184,
      protein: _parseDouble(nutriments['proteins_100g']) ?? 0,
      carbs: _parseDouble(nutriments['carbohydrates_100g']) ?? 0,
      fat: _parseDouble(nutriments['fat_100g']) ?? 0,
      fiber: _parseDouble(nutriments['fiber_100g']),
      sugar: _parseDouble(nutriments['sugars_100g']),
      servingSize: json['serving_size'] as String?,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Calculate calories for a given serving size in grams
  double calculateCaloriesForServing(double grams) {
    return (calories / 100) * grams;
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'brand': brand,
      'image_url': imageUrl,
      'calories_per_100g': calories,
      'protein_per_100g': protein,
      'carbs_per_100g': carbs,
      'fat_per_100g': fat,
      'fiber_per_100g': fiber,
      'sugar_per_100g': sugar,
      'serving_size': servingSize,
    };
  }
}

/// Provider for Open Food Facts service
final openFoodFactsServiceProvider = Provider<OpenFoodFactsService>((ref) {
  return OpenFoodFactsService();
});
