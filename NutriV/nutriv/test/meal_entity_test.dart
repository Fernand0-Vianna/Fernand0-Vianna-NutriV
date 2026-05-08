import 'package:flutter_test/flutter_test.dart';
import 'package:nutriv/domain/entities/meal.dart';
import 'package:nutriv/domain/entities/food_item.dart';

void main() {
  group('Meal Entity', () {
    test('creates meal with required fields', () {
      final meal = Meal(
        id: '1',
        name: 'Almoço',
        mealType: 'almoço',
        dateTime: DateTime.now(),
        foods: [],
      );

      expect(meal.id, '1');
      expect(meal.name, 'Almoço');
      expect(meal.mealType, 'almoço');
      expect(meal.foods, isEmpty);
    });

    test('calculates total calories correctly', () {
      final meal = Meal(
        id: '1',
        name: 'Almoço',
        mealType: 'almoço',
        dateTime: DateTime.now(),
        foods: [
          MealFood(
            id: 'f1',
            food: FoodItem(
              id: 'food1',
              name: 'Arroz',
              calories: 130,
              protein: 2.7,
              carbs: 28,
              fat: 0.3,
              portion: 100,
            ),
            quantity: 100,
          ),
          MealFood(
            id: 'f2',
            food: FoodItem(
              id: 'food2',
              name: 'Frango',
              calories: 165,
              protein: 31,
              carbs: 0,
              fat: 3.6,
              portion: 100,
            ),
            quantity: 100,
          ),
        ],
      );

      expect(meal.totalCalories, closeTo(295, 1));
    });

    test('calculates total protein correctly', () {
      final meal = Meal(
        id: '1',
        name: 'Almoço',
        mealType: 'almoço',
        dateTime: DateTime.now(),
        foods: [
          MealFood(
            id: 'f1',
            food: FoodItem(
              id: 'food1',
              name: 'Arroz',
              calories: 130,
              protein: 2.7,
              carbs: 28,
              fat: 0.3,
              portion: 100,
            ),
            quantity: 100,
          ),
          MealFood(
            id: 'f2',
            food: FoodItem(
              id: 'food2',
              name: 'Frango',
              calories: 165,
              protein: 31,
              carbs: 0,
              fat: 3.6,
              portion: 100,
            ),
            quantity: 100,
          ),
        ],
      );

      expect(meal.totalProtein, closeTo(33.7, 0.1));
    });

    test('calculates total carbs correctly', () {
      final meal = Meal(
        id: '1',
        name: 'Almoço',
        mealType: 'almoço',
        dateTime: DateTime.now(),
        foods: [
          MealFood(
            id: 'f1',
            food: FoodItem(
              id: 'food1',
              name: 'Arroz',
              calories: 130,
              protein: 2.7,
              carbs: 28,
              fat: 0.3,
              portion: 100,
            ),
            quantity: 100,
          ),
        ],
      );

      expect(meal.totalCarbs, closeTo(28.0, 0.01));
    });

    test('calculates total fat correctly', () {
      final meal = Meal(
        id: '1',
        name: 'Almoço',
        mealType: 'almoço',
        dateTime: DateTime.now(),
        foods: [
          MealFood(
            id: 'f1',
            food: FoodItem(
              id: 'food1',
              name: 'Arroz',
              calories: 130,
              protein: 2.7,
              carbs: 28,
              fat: 0.3,
              portion: 100,
            ),
            quantity: 100,
          ),
        ],
      );

      expect(meal.totalFat, 0.3);
    });
  });
}