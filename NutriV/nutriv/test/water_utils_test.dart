import 'package:flutter_test/flutter_test.dart';
import 'package:nutriv/core/utils/helpers.dart';

void main() {
  group('WaterUtils', () {
    group('calculateWaterGoal', () {
      test('calculates base water goal correctly', () {
        final water = WaterUtils.calculateWaterGoal(
          weightKg: 70.0,
          activityLevel: 1,
        );
        expect(water, greaterThan(2000));
        expect(water, lessThan(3000));
      });

      test('increases with weight', () {
        final waterLight = WaterUtils.calculateWaterGoal(
          weightKg: 50.0,
          activityLevel: 1,
        );
        final waterHeavy = WaterUtils.calculateWaterGoal(
          weightKg: 100.0,
          activityLevel: 1,
        );
        expect(waterHeavy, greaterThan(waterLight));
      });

      test('increases with activity level', () {
        final waterSedentary = WaterUtils.calculateWaterGoal(
          weightKg: 70.0,
          activityLevel: 0,
        );
        final waterActive = WaterUtils.calculateWaterGoal(
          weightKg: 70.0,
          activityLevel: 3,
        );
        expect(waterActive, greaterThan(waterSedentary));
      });

      test('very active has highest water goal', () {
        final waterSedentary = WaterUtils.calculateWaterGoal(
          weightKg: 70.0,
          activityLevel: 0,
        );
        final waterVeryActive = WaterUtils.calculateWaterGoal(
          weightKg: 70.0,
          activityLevel: 4,
        );
        expect(waterVeryActive, greaterThan(waterSedentary));
      });
    });
  });
}