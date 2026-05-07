import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/food_item.dart';
import '../../data/database/database_helper.dart';

class SyncMealRepository {
  final DatabaseHelper _db;
  final SupabaseClient _supabase;

  SyncMealRepository(this._db, this._supabase);

  Future<List<Meal>> getAllMeals() async {
    final userId = _supabase.auth.currentUser?.id;
    final dbMeals = await _db.getAllMeals(userId: userId);

    if (dbMeals.isEmpty) {
      await _pullFromSupabase();
      final dbMealsAfter = await _db.getAllMeals(userId: userId);
      return await _parseMealListWithFoods(dbMealsAfter);
    }

    return await _parseMealListWithFoods(dbMeals);
  }

  Future<List<Meal>> getMealsByDate(DateTime date) async {
    final userId = _supabase.auth.currentUser?.id;
    final dateStr = _formatDate(date);
    final dbMeals = await _db.getMealsByDate(dateStr, userId: userId);
    return await _parseMealListWithFoods(dbMeals);
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

      for (final mealData in meals) {
        final items = mealData['meal_items'] as List<dynamic>? ?? [];
        final foods = <Map<String, dynamic>>[];

        for (final item in items) {
          final foodData = item['foods'] as Map<String, dynamic>?;
          if (foodData != null && foodData.isNotEmpty) {
            foods.add({
              'id': item['id'] as String,
              'meal_id': mealData['id'],
              'food_id': foodData['id']?.toString() ?? '',
              'food_name': foodData['name']?.toString() ?? '',
              'food_calories':
                  (foodData['calories'] as num?)?.toDouble() ?? 0,
              'food_protein':
                  (foodData['protein'] as num?)?.toDouble() ?? 0,
              'food_carbs':
                  (foodData['carbs'] as num?)?.toDouble() ?? 0,
              'food_fat': (foodData['fat'] as num?)?.toDouble() ?? 0,
              'food_fiber':
                  (foodData['fiber'] as num?)?.toDouble() ?? 0,
              'food_sugar': 0.0,
              'food_sodium': 0.0,
              'food_portion':
                  (foodData['serving_size'] as num?)?.toDouble() ?? 100,
              'food_portion_unit': 'g',
              'food_image_url': foodData['image_url'],
              'food_barcode': foodData['barcode'],
              'quantity':
                  (item['quantity_g'] as num?)?.toDouble() ?? 100,
            });
          }
        }

        await _db.insertMealWithFoods(
          meal: {
            'id': mealData['id'],
            'user_id': userId,
            'name': mealData['name'],
            'meal_type': mealData['meal_type'],
            'consumed_at': mealData['consumed_at'],
            'date': mealData['date'],
            'input_method': mealData['input_method'] ?? 'manual',
            'notes': mealData['notes'],
            'sync_status': 'synced',
          },
          foods: foods,
        );
      }

      _logDebug(
        'Pull: ${meals.length} refeições baixadas do Supabase',
      );
    } catch (e) {
      _logDebug('Pull: Erro ao baixar do Supabase: $e');
    }
  }

  Future<void> deleteMeal(String mealId) async {
    await _db.deleteMealFoods(mealId);
    await _db.deleteMeal(mealId);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _supabase
            .from('meal_items')
            .delete()
            .eq('meal_id', mealId);
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

  Future<void> saveMeal(Meal meal) async {
    final dateStr = _formatDate(meal.dateTime);
    final userId = _supabase.auth.currentUser?.id;

    await _db.insertMealWithFoods(
      meal: {
        'id': meal.id,
        'user_id': userId,
        'name': meal.name,
        'meal_type': meal.mealType,
        'consumed_at': meal.dateTime.toIso8601String(),
        'date': dateStr,
        'input_method': 'manual',
        'notes': meal.notes,
        'sync_status': 'pending',
      },
      foods: meal.foods.map((mealFood) {
        return {
          'id': mealFood.id,
          'meal_id': meal.id,
          'food_id': mealFood.food.id,
          'food_name': mealFood.food.name,
          'food_calories': mealFood.food.calories,
          'food_protein': mealFood.food.protein,
          'food_carbs': mealFood.food.carbs,
          'food_fat': mealFood.food.fat,
          'food_fiber': mealFood.food.fiber,
          'food_sugar': mealFood.food.sugar,
          'food_sodium': mealFood.food.sodium,
          'food_portion': mealFood.food.portion,
          'food_portion_unit': mealFood.food.portionUnit,
          'food_image_url': mealFood.food.imageUrl,
          'food_barcode': mealFood.food.barcode,
          'quantity': mealFood.quantity,
        };
      }).toList(),
    );

    await _syncMealToSupabase(meal);
  }

  Future<void> _syncMealToSupabase(Meal meal, {int retryCount = 3}) async {
    for (int attempt = 0; attempt < retryCount; attempt++) {
      try {
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) {
          _logDebug(
            'Sync: Usuário não autenticado, salvando apenas localmente',
          );
          return;
        }

        final dateStr = _formatDate(meal.dateTime);

        final mealData = await _supabase
            .from('meals')
            .upsert({
              'id': meal.id,
              'user_id': userId,
              'name': meal.name,
              'meal_type': meal.mealType.toLowerCase(),
              'consumed_at': meal.dateTime.toIso8601String(),
              'date': dateStr,
              'input_method': 'manual',
            }, onConflict: 'id')
            .select('id')
            .maybeSingle();

        if (mealData == null) {
          _logDebug('Sync: Erro ao criar refeição principal');
          return;
        }

        await _supabase
            .from('meal_items')
            .delete()
            .eq('meal_id', mealData['id']);

        for (final mealFood in meal.foods) {
          final foodId =
              await _ensureFoodExists(mealFood.food, userId);
          await _supabase.from('meal_items').insert({
            'id':
                '${mealData['id']}_${foodId}_${DateTime.now().millisecondsSinceEpoch}',
            'meal_id': mealData['id'],
            'food_id': foodId,
            'food_name': mealFood.food.name,
            'quantity_g': mealFood.quantity,
            'calories':
                mealFood.food.calories * (mealFood.quantity / 100),
            'protein_g':
                mealFood.food.protein * (mealFood.quantity / 100),
            'carbs_g':
                mealFood.food.carbs * (mealFood.quantity / 100),
            'fat_g': mealFood.food.fat * (mealFood.quantity / 100),
            'fiber_g':
                mealFood.food.fiber * (mealFood.quantity / 100),
            'input_method': 'manual',
          });
        }

        await _db.markMealSynced(meal.id);
        _logDebug(
          'Sync: Refeição ${meal.name} sincronizada com sucesso',
        );
        return;
      } catch (e) {
        _logDebug('Sync: Tentativa ${attempt + 1} falhou: $e');
        if (attempt == retryCount - 1) {
          _logDebug(
            'Sync: Todas as tentativas falharam. Erro final: $e',
          );
          await _enqueueForSync(meal);
        }
        await Future.delayed(
          Duration(milliseconds: 500 * (attempt + 1)),
        );
      }
    }
  }

  Future<void> _enqueueForSync(Meal meal) async {
    final payload = jsonEncode({
      'id': meal.id,
      'name': meal.name,
      'mealType': meal.mealType,
      'dateTime': meal.dateTime.toIso8601String(),
      'foods': meal.foods.map((f) {
        return {
          'id': f.id,
          'food': {
            'id': f.food.id,
            'name': f.food.name,
            'calories': f.food.calories,
            'protein': f.food.protein,
            'carbs': f.food.carbs,
            'fat': f.food.fat,
            'fiber': f.food.fiber,
            'portion': f.food.portion,
          },
          'quantity': f.quantity,
        };
      }).toList(),
      'notes': meal.notes,
    });

    await _db.enqueueSync(
      entityType: 'meal',
      entityId: meal.id,
      payload: payload,
    );
  }

  Future<void> processPendingSync() async {
    final pending = await _db.getPendingSyncQueue();
    if (pending.isEmpty) return;

    _logDebug('Sync: Processando ${pending.length} itens pendentes');

    for (final item in pending) {
      try {
        final queueId = item['id'] as int;
        final payload = jsonDecode(item['payload'] as String);
        final meal = _parseMealFromSyncPayload(payload);
        await _syncMealToSupabase(meal, retryCount: 1);
        await _db.removeFromSyncQueue(queueId);
      } catch (e) {
        _logDebug('Sync: Falha ao processar item pendente: $e');
      }
    }
  }

  Meal _parseMealFromSyncPayload(Map<String, dynamic> json) {
    final dateTime = DateTime.parse(json['dateTime'] as String);
    final foodsList = (json['foods'] as List<dynamic>).map((f) {
      final foodData = f['food'] as Map<String, dynamic>;
      return MealFood(
        id: f['id'] as String,
        food: FoodItem(
          id: foodData['id'] as String,
          name: foodData['name'] as String,
          calories: (foodData['calories'] as num).toDouble(),
          protein: (foodData['protein'] as num).toDouble(),
          carbs: (foodData['carbs'] as num).toDouble(),
          fat: (foodData['fat'] as num).toDouble(),
          fiber: (foodData['fiber'] as num?)?.toDouble() ?? 0,
          portion: (foodData['portion'] as num).toDouble(),
        ),
        quantity: (f['quantity'] as num).toDouble(),
      );
    }).toList();

    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      dateTime: dateTime,
      mealType: json['mealType'] as String,
      foods: foodsList,
      notes: json['notes'] as String?,
    );
  }

  Future<String> _ensureFoodExists(
    FoodItem food,
    String userId,
  ) async {
    try {
      final existing = await _supabase
          .from('foods')
          .select('id')
          .eq('name', food.name)
          .maybeSingle();

      if (existing != null) {
        return existing['id'] as String;
      }

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
      _logDebug(
        'Erro ao garantir existência do alimento: $e',
      );
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
        .asyncMap((meals) => _parseRemoteMeals(meals));
  }

  Future<List<Meal>> _parseRemoteMeals(
    List<Map<String, dynamic>> meals,
  ) async {
    final mealList = <Meal>[];

    for (final mealData in meals) {
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
              calories:
                  (foodData['calories'] as num?)?.toDouble() ?? 0,
              protein:
                  (foodData['protein'] as num?)?.toDouble() ?? 0,
              carbs: (foodData['carbs'] as num?)?.toDouble() ?? 0,
              fat: (foodData['fat'] as num?)?.toDouble() ?? 0,
              fiber: (foodData['fiber'] as num?)?.toDouble() ?? 0,
              portion:
                  (foodData['serving_size'] as num?)?.toDouble() ??
                  100,
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

  Future<List<Meal>> _parseMealListWithFoods(
    List<Map<String, dynamic>> dbMeals,
  ) async {
    final mealList = <Meal>[];

    for (final mealData in dbMeals) {
      final mealId = mealData['id'] as String;
      final dbFoods = await _db.getMealFoods(mealId);

      final foods = dbFoods.map((foodData) {
        return MealFood(
          id: foodData['id'] as String,
          food: FoodItem(
            id: (foodData['food_id'] as String?) ?? '',
            name: foodData['food_name'] as String,
            calories: (foodData['food_calories'] as num).toDouble(),
            protein: (foodData['food_protein'] as num).toDouble(),
            carbs: (foodData['food_carbs'] as num).toDouble(),
            fat: (foodData['food_fat'] as num).toDouble(),
            fiber: (foodData['food_fiber'] as num).toDouble(),
            sugar: (foodData['food_sugar'] as num?)?.toDouble() ?? 0,
            sodium: (foodData['food_sodium'] as num?)?.toDouble() ?? 0,
            portion: (foodData['food_portion'] as num).toDouble(),
            portionUnit:
                foodData['food_portion_unit'] as String? ?? 'g',
            imageUrl: foodData['food_image_url'] as String?,
            barcode: foodData['food_barcode'] as String?,
          ),
          quantity: (foodData['quantity'] as num).toDouble(),
        );
      }).toList();

      mealList.add(
        Meal(
          id: mealId,
          name: mealData['name'] as String,
          dateTime:
              DateTime.parse(mealData['consumed_at'] as String),
          mealType: mealData['meal_type'] as String,
          foods: foods,
          notes: mealData['notes'] as String?,
        ),
      );
    }

    return mealList;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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

void _logDebug(String message) {
  // ignore: avoid_print
  print('[SyncMealRepository] $message');
}
