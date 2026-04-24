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

  Future<void> deleteMeal(String mealId) async {
    final meals = getAllMeals();
    meals.removeWhere((m) => m.id == mealId);
    await _saveLocal(meals);

    // Delete do Supabase - deleta todos os food_logs relacionados a esta refeição
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _supabase
            .from('food_logs')
            .delete()
            .eq('user_id', userId)
            .eq('meal_type', mealId); // usando meal_id como identificador
      }
    } catch (e) {
      debugPrint('Erro ao deletar do Supabase: $e');
    }
  }

  Future<void> updateMeal(Meal meal) async {
    await saveMeal(meal);
  }

  Future<void> _saveLocal(List<Meal> meals) async {
    final mealsJson = meals
        .map((m) => MealModel.fromEntity(m).toJson())
        .toList();
    await _prefs.setString(_localMealsKey, jsonEncode(mealsJson));
  }

  Future<void> saveMeal(Meal meal) async {
    // 1. Salvar localmente
    final meals = getAllMeals();
    final index = meals.indexWhere((m) => m.id == meal.id);

    if (index >= 0) {
      meals[index] = meal;
    } else {
      meals.add(meal);
    }
    await _saveLocal(meals);

    // 2. Sincronizar com Supabase
    await _syncMealToSupabase(meal);
  }

  Future<void> _syncMealToSupabase(Meal meal) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('Sync: Usuário não autenticado');
        return;
      }

      final date =
          '${meal.dateTime.year}-${meal.dateTime.month.toString().padLeft(2, '0')}-${meal.dateTime.day.toString().padLeft(2, '0')}';

      // Para cada alimento na refeição, criar/atualizar um food_log
      for (final mealFood in meal.foods) {
        // Primeiro, garantir que o alimento existe na tabela foods
        String foodId = await _ensureFoodExists(mealFood.food, userId);

        // Inserir/atualizar o food_log
        await _supabase.from('food_logs').upsert({
          'user_id': userId,
          'food_id': foodId,
          'quantity': mealFood.quantity,
          'meal_type': meal.mealType
              .toLowerCase(), // breakfast, lunch, dinner, snack
          'date': date,
        }, onConflict: 'user_id,food_id,date,meal_type');
      }

      debugPrint('Sync: Refeição ${meal.name} sincronizada com sucesso');
    } catch (e) {
      debugPrint('Sync: Erro ao sincronizar refeição: $e');
    }
  }

  Future<String> _ensureFoodExists(FoodItem food, String userId) async {
    try {
      // Tentar encontrar alimento existente pelo nome
      final existing = await _supabase
          .from('foods')
          .select('id')
          .eq('name', food.name)
          .maybeSingle();

      if (existing != null) {
        return existing['id'] as String;
      }

      // Criar novo alimento
      final result = await _supabase
          .from('foods')
          .insert({
            'name': food.name,
            'calories': food.calories,
            'protein': food.protein,
            'carbs': food.carbs,
            'fat': food.fat,
            'serving_size': food.portion,
            'created_by': userId,
          })
          .select('id')
          .single();

      return result['id'] as String;
    } catch (e) {
      debugPrint('Erro ao garantir existência do alimento: $e');
      // Retornar ID temporário em caso de erro
      return food.id;
    }
  }

  Stream<List<Meal>> watchMeals() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _supabase
        .from('food_logs')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .asyncMap((logs) => _parseFoodLogsToMeals(logs));
  }

  Future<List<Meal>> _parseFoodLogsToMeals(
    List<Map<String, dynamic>> logs,
  ) async {
    // Agrupar logs por data e meal_type
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final log in logs) {
      final date = log['date'] as String;
      final mealType = log['meal_type'] as String;
      final key = '$date-$mealType';

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(log);
    }

    final List<Meal> meals = [];

    for (final entry in grouped.entries) {
      final foods = <MealFood>[];

      for (final log in entry.value) {
        // Buscar detalhes do alimento
        final foodData = await _supabase
            .from('foods')
            .select()
            .eq('id', log['food_id'])
            .maybeSingle();

        if (foodData != null) {
          foods.add(
            MealFood(
              id: log['id'] as String,
              food: FoodItem(
                id: foodData['id'] as String,
                name: foodData['name'] as String,
                calories: (foodData['calories'] as num).toDouble(),
                protein: (foodData['protein'] as num?)?.toDouble() ?? 0,
                carbs: (foodData['carbs'] as num?)?.toDouble() ?? 0,
                fat: (foodData['fat'] as num?)?.toDouble() ?? 0,
                portion: (foodData['serving_size'] as num?)?.toDouble() ?? 100,
              ),
              quantity: (log['quantity'] as num).toDouble(),
            ),
          );
        }
      }

      if (foods.isNotEmpty) {
        final parts = entry.key.split('-');
        final date = DateTime.parse(parts[0]);
        final mealType = parts[1];

        meals.add(
          Meal(
            id: entry.key,
            name: _getMealName(mealType),
            dateTime: date,
            mealType: mealType,
            foods: foods,
            notes: null,
          ),
        );
      }
    }

    return meals;
  }

  String _getMealName(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Café da Manhã';
      case 'lunch':
        return 'Almoço';
      case 'dinner':
        return 'Jantar';
      case 'snack':
        return 'Lanche';
      default:
        return 'Refeição';
    }
  }

  String exportMealsToCsv(List<Meal> meals) {
    final buffer = StringBuffer();
    buffer.writeln('Data,Refeição,Alimento,Quantidade (g),Calorias,Proteína (g),Carboidratos (g),Gordura (g)');
    
    for (final meal in meals) {
      for (final food in meal.foods) {
        final date = '${meal.dateTime.day}/${meal.dateTime.month}/${meal.dateTime.year}';
        buffer.writeln(
          '$date,${meal.name},${food.food.name},${food.quantity.toInt()},'
          '${food.food.calories.toInt()},${food.food.protein.toInt()},'
          '${food.food.carbs.toInt()},${food.food.fat.toInt()}'
        );
      }
    }
    
    return buffer.toString();
  }
}

// Helper para debug
void debugPrint(String message) {
  // ignore: avoid_print
  print('[SyncMealRepository] $message');
}
