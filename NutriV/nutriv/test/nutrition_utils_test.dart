import 'package:flutter_test/flutter_test.dart';
import 'package:nutriv/core/utils/helpers.dart';

void main() {
  group('NutritionUtils', () {
    group('calculateBMR', () {
      test('calculates BMR correctly for male', () {
        final bmr = NutritionUtils.calculateBMR(
          weight: 70,
          height: 175,
          age: 30,
          isMale: true,
        );
        expect(bmr, greaterThan(1500));
        expect(bmr, lessThan(1800));
      });

      test('calculates BMR correctly for female', () {
        final bmr = NutritionUtils.calculateBMR(
          weight: 60,
          height: 165,
          age: 25,
          isMale: false,
        );
        expect(bmr, greaterThan(1200));
        expect(bmr, lessThan(1600));
      });

      test('BMR increases with weight', () {
        final bmrLight = NutritionUtils.calculateBMR(
          weight: 60,
          height: 170,
          age: 30,
          isMale: true,
        );
        final bmrHeavy = NutritionUtils.calculateBMR(
          weight: 90,
          height: 170,
          age: 30,
          isMale: true,
        );
        expect(bmrHeavy, greaterThan(bmrLight));
      });

      test('BMR decreases with age', () {
        final bmrYoung = NutritionUtils.calculateBMR(
          weight: 70,
          height: 170,
          age: 20,
          isMale: true,
        );
        final bmrOld = NutritionUtils.calculateBMR(
          weight: 70,
          height: 170,
          age: 50,
          isMale: true,
        );
        expect(bmrYoung, greaterThan(bmrOld));
      });
    });

    group('calculateTDEE', () {
      test('sedentary activity has lowest multiplier', () {
        final bmr = 1500.0;
        final tdeeSedentary = NutritionUtils.calculateTDEE(bmr, 0);
        final tdeeModerate = NutritionUtils.calculateTDEE(bmr, 2);
        expect(tdeeSedentary, lessThan(tdeeModerate));
      });

      test('very active has highest multiplier', () {
        final bmr = 1500.0;
        final tdeeSedentary = NutritionUtils.calculateTDEE(bmr, 0);
        final tdeeVeryActive = NutritionUtils.calculateTDEE(bmr, 4);
        expect(tdeeVeryActive, greaterThan(tdeeSedentary));
      });
    });

    group('calculateGoalCalories', () {
      test('lose goal reduces calories', () {
        final tdee = 2000.0;
        final calories = NutritionUtils.calculateGoalCalories(tdee, 'lose');
        expect(calories, lessThan(tdee));
      });

      test('gain goal increases calories', () {
        final tdee = 2000.0;
        final calories = NutritionUtils.calculateGoalCalories(tdee, 'gain');
        expect(calories, greaterThan(tdee));
      });

      test('maintain goal keeps calories', () {
        final tdee = 2000.0;
        final calories = NutritionUtils.calculateGoalCalories(tdee, 'maintain');
        expect(calories, equals(tdee));
      });
    });

    group('parseWeight', () {
      test('parses kg correctly', () {
        expect(NutritionUtils.parseWeight('70'), equals(70.0));
        expect(NutritionUtils.parseWeight('70.5'), equals(70.5));
      });

      test('parses with kg suffix', () {
        expect(NutritionUtils.parseWeight('70kg'), equals(70.0));
        expect(NutritionUtils.parseWeight('70 kg'), equals(70.0));
      });
    });

    group('parseHeight', () {
      test('parses cm correctly', () {
        expect(NutritionUtils.parseHeight('170'), equals(170.0));
        expect(NutritionUtils.parseHeight('175.5'), equals(175.5));
      });

      test('parses with cm suffix', () {
        expect(NutritionUtils.parseHeight('170cm'), equals(170.0));
        expect(NutritionUtils.parseHeight('170 cm'), equals(170.0));
      });
    });
  });
}