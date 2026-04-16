import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/food_item.dart';
import '../models/meal_model.dart';

class FirestoreMealRepository {
  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;

  static const String _localMealsKey = 'meals';

  FirestoreMealRepository(this._prefs, this._firestore);

  List<Meal> getAllMeals() {
    final mealsData = _prefs.getString(_localMealsKey);
    if (mealsData != null) {
      final List<dynamic> decoded = jsonDecode(mealsData);
      return decoded.map((m) => MealModel.fromJson(m)).toList();
    }
    return [];
  }

  Future<void> saveLocal(List<Meal> meals) async {
    final mealsJson = meals
        .map((m) => MealModel.fromEntity(m).toJson())
        .toList();
    await _prefs.setString(_localMealsKey, jsonEncode(mealsJson));
  }

  Future<void> saveMeal(Meal meal) async {
    final meals = getAllMeals();
    final index = meals.indexWhere((m) => m.id == meal.id);

    if (index >= 0) {
      meals[index] = meal;
    } else {
      meals.add(meal);
    }

    await saveLocal(meals);
    await _syncToFirestore(meal);
  }

  Future<void> _syncToFirestore(Meal meal) async {
    try {
      await _firestore.collection('meals').doc(meal.id).set({
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
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> deleteMeal(String mealId) async {
    final meals = getAllMeals();
    meals.removeWhere((m) => m.id == mealId);
    await saveLocal(meals);

    try {
      await _firestore.collection('meals').doc(mealId).delete();
    } catch (_) {}
  }

  Future<void> updateMeal(Meal meal) async {
    await saveMeal(meal);
  }

  Stream<List<Meal>> watchMeals() {
    return _firestore
        .collection('meals')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return _parseFirestoreMeal(data);
          }).toList(),
        );
  }

  Meal _parseFirestoreMeal(Map<String, dynamic> data) {
    final foods = <MealFood>[];
    if (data['foods'] != null) {
      for (var f in data['foods']) {
        final foodData = f['food'] as Map<String, dynamic>;
        foods.add(
          MealFood(
            id: f['id'],
            food: FoodItem(
              id: foodData['id'],
              name: foodData['name'],
              calories: (foodData['calories'] as num).toDouble(),
              protein: (foodData['protein'] as num).toDouble(),
              carbs: (foodData['carbs'] as num).toDouble(),
              fat: (foodData['fat'] as num).toDouble(),
              portion: (foodData['portion'] as num).toDouble(),
            ),
            quantity: (f['quantity'] as num).toDouble(),
          ),
        );
      }
    }

    return Meal(
      id: data['id'],
      name: data['name'],
      dateTime: DateTime.parse(data['dateTime']),
      mealType: data['mealType'],
      foods: foods,
      notes: data['notes'],
    );
  }
}
