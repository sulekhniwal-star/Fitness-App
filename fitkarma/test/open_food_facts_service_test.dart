import 'package:flutter_test/flutter_test.dart';
import 'package:fitkarma/domain/services/open_food_facts_service.dart';

void main() {
  group('FoodProduct', () {
    test('should create FoodProduct from JSON', () {
      final json = {
        'code': '123456789',
        'product_name': 'Organic Oats',
        'brands': ' Quaker',
        'image_url': 'https://example.com/oats.jpg',
        'nutriments': {
          'energy-kcal_100g': 389,
          'proteins_100g': 16.9,
          'carbohydrates_100g': 66.3,
          'fat_100g': 6.9,
          'fiber_100g': 10.6,
          'sugars_100g': 0,
        },
        'serving_size': '40g',
      };

      final product = FoodProduct.fromJson(json);

      expect(product.code, '123456789');
      expect(product.name, 'Organic Oats');
      expect(product.brand, ' Quaker');
      expect(product.imageUrl, 'https://example.com/oats.jpg');
      expect(product.calories, 389);
      expect(product.protein, 16.9);
      expect(product.carbs, 66.3);
      expect(product.fat, 6.9);
      expect(product.fiber, 10.6);
      expect(product.sugar, 0);
      expect(product.servingSize, '40g');
    });

    test('should handle missing nutriments', () {
      final json = {
        'code': '123',
        'product_name': 'Simple Product',
      };

      final product = FoodProduct.fromJson(json);

      expect(product.code, '123');
      expect(product.name, 'Simple Product');
      expect(product.calories, 0);
      expect(product.protein, 0);
      expect(product.carbs, 0);
      expect(product.fat, 0);
    });

    test('should handle null values in nutriments', () {
      final json = {
        'code': '123',
        'product_name': 'Product',
        'nutriments': {
          'energy-kcal_100g': null,
          'proteins_100g': 10.0,
        },
      };

      final product = FoodProduct.fromJson(json);

      expect(product.calories, 0);
      expect(product.protein, 10.0);
    });

    test('should calculate calories for serving', () {
      final product = FoodProduct(
        code: '123',
        name: 'Test Product',
        calories: 400,
        protein: 20,
        carbs: 50,
        fat: 10,
      );

      final caloriesFor50g = product.calculateCaloriesForServing(50);
      expect(caloriesFor50g, 200); // 400 * 50 / 100
    });

    test('should convert to JSON correctly', () {
      final product = FoodProduct(
        code: '123',
        name: 'Test Product',
        brand: 'Test Brand',
        imageUrl: 'https://example.com/img.jpg',
        calories: 400,
        protein: 20,
        carbs: 50,
        fat: 10,
        fiber: 5,
        sugar: 8,
        servingSize: '100g',
      );

      final json = product.toJson();

      expect(json['code'], '123');
      expect(json['name'], 'Test Product');
      expect(json['brand'], 'Test Brand');
      expect(json['calories_per_100g'], 400);
      expect(json['protein_per_100g'], 20);
      expect(json['carbs_per_100g'], 50);
      expect(json['fat_per_100g'], 10);
      expect(json['fiber_per_100g'], 5);
      expect(json['sugar_per_100g'], 8);
      expect(json['serving_size'], '100g');
    });

    test('should handle string number values', () {
      final json = {
        'code': '123',
        'product_name': 'Product',
        'nutriments': {
          'energy-kcal_100g': '389.5',
          'proteins_100g': '16.9',
        },
      };

      final product = FoodProduct.fromJson(json);

      expect(product.calories, 389.5);
      expect(product.protein, 16.9);
    });

    test('should fallback for energy calculation when kcal not available', () {
      final json = {
        'code': '123',
        'product_name': 'Product',
        'nutriments': {
          'energy_100g': 1674, // kJ instead of kcal
        },
      };

      final product = FoodProduct.fromJson(json);

      // 1674 kJ / 4.184 ≈ 400 kcal
      expect(product.calories, closeTo(400, 1));
    });
  });
}
