import 'package:flutter_test/flutter_test.dart';
import 'package:fitkarma/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should create UserModel from JSON', () {
      final json = {
        'id': 'test123',
        'email': 'test@example.com',
        'name': 'Test User',
        'karma_points': 100,
        'streak_days': 5,
        'subscription_tier': 'free',
        'created': '2024-01-01T00:00:00.000Z',
        'updated': '2024-01-01T00:00:00.000Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'test123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.karmaPoints, 100);
      expect(user.streakDays, 5);
      expect(user.subscriptionTier, 'free');
    });

    test('should calculate BMI correctly', () {
      final user = UserModel(
        id: 'test',
        email: 'test@test.com',
        name: 'Test',
        heightCm: 170,
        weightKg: 70,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(user.bmi, closeTo(24.2, 0.1));
    });

    test('should return null BMI when height is invalid', () {
      final user = UserModel(
        id: 'test',
        email: 'test@test.com',
        name: 'Test',
        heightCm: 0,
        weightKg: 70,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(user.bmi, isNull);
    });

    test('should return correct BMI category', () {
      final underweight = UserModel(
        id: '1',
        email: 'a@a.com',
        name: 'A',
        heightCm: 170,
        weightKg: 50,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(underweight.bmiCategory, 'Underweight');

      final normal = UserModel(
        id: '2',
        email: 'b@b.com',
        name: 'B',
        heightCm: 170,
        weightKg: 65,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(normal.bmiCategory, 'Normal');

      final overweight = UserModel(
        id: '3',
        email: 'c@c.com',
        name: 'C',
        heightCm: 170,
        weightKg: 80,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(overweight.bmiCategory, 'Overweight');

      final obese = UserModel(
        id: '4',
        email: 'd@d.com',
        name: 'D',
        heightCm: 170,
        weightKg: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(obese.bmiCategory, 'Obese');
    });

    test('should convert to JSON correctly', () {
      final user = UserModel(
        id: 'test123',
        email: 'test@example.com',
        name: 'Test User',
        karmaPoints: 100,
        streakDays: 5,
        subscriptionTier: 'free',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      final json = user.toJson();

      expect(json['id'], 'test123');
      expect(json['email'], 'test@example.com');
      expect(json['name'], 'Test User');
      expect(json['karma_points'], 100);
    });

    test('should copy with new values', () {
      final user = UserModel(
        id: 'test',
        email: 'test@test.com',
        name: 'Original',
        karmaPoints: 50,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = user.copyWith(name: 'Updated', karmaPoints: 100);

      expect(updated.name, 'Updated');
      expect(updated.karmaPoints, 100);
      expect(updated.email, 'test@test.com'); // unchanged
    });
  });
}
