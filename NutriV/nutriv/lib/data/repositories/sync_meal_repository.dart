import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/food_item.dart';
import '../models/meal_model.dart';

class SyncMealRepository {
  final SharedPreferences _prefs;
  final SupabaseClient _supabase;

  static const String _localMealsKey = 'meals';

  SyncMealRepository(this._prefs, this._supabase);

  List<Meal> getAllMeals() {
    final mealsData = _prefs.getString(_localMealsKey);
    if (mealsData != null) {
      final List<dynamic> decoded = jsonDecode(mealsData);
      return decoded.map((m) => MealModel.fromJson(m)).toList();
    }
    return [];
  }

  Future<void> syncToSupabase(Meal meal) async {
    try {
      await _supabase.from('meals').upsert({
        'id': meal.id,
        'name': meal.name,
        'date_time': meal.dateTime.toIso8601String(),
        'meal_type': meal.mealType,
        'foods': jsonEncode(
          meal.foods
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
        ),
        'notes': meal.notes,
        'user_id': _supabase.auth.currentUser?.id,
      });
    } catch (e) {
      // Ignora erro de sync
    }
  }

  Future<void> saveMeal(Meal meal) async {
    final meals = getAllMeals();
    final index = meals.indexWhere((m) => m.id == meal.id);

    if (index >= 0) {
      meals[index] = meal;
    } else {
      meals.add(meal);
    }

    await _saveLocal(meals);
    await syncToSupabase(meal);
  }

  Future<void> _saveLocal(List<Meal> meals) async {
    final mealsJson = meals
        .map((m) => MealModel.fromEntity(m).toJson())
        .toList();
    await _prefs.setString(_localMealsKey, jsonEncode(mealsJson));
  }

  Stream<List<Meal>> watchMeals() {
    return _supabase
        .from('meals')
        .stream(primaryKey: ['id'])
        .map((maps) => maps.map((m) => _parseSupabaseMeal(m)).toList());
  }

  Meal _parseSupabaseMeal(Map<String, dynamic> map) {
    final foods = <MealFood>[];
    if (map['foods'] != null) {
      final List<dynamic> foodsList = map['foods'] is String
          ? jsonDecode(map['foods'])
          : map['foods'];
      for (var f in foodsList) {
        foods.add(
          MealFood(
            id: f['id'],
            food: FoodItem(
              id: f['food']['id'],
              name: f['food']['name'],
              calories: (f['food']['calories'] as num).toDouble(),
              protein: (f['food']['protein'] as num).toDouble(),
              carbs: (f['food']['carbs'] as num).toDouble(),
              fat: (f['food']['fat'] as num).toDouble(),
              portion: (f['food']['portion'] as num).toDouble(),
            ),
            quantity: (f['quantity'] as num).toDouble(),
          ),
        );
      }
    }

    return Meal(
      id: map['id'],
      name: map['name'],
      dateTime: DateTime.parse(map['date_time']),
      mealType: map['meal_type'],
      foods: foods,
      notes: map['notes'],
    );
  }
}
