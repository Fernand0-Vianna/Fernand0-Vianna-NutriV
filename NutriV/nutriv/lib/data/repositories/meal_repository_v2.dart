import 'package:supabase_flutter/supabase_flutter.dart';

/// Modelo para MealItem (alimento dentro de uma refeição)
class MealItemData {
  final String? id;
  final String? foodId;
  final String foodName;
  final double quantityG;
  final double? quantityServing;
  final String? servingDescription;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double? fiberG;
  final double? sugarG;
  final double? sodiumMg;
  final Map<String, dynamic>? micronutrients;
  final int displayOrder;

  MealItemData({
    this.id,
    this.foodId,
    required this.foodName,
    required this.quantityG,
    this.quantityServing,
    this.servingDescription,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG,
    this.sugarG,
    this.sodiumMg,
    this.micronutrients,
    this.displayOrder = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'food_name': foodName,
      'quantity_g': quantityG,
      'quantity_serving': quantityServing,
      'serving_description': servingDescription,
      'calories': calories,
      'protein_g': proteinG,
      'carbs_g': carbsG,
      'fat_g': fatG,
      'fiber_g': fiberG,
      'sugar_g': sugarG,
      'sodium_mg': sodiumMg,
      'micronutrients': micronutrients,
      'display_order': displayOrder,
    };
  }
}

/// Modelo para Meal (refeição)
class MealData {
  final String? id;
  final String userId;
  final String name;
  final String mealType;
  final DateTime consumedAt;
  final DateTime date;
  final String? aiScanImageUrl;
  final Map<String, dynamic>? aiRecognitionData;
  final double? aiConfidenceScore;
  final bool aiWasEdited;
  final String inputMethod;
  final String? notes;
  final DateTime? createdAt;
  final List<MealItemData>? items;

  MealData({
    this.id,
    required this.userId,
    required this.name,
    required this.mealType,
    required this.consumedAt,
    required this.date,
    this.aiScanImageUrl,
    this.aiRecognitionData,
    this.aiConfidenceScore,
    this.aiWasEdited = false,
    this.inputMethod = 'manual',
    this.notes,
    this.createdAt,
    this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'meal_type': mealType,
      'consumed_at': consumedAt.toIso8601String(),
      'date': date.toIso8601String().split('T')[0],
      'ai_scan_image_url': aiScanImageUrl,
      'ai_recognition_data': aiRecognitionData,
      'ai_confidence_score': aiConfidenceScore,
      'ai_was_edited': aiWasEdited,
      'input_method': inputMethod,
      'notes': notes,
    };
  }
}

/// Repository para gerenciar refeições
class MealRepositoryV2 {
  final SupabaseClient _supabase;

  MealRepositoryV2(this._supabase);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Cria uma nova refeição com seus itens
  Future<MealData> createMeal(MealData meal) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    // 1. Criar a refeição
    final mealResponse = await _supabase
        .from('meals')
        .insert(meal.toJson()..['user_id'] = userId)
        .select()
        .single();

    final mealId = mealResponse['id'] as String;

    // 2. Criar os itens da refeição
    if (meal.items != null && meal.items!.isNotEmpty) {
      final itemsData = meal.items!.map((item) {
        return item.toJson()..['meal_id'] = mealId;
      }).toList();

      await _supabase.from('meal_items').insert(itemsData);
    }

