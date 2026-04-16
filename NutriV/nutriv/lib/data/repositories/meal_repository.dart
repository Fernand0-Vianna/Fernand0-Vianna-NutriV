import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/meal.dart';
import '../models/meal_model.dart';

class MealRepository {
  final SharedPreferences _prefs;
  FirebaseFirestore? _firestore;

  MealRepository(this._prefs);

  void setFirestore(FirebaseFirestore firestore) {
    _firestore = firestore;
  }

  Future<void> _syncToCloud(Meal meal) async {
    if (_firestore == null) return;
    try {
      await _firestore!.collection('meals').doc(meal.id).set({
        'id': meal.id,
        'name': meal.name,
        'dateTime': meal.dateTime.toIso8601String(),
        'mealType': meal.mealType,
        'foods': meal.foods
            .map(
              (f) => {
                'id': f.id,
                'food': {
                  'id': f.food.id,
                  'name': f.food.name,
                  'calories': f.food.calories,
                  'protein': f.food.protein,
                  'carbs': f.food.carbs,
                  'fat': f.food.fat,
                  'portion': f.food.portion,
                },
                'quantity': f.quantity,
              },
            )
            .toList(),
        'notes': meal.notes,
      });
    } catch (_) {}
  }

  Future<void> saveMeal(Meal meal) async {
    final meals = getAllMeals();
    final index = meals.indexWhere((m) => m.id == meal.id);

    if (index >= 0) {
      meals[index] = meal;
    } else {
      meals.add(meal);
    }

    final mealsJson = meals
        .map((m) => MealModel.fromEntity(m).toJson())
        .toList();
    await _prefs.setString('meals', jsonEncode(mealsJson));
    await _syncToCloud(meal);
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

    final mealsJson = meals
        .map((m) => MealModel.fromEntity(m).toJson())
        .toList();
    await _prefs.setString('meals', jsonEncode(mealsJson));

    if (_firestore != null) {
      try {
        await _firestore!.collection('meals').doc(mealId).delete();
      } catch (_) {}
    }
  }

  Future<void> updateMeal(Meal meal) async {
    await saveMeal(meal);
  }
}
