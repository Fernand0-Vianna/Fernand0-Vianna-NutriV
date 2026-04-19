import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_model.dart';

class UserProfileRepository {
  final SupabaseClient _supabase;

  UserProfileRepository(this._supabase);

  /// Busca o perfil do usuário atual
  Future<UserProfileModel?> getCurrentProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .single();

    return UserProfileModel.fromJson(response);
  }

  /// Busca perfil por ID
  Future<UserProfileModel?> getProfileById(String userId) async {
    final response = await _supabase
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .single();

    return UserProfileModel.fromJson(response);
  }

  /// Atualiza o perfil
  Future<UserProfileModel?> updateProfile(UserProfileModel profile) async {
    final response = await _supabase
        .from('user_profiles')
        .update(profile.toJson())
        .eq('id', profile.id)
        .select()
        .single();

    return UserProfileModel.fromJson(response);
  }

  /// Atualiza último acesso
  Future<void> updateLastActive() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('user_profiles')
        .update({'last_active_at': DateTime.now().toIso8601String()})
        .eq('id', userId);
  }

  /// Atualiza peso atual
  Future<void> updateCurrentWeight(double weightKg) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('user_profiles')
        .update({
          'current_weight_kg': weightKg,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  /// Atualiza metas de calorias e macros
  Future<void> updateGoals({
    double? dailyCalories,
    double? protein,
    double? carbs,
    double? fat,
    double? water,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (dailyCalories != null) updates['daily_calories_target'] = dailyCalories;
    if (protein != null) updates['protein_target_g'] = protein;
    if (carbs != null) updates['carbs_target_g'] = carbs;
    if (fat != null) updates['fat_target_g'] = fat;
    if (water != null) updates['water_target_ml'] = water;

    await _supabase
        .from('user_profiles')
        .update(updates)
        .eq('id', userId);
  }

  /// Atualiza objetivo (perder, manter, ganhar)
  Future<void> updateGoalType(String goalType, {double? targetWeight}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final updates = <String, dynamic>{
      'goal_type': goalType,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (targetWeight != null) updates['target_weight_kg'] = targetWeight;

    await _supabase
        .from('user_profiles')
        .update(updates)
        .eq('id', userId);
  }

  /// Calcula e atualiza BMR/TDEE
  Future<void> calculateAndUpdateMetabolicRates() async {
    final profile = await getCurrentProfile();
    if (profile == null) return;

    // Fórmula de Harris-Benedict revisada
    double bmr;
    if (profile.gender == 'female') {
      bmr = 447.593 +
          (9.247 * (profile.currentWeightKg ?? 70)) +
          (3.098 * (profile.heightCm ?? 170)) -
          (4.330 * (profile.birthDate != null
              ? DateTime.now().difference(profile.birthDate!).inDays ~/ 365
              : 25));
    } else {
      bmr = 88.362 +
          (13.397 * (profile.currentWeightKg ?? 70)) +
          (4.799 * (profile.heightCm ?? 170)) -
          (5.677 * (profile.birthDate != null
              ? DateTime.now().difference(profile.birthDate!).inDays ~/ 365
              : 25));
    }

    // Multiplicador de atividade
    double activityMultiplier;
    switch (profile.activityLevel) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'light':
        activityMultiplier = 1.375;
        break;
      case 'moderate':
        activityMultiplier = 1.55;
        break;
      case 'active':
        activityMultiplier = 1.725;
        break;
      case 'very_active':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.55;
    }

    final tdee = bmr * activityMultiplier;

    // Ajuste baseado no objetivo
    double targetCalories;
    switch (profile.goalType) {
      case 'lose':
        targetCalories = tdee - 500; // Déficit de 500 calorias
        break;
      case 'gain':
        targetCalories = tdee + 500; // Superávit de 500 calorias
        break;
      case 'maintain':
      default:
        targetCalories = tdee;
        break;
    }

    // Atualizar no banco
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('user_profiles').update({
      'bmr_calories': bmr,
      'tdee_calories': tdee,
      'daily_calories_target': targetCalories,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  /// Stream do perfil para atualizações em tempo real
  Stream<UserProfileModel?> watchProfile() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value(null);

    return _supabase
        .from('user_profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) => data.isNotEmpty ? UserProfileModel.fromJson(data.first) : null);
  }
}
