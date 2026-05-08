import '../../data/repositories/meal_repository_v2.dart';

abstract class IMealRepositoryV2 {
  Future<MealData> createMeal(MealData meal);
  Future<List<MealData>> getMealsForDate(DateTime date);
  Future<List<MealData>> getMealsForDateRange(DateTime start, DateTime end);
  Future<MealData> updateMeal(String mealId, MealData meal);
  Future<void> deleteMeal(String mealId);
  Future<void> addItemToMeal(String mealId, MealItemData item);
  Future<void> removeItemFromMeal(String itemId);
  Future<void> markAiAsEdited(String mealId);
  Stream<List<MealData>> watchMealsForDate(DateTime date);
}
