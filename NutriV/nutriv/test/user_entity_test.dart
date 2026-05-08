import 'package:flutter_test/flutter_test.dart';
import 'package:nutriv/domain/entities/user.dart';

void main() {
  group('User Entity', () {
    test('creates user with required fields', () {
      final user = User(
        id: '123',
        name: 'João',
        weight: 70,
        height: 175,
        age: 30,
        isMale: true,
        activityLevel: 2,
        goal: 'maintain',
        calorieGoal: 2000,
        proteinGoal: 150,
        carbsGoal: 250,
        fatGoal: 65,
        waterGoal: 2500,
        createdAt: DateTime.now(),
      );

      expect(user.id, '123');
      expect(user.name, 'João');
      expect(user.weight, 70);
      expect(user.height, 175);
    });

    test('copyWith creates new instance with updated fields', () {
      final user = User(
        id: '123',
        name: 'João',
        weight: 70,
        height: 175,
        age: 30,
        isMale: true,
        activityLevel: 2,
        goal: 'maintain',
        calorieGoal: 2000,
        proteinGoal: 150,
        carbsGoal: 250,
        fatGoal: 65,
        waterGoal: 2500,
        createdAt: DateTime.now(),
      );

      final updatedUser = user.copyWith(
        weight: 75,
        calorieGoal: 2200,
      );

      expect(updatedUser.weight, 75);
      expect(updatedUser.calorieGoal, 2200);
      expect(updatedUser.name, 'João');
      expect(updatedUser.height, 175);
    });

    test('two users with same props are equal', () {
      final createdAt = DateTime.now();
      final user1 = User(
        id: '123',
        name: 'João',
        weight: 70,
        height: 175,
        age: 30,
        isMale: true,
        activityLevel: 2,
        goal: 'maintain',
        calorieGoal: 2000,
        proteinGoal: 150,
        carbsGoal: 250,
        fatGoal: 65,
        waterGoal: 2500,
        createdAt: createdAt,
      );

      final user2 = User(
        id: '123',
        name: 'João',
        weight: 70,
        height: 175,
        age: 30,
        isMale: true,
        activityLevel: 2,
        goal: 'maintain',
        calorieGoal: 2000,
        proteinGoal: 150,
        carbsGoal: 250,
        fatGoal: 65,
        waterGoal: 2500,
        createdAt: createdAt,
      );

      expect(user1, equals(user2));
    });
  });
}