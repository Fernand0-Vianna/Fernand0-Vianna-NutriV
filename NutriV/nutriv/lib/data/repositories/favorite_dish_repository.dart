import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/favorite_dish_model.dart';

class FavoriteDishRepository {
  final SupabaseClient _supabase;

  FavoriteDishRepository(this._supabase);

  String? get _userId => _supabase.auth.currentUser?.id;

  Future<List<FavoriteDishModel>> getFavoriteDishes() async {
    final userId = _userId;
    if (userId == null) return [];

    final response = await _supabase
        .from('favorite_dishes')
        .select()
        .eq('user_id', userId)
        .order('times_used', ascending: false);

    return response.map((json) => FavoriteDishModel.fromJson(json)).toList();
  }

  Future<FavoriteDishModel?> getFavoriteDishById(String id) async {
    final response = await _supabase
        .from('favorite_dishes')
        .select()
        .eq('id', id)
        .maybeSingle();

    return response != null ? FavoriteDishModel.fromJson(response) : null;
  }

  Future<FavoriteDishModel> addFavoriteDish(FavoriteDishModel dish) async {
    final userId = _userId;
    if (userId == null) throw Exception('Usuário não autenticado');

    final now = DateTime.now();
    final data = dish.toJson()..['user_id'] = userId;
    data['created_at'] = now.toIso8601String();
    data['updated_at'] = now.toIso8601String();

    final response =
        await _supabase.from('favorite_dishes').insert(data).select().single();

    return FavoriteDishModel.fromJson(response);
  }

  Future<void> updateFavoriteDish(String id, FavoriteDishModel dish) async {
    final data = dish.toJson()
      ..['updated_at'] = DateTime.now().toIso8601String();

    await _supabase.from('favorite_dishes').update(data).eq('id', id);
  }

  Future<void> deleteFavoriteDish(String id) async {
    await _supabase.from('favorite_dishes').delete().eq('id', id);
  }

  Future<void> updateTimesUsed(String id, int timesUsed) async {
    await _supabase.from('favorite_dishes').update({
      'times_used': timesUsed,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> saveDishFromMeal({
    required String name,
    required List<FavoriteDishItem> items,
  }) async {
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

    final dish = FavoriteDishModel(
      name: name,
      items: items,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await addFavoriteDish(dish);
  }

  Stream<List<FavoriteDishModel>> watchFavoriteDishes() {
    final userId = _userId;
    if (userId == null) return Stream.value([]);

    return _supabase.from('favorite_dishes').stream(primaryKey: ['id']).map(
        (data) => data
            .where((d) => d['user_id'] == userId)
            .map((json) => FavoriteDishModel.fromJson(json))
            .toList());
  }
}
