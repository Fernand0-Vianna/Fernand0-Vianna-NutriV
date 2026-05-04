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

  Future<List<Meal>> getAllMeals() async {
    final mealsData = _prefs.getString(_localMealsKey);
    if (mealsData != null) {
      final List<dynamic> decoded = jsonDecode(mealsData);
      final meals = decoded.map((m) => MealModel.fromJson(m)).toList();
      if (meals.isNotEmpty) return meals;
    }
    // Se local vazio, faz pull do Supabase e aguarda
    await _pullFromSupabase();
    // Tenta novamente após o pull
    final afterPullData = _prefs.getString(_localMealsKey);
    if (afterPullData != null) {
      final List<dynamic> decoded = jsonDecode(afterPullData);
      return decoded.map((m) => MealModel.fromJson(m)).toList();
    }
    return [];
  }

  // Versão síncrona para compatibilidade (usada pelo BLoC)
  List<Meal> getAllMealsSync() {
    final mealsData = _prefs.getString(_localMealsKey);
    if (mealsData != null) {
      final List<dynamic> decoded = jsonDecode(mealsData);
      return decoded.map((m) => MealModel.fromJson(m)).toList();
    }
    // Se local vazio, agenda pull para próxima vez
    _pullFromSupabase();
    return [];
  }

  Future<void> init() async {
    await processPendingSync();
    await _pullFromSupabase();
  }

  Future<void> _pullFromSupabase() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      _logDebug('Pull: Buscando refeições do Supabase...');
      final meals = await _supabase
          .from('meals')
          .select('*, meal_items(*, foods(*))')
          .eq('user_id', userId)
          .order('consumed_at', ascending: false);

      final mealList = <Meal>[];
      for (final mealData in meals) {
        final items = mealData['meal_items'] as List<dynamic>? ?? [];
        final foods = <MealFood>[];

        for (final item in items) {
          final foodData = item['foods'] as Map<String, dynamic>? ?? {};
          foods.add(MealFood(
            id: item['id'] as String,
            food: FoodItem(
              id: foodData['id'] ?? '',
              name: foodData['name'] ?? '',
              calories: (foodData['calories'] as num?)?.toDouble() ?? 0,
              protein: (foodData['protein'] as num?)?.toDouble() ?? 0,
              carbs: (foodData['carbs'] as num?)?.toDouble() ?? 0,
              fat: (foodData['fat'] as num?)?.toDouble() ?? 0,
              fiber: (foodData['fiber'] as num?)?.toDouble() ?? 0,
              portion: (foodData['serving_size'] as num?)?.toDouble() ?? 100,
            ),
            quantity: (item['quantity_g'] as num?)?.toDouble() ?? 0,
          ));
        }

        if (foods.isNotEmpty) {
          mealList.add(Meal(
            id: mealData['id'] as String,
            name: mealData['name'] as String,
            dateTime: DateTime.parse(mealData['consumed_at'] as String),
            mealType: mealData['meal_type'] as String,
            foods: foods,
          ));
        }
      }

      // Salva localmente
      await _saveLocal(mealList);
      _logDebug('Pull: ${mealList.length} refeições baixadas do Supabase');
    } catch (e) {
      _logDebug('Pull: Erro ao baixar do Supabase: $e');
    }
  }

  Future<List<Meal>> getMealsByDate(DateTime date) async {
    final meals = await getAllMeals();
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
    final meals = await getAllMeals();
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
      _logDebug('Erro ao deletar do Supabase: $e');
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
    final meals = await getAllMeals();
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

  Future<void> _syncMealToSupabase(Meal meal, {int retryCount = 3}) async {
    for (int attempt = 0; attempt < retryCount; attempt++) {
      try {
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) {
          _logDebug('Sync: Usuário não autenticado, salvando apenas localmente');
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
          _logDebug('Sync: Erro ao criar refeição principal');
          return;
        }

        // 2. Deletar itens antigos e inserir novos
        await _supabase
            .from('meal_items')
            .delete()
            .eq('meal_id', mealData['id']);

        for (final mealFood in meal.foods) {
          String foodId = await _ensureFoodExists(mealFood.food, userId);
          await _supabase.from('meal_items').insert({
            'id': '${mealData['id']}_${foodId}_${DateTime.now().millisecondsSinceEpoch}',
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
          });
        }

        _logDebug('Sync: Refeição ${meal.name} sincronizada com sucesso');
        return; // Sucesso, sai do retry
      } catch (e) {
        _logDebug('Sync: Tentativa ${attempt + 1} falhou: $e');
        if (attempt == retryCount - 1) {
          _logDebug('Sync: Todas as tentativas falharam. Erro final: $e');
          // Salva na fila de pendências para retry futuro
          await _saveToPendingQueue(meal);
        }
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }
  }

  Future<void> _saveToPendingQueue(Meal meal) async {
    final pending = _prefs.getStringList('pending_sync') ?? [];
    pending.add(jsonEncode(MealModel.fromEntity(meal).toJson()));
    await _prefs.setStringList('pending_sync', pending);
    _logDebug('Sync: Refeição salva na fila de pendências');
  }

  Future<void> processPendingSync() async {
    final pending = _prefs.getStringList('pending_sync') ?? [];
    if (pending.isEmpty) return;

    _logDebug('Sync: Processando ${pending.length} itens pendentes');
    final remaining = <String>[];

    for (final item in pending) {
      try {
        final meal = MealModel.fromJson(jsonDecode(item));
        await _syncMealToSupabase(meal, retryCount: 1);
        // Se chegou aqui, sync funcionou, remove da fila
      } catch (e) {
        remaining.add(item);
      }
    }

    await _prefs.setStringList('pending_sync', remaining);
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
      _logDebug('Erro ao garantir existência do alimento: $e');
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
void _logDebug(String message) {
  // ignore: avoid_print
  print('[SyncMealRepository] $message');
}
