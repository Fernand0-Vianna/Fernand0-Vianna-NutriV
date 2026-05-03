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

    // Delete do Supabase - deleta a refeição e seus itens
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        // Primeiro deletar os meal_items relacionados
        await _supabase.from('meal_items').delete().eq('meal_id', mealId);

        // Depois deletar a refeição
        await _supabase
            .from('meals')
            .delete()
            .eq('id', mealId)
            .eq('user_id', userId);
      }
    } catch (e) {
      debugPrint('Erro ao deletar do Supabase: $e');
    }
  }

  Future<void> updateMeal(Meal meal) async {
    await saveMeal(meal);
  }

  Future<void> _saveLocal(List<Meal> meals) async {
    final mealsJson =
        meals.map((m) => MealModel.fromEntity(m).toJson()).toList();
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
        debugPrint('Sync: Usuário não autenticado, salvando apenas localmente');
        return;
      }

      final date =
          '${meal.dateTime.year}-${meal.dateTime.month.toString().padLeft(2, '0')}-${meal.dateTime.day.toString().padLeft(2, '0')}';

      // 1. Criar/atualizar a refeição principal
      final mealData = await _supabase
          .from('meals')
          .upsert({
            'id': meal.id,
            'user_id': userId,
            'name': meal.name,
            'meal_type': meal.mealType.toLowerCase(),
            'consumed_at': meal.dateTime.toIso8601String(),
            'date': date,
            'input_method': 'manual',
          }, onConflict: 'id')
          .select('id')
          .maybeSingle();

      if (mealData == null) {
        debugPrint('Sync: Erro ao criar refeição principal');
        return;
      }

      // 2. Para cada alimento na refeição, criar meal_items
      for (final mealFood in meal.foods) {
        // Primeiro, garantir que o alimento existe na tabela foods
        String foodId = await _ensureFoodExists(mealFood.food, userId);

        // Criar o meal_item com ID único
        final itemId = '${mealData['id']}_${foodId}_${DateTime.now().millisecondsSinceEpoch}';
        await _supabase.from('meal_items').upsert({
          'id': itemId,
          'meal_id': mealData['id'],
          'food_id': foodId,
          'food_name': mealFood.food.name,
          'quantity_g': mealFood.quantity,
          'calories': mealFood.food.calories * (mealFood.quantity / 100),
          'protein_g': mealFood.food.protein * (mealFood.quantity / 100),
          'carbs_g': mealFood.food.carbs * (mealFood.quantity / 100),
          'fat_g': mealFood.food.fat * (mealFood.quantity / 100),
          'fiber_g': mealFood.food.fiber * (mealFood.quantity / 100),
          'input_method': 'manual',
        }, onConflict: 'id');
      }

      debugPrint('Sync: Refeição ${meal.name} sincronizada com sucesso');
    } catch (e, stackTrace) {
      debugPrint('Sync: Erro ao sincronizar refeição: $e');
      debugPrint('Stack trace: $stackTrace');
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
        .from('meals')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('consumed_at', ascending: false)
        .asyncMap((meals) => _parseMealsToMealList(meals));
  }

  Future<List<Meal>> _parseMealsToMealList(
    List<Map<String, dynamic>> meals,
  ) async {
    final List<Meal> mealList = [];

    for (final mealData in meals) {
      // Buscar meal_items relacionados
      final items = await _supabase
          .from('meal_items')
          .select('*, foods(*)')
          .eq('meal_id', mealData['id']);

      final foods = <MealFood>[];

      for (final item in items) {
        final foodData = item['foods'] as Map<String, dynamic>;
        foods.add(
          MealFood(
            id: item['id'] as String,
            food: FoodItem(
              id: foodData['id'] as String,
              name: foodData['name'] as String,
              calories: (foodData['calories'] as num?)?.toDouble() ?? 0,
              protein: (foodData['protein'] as num?)?.toDouble() ?? 0,
              carbs: (foodData['carbs'] as num?)?.toDouble() ?? 0,
              fat: (foodData['fat'] as num?)?.toDouble() ?? 0,
              fiber: (foodData['fiber'] as num?)?.toDouble() ?? 0,
              portion: (foodData['serving_size'] as num?)?.toDouble() ?? 100,
            ),
            quantity: (item['quantity_g'] as num).toDouble(),
          ),
        );
      }

      if (foods.isNotEmpty) {
        mealList.add(
          Meal(
            id: mealData['id'] as String,
            name: mealData['name'] as String,
            dateTime: DateTime.parse(mealData['consumed_at'] as String),
            mealType: mealData['meal_type'] as String,
            foods: foods,
            notes: mealData['notes'] as String?,
          ),
        );
      }
    }

    return mealList;
  }

  String exportMealsToCsv(List<Meal> meals) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Data,Refeição,Alimento,Quantidade (g),Calorias,Proteína (g),Carboidratos (g),Gordura (g)',
    );

    for (final meal in meals) {
      for (final food in meal.foods) {
        final date =
            '${meal.dateTime.day}/${meal.dateTime.month}/${meal.dateTime.year}';
        buffer.writeln(
          '$date,${meal.name},${food.food.name},${food.quantity.toInt()},'
          '${food.food.calories.toInt()},${food.food.protein.toInt()},'
          '${food.food.carbs.toInt()},${food.food.fat.toInt()}',
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