    // 3. Retornar a refeição completa
    return _getMealById(mealId);
  }

  /// Busca uma refeição completa (com itens)
  Future<MealData> _getMealById(String mealId) async {
    final mealResponse = await _supabase
        .from('meals')
        .select()
        .eq('id', mealId)
        .single();

    final itemsResponse = await _supabase
        .from('meal_items')
        .select()
        .eq('meal_id', mealId)
        .order('display_order');

    return _mealFromJson(mealResponse, itemsResponse);
  }

  /// Busca refeições do dia
  Future<List<MealData>> getMealsForDate(DateTime date) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final dateStr = date.toIso8601String().split('T')[0];

    final mealsResponse = await _supabase
        .from('meals')
        .select()
        .eq('user_id', userId)
        .eq('date', dateStr)
        .order('consumed_at');

    final List<MealData> meals = [];
    for (final mealJson in mealsResponse) {
      final itemsResponse = await _supabase
          .from('meal_items')
          .select()
          .eq('meal_id', mealJson['id'])
          .order('display_order');

      meals.add(_mealFromJson(mealJson, itemsResponse));
    }

    return meals;
  }

  /// Busca refeições de um período
  Future<List<MealData>> getMealsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];

    final mealsResponse = await _supabase
        .from('meals')
        .select()
        .eq('user_id', userId)
        .gte('date', startStr)
        .lte('date', endStr)
        .order('consumed_at');

    final List<MealData> meals = [];
    for (final mealJson in mealsResponse) {
      final itemsResponse = await _supabase
          .from('meal_items')
          .select()
          .eq('meal_id', mealJson['id'])
          .order('display_order');

      meals.add(_mealFromJson(mealJson, itemsResponse));
    }

    return meals;
  }

  /// Atualiza uma refeição
  Future<MealData> updateMeal(String mealId, MealData meal) async {
    await _supabase
        .from('meals')
        .update(meal.toJson()..remove('user_id'))
        .eq('id', mealId);

    // Atualizar itens se fornecidos
    if (meal.items != null) {
      // Deletar itens antigos
      await _supabase.from('meal_items').delete().eq('meal_id', mealId);

      // Inserir novos
      if (meal.items!.isNotEmpty) {
        final itemsData = meal.items!.map((item) {
          return item.toJson()..['meal_id'] = mealId;
        }).toList();

        await _supabase.from('meal_items').insert(itemsData);
      }
    }

    return _getMealById(mealId);
  }

  /// Deleta uma refeição
  Future<void> deleteMeal(String mealId) async {
    await _supabase.from('meals').delete().eq('id', mealId);
  }

  /// Adiciona item a uma refeição existente
  Future<void> addItemToMeal(String mealId, MealItemData item) async {
    await _supabase
        .from('meal_items')
        .insert(item.toJson()..['meal_id'] = mealId);
  }

  /// Remove item de uma refeição
  Future<void> removeItemFromMeal(String itemId) async {
    await _supabase.from('meal_items').delete().eq('id', itemId);
  }

  /// Atualiza notas de AI (quando usuário edita reconhecimento)
  Future<void> markAiAsEdited(String mealId) async {
    await _supabase
        .from('meals')
        .update({
          'ai_was_edited': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', mealId);
  }

  /// Stream de refeições em tempo real
  Stream<List<MealData>> watchMealsForDate(DateTime date) {
    final userId = _currentUserId;
    if (userId == null) return Stream.value([]);

    final dateStr = date.toIso8601String().split('T')[0];

    return _supabase.from('meals').stream(primaryKey: ['id']).asyncMap((
      mealsData,
    ) async {
      // Filtrar por user_id e date no client
      mealsData = mealsData
          .where((m) => m['user_id'] == userId && m['date'] == dateStr)
          .toList();
      final List<MealData> meals = [];
      for (final mealJson in mealsData) {
        final itemsResponse = await _supabase
            .from('meal_items')
            .select()
            .eq('meal_id', mealJson['id'])
            .order('display_order');

        meals.add(_mealFromJson(mealJson, itemsResponse));
      }
      return meals;
    });
  }

  /// Calcula totais de uma refeição
  Map<String, double> calculateMealTotals(List<MealItemData> items) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final item in items) {
      totalCalories += item.calories;
      totalProtein += item.proteinG;
      totalCarbs += item.carbsG;
      totalFat += item.fatG;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }

  /// Helper para converter JSON em MealData
  MealData _mealFromJson(
    Map<String, dynamic> mealJson,
    List<dynamic> itemsJson,
  ) {
    return MealData(
      id: mealJson['id'] as String,
      userId: mealJson['user_id'] as String,
      name: mealJson['name'] as String,
      mealType: mealJson['meal_type'] as String,
      consumedAt: DateTime.parse(mealJson['consumed_at'] as String),
      date: DateTime.parse(mealJson['date'] as String),
      aiScanImageUrl: mealJson['ai_scan_image_url'] as String?,
      aiRecognitionData:
          mealJson['ai_recognition_data'] as Map<String, dynamic>?,
      aiConfidenceScore: (mealJson['ai_confidence_score'] as num?)?.toDouble(),
      aiWasEdited: mealJson['ai_was_edited'] as bool? ?? false,
      inputMethod: mealJson['input_method'] as String? ?? 'manual',
      notes: mealJson['notes'] as String?,
      createdAt: DateTime.parse(mealJson['created_at'] as String),
      items: itemsJson.map((item) => _mealItemFromJson(item)).toList(),
    );
  }

  /// Helper para converter JSON em MealItemData
  MealItemData _mealItemFromJson(Map<String, dynamic> json) {
    return MealItemData(
      id: json['id'] as String?,
      foodId: json['food_id'] as String?,
      foodName: json['food_name'] as String,
      quantityG: (json['quantity_g'] as num).toDouble(),
      quantityServing: (json['quantity_serving'] as num?)?.toDouble(),
      servingDescription: json['serving_description'] as String?,
      calories: (json['calories'] as num).toDouble(),
      proteinG: (json['protein_g'] as num).toDouble(),
      carbsG: (json['carbs_g'] as num).toDouble(),
      fatG: (json['fat_g'] as num).toDouble(),
      fiberG: (json['fiber_g'] as num?)?.toDouble(),
      sugarG: (json['sugar_g'] as num?)?.toDouble(),
      sodiumMg: (json['sodium_mg'] as num?)?.toDouble(),
      micronutrients: json['micronutrients'] as Map<String, dynamic>?,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }
}
