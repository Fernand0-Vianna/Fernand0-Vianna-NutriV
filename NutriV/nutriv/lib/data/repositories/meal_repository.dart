import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/meal.dart';
import '../models/meal_model.dart';

class MealRepository {
  final SharedPreferences _prefs;

  MealRepository(this._prefs);

  Future<void> saveMeal(Meal meal) async {
    final meals = getAllMeals();
    final index = meals.indexWhere((m) => m.id == meal.id);

    if (index >= 0) {
      meals[index] = meal;
    } else {
      meals.add(meal);
    }

    final mealsJson =
        meals.map((m) => MealModel.fromEntity(m).toJson()).toList();
    await _prefs.setString('meals', jsonEncode(mealsJson));
  }

  List<Meal> getAllMeals() {
    final mealsData = _prefs.getString('meals');
    if (mealsData != null) {
      final List<dynamic> decoded = jsonDecode(mealsData);
      return decoded.map((m) => MealModel.fromJson(m)).toList();
    }
    return [];
  }

  List<Meal> getMealsByDate(DateTime date) {
    final meals = getAllMeals();
    return meals
        .where(
          (m) =>
              m.dateTime.year == date.year &&
              m.dateTime.month == date.month &&
              m.dateTime.day == date.day,
        )
        .toList();
  }

  List<Meal> getMealsByDateAndType(DateTime date, String mealType) {
    final meals = getMealsByDate(date);
    return meals.where((m) => m.mealType == mealType).toList();
  }

  Future<void> deleteMeal(String mealId) async {
    final meals = getAllMeals();
    meals.removeWhere((m) => m.id == mealId);

    final mealsJson =
        meals.map((m) => MealModel.fromEntity(m).toJson()).toList();
    await _prefs.setString('meals', jsonEncode(mealsJson));
  }

  Future<void> updateMeal(Meal meal) async {
    await saveMeal(meal);
  }
}
